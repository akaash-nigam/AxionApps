# Code Analysis Engine Design Document

## Document Information
- **Version**: 1.0
- **Last Updated**: 2025-11-24
- **Status**: Draft
- **Owner**: Engineering Team

## 1. Overview

This document specifies the code analysis engine responsible for parsing source code, extracting symbols, identifying dependencies, and providing syntax highlighting for multiple programming languages.

## 2. Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                  Code Analysis Engine                    │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   Parser     │  │  Dependency  │  │   Syntax     │ │
│  │   Manager    │  │  Extractor   │  │  Highlighter │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
│         │                  │                  │         │
│         └──────────────────┴──────────────────┘         │
│                           │                              │
│              ┌────────────┴────────────┐                │
│              │                         │                │
│       ┌──────────────┐         ┌──────────────┐        │
│       │  Tree-sitter │         │   SourceKit  │        │
│       │   Parsers    │         │  (Swift/ObjC)│        │
│       └──────────────┘         └──────────────┘        │
└─────────────────────────────────────────────────────────┘
```

## 3. Language Support

### 3.1 Supported Languages

| Language | Parser | Symbol Extraction | Dependency Extraction | Priority |
|----------|--------|-------------------|----------------------|----------|
| Swift | SourceKit + tree-sitter | ✓ | ✓ | High |
| JavaScript | tree-sitter | ✓ | ✓ | High |
| TypeScript | tree-sitter | ✓ | ✓ | High |
| Python | tree-sitter | ✓ | ✓ | High |
| Java | tree-sitter | ✓ | ✓ | Medium |
| Go | tree-sitter | ✓ | ✓ | Medium |
| Rust | tree-sitter | ✓ | ✓ | Medium |
| C++ | tree-sitter | ✓ | ✓ | Medium |
| Objective-C | SourceKit | ✓ | ✓ | Low |
| C# | tree-sitter | ✓ | ✓ | Low |

### 3.2 Language Detection

```swift
enum Language: String, Codable {
    case swift = "swift"
    case javascript = "javascript"
    case typescript = "typescript"
    case python = "python"
    case java = "java"
    case go = "go"
    case rust = "rust"
    case cpp = "cpp"
    case objc = "objc"
    case csharp = "csharp"
    case unknown = "unknown"

    static func detect(from filePath: String) -> Language {
        let ext = (filePath as NSString).pathExtension.lowercased()

        switch ext {
        case "swift": return .swift
        case "js", "jsx", "mjs": return .javascript
        case "ts", "tsx": return .typescript
        case "py", "pyw": return .python
        case "java": return .java
        case "go": return .go
        case "rs": return .rust
        case "cpp", "cc", "cxx", "c++", "hpp", "h": return .cpp
        case "m", "mm": return .objc
        case "cs": return .csharp
        default: return .unknown
        }
    }
}
```

## 4. Parser Manager

### 4.1 Interface

```swift
protocol CodeParser {
    var supportedLanguage: Language { get }

    func parse(_ source: String) async throws -> SyntaxTree
    func extractSymbols(from tree: SyntaxTree) -> [Symbol]
    func extractDependencies(from tree: SyntaxTree) -> [Dependency]
    func highlightSyntax(in tree: SyntaxTree) -> [SyntaxHighlight]
}

class ParserManager {
    private var parsers: [Language: CodeParser] = [:]
    private let parsingQueue = DispatchQueue(
        label: "com.spatialcodereviewer.parsing",
        qos: .userInitiated,
        attributes: .concurrent
    )

    init() {
        registerParsers()
    }

    private func registerParsers() {
        parsers[.swift] = SourceKitParser()
        parsers[.javascript] = TreeSitterParser(language: .javascript)
        parsers[.typescript] = TreeSitterParser(language: .typescript)
        parsers[.python] = TreeSitterParser(language: .python)
        parsers[.java] = TreeSitterParser(language: .java)
        parsers[.go] = TreeSitterParser(language: .go)
        parsers[.rust] = TreeSitterParser(language: .rust)
        parsers[.cpp] = TreeSitterParser(language: .cpp)
    }

    func parseFile(_ file: CodeFile) async throws -> ParseResult {
        let language = Language.detect(from: file.path)

        guard let parser = parsers[language] else {
            throw AnalysisError.unsupportedLanguage(language)
        }

        return try await withCheckedThrowingContinuation { continuation in
            parsingQueue.async {
                do {
                    let tree = try await parser.parse(file.content)
                    let symbols = parser.extractSymbols(from: tree)
                    let dependencies = parser.extractDependencies(from: tree)
                    let highlights = parser.highlightSyntax(in: tree)

                    let result = ParseResult(
                        file: file,
                        tree: tree,
                        symbols: symbols,
                        dependencies: dependencies,
                        highlights: highlights
                    )

                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func parseBatch(_ files: [CodeFile]) async throws -> [ParseResult] {
        try await withThrowingTaskGroup(of: ParseResult.self) { group in
            for file in files {
                group.addTask {
                    try await self.parseFile(file)
                }
            }

            var results: [ParseResult] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }
    }
}
```

### 4.2 Data Models

```swift
struct SyntaxTree {
    let rootNode: SyntaxNode
    let language: Language
    let source: String
}

struct SyntaxNode {
    let type: String
    let range: Range<Int>
    let startPosition: Position
    let endPosition: Position
    let children: [SyntaxNode]
    let text: String

    struct Position {
        let line: Int
        let column: Int
    }
}

struct Symbol {
    let id: UUID
    let name: String
    let kind: SymbolKind
    let range: Range<Int>
    let location: Location
    let signature: String?
    let parent: UUID?
    let children: [UUID]

    enum SymbolKind: String, Codable {
        case file
        case module
        case namespace
        case package
        case `class`
        case method
        case property
        case field
        case constructor
        case `enum`
        case interface
        case function
        case variable
        case constant
        case string
        case number
        case boolean
        case array
        case object
        case key
        case null
        case enumMember
        case `struct`
        case event
        case `operator`
        case typeParameter
    }

    struct Location {
        let line: Int
        let column: Int
        let length: Int
    }
}

struct Dependency {
    let id: UUID
    let sourceFile: String
    let targetFile: String?
    let targetSymbol: String?
    let type: DependencyType
    let location: Symbol.Location
}

enum DependencyType: String, Codable {
    case `import` = "import"
    case inheritance = "inheritance"
    case call = "call"
    case reference = "reference"
}

struct SyntaxHighlight {
    let range: Range<Int>
    let token: TokenType

    enum TokenType: String {
        case keyword
        case identifier
        case string
        case number
        case comment
        case `operator`
        case punctuation
        case type
        case function
        case variable
        case constant
        case parameter
        case property
        case decorator
        case macro
    }
}

struct ParseResult {
    let file: CodeFile
    let tree: SyntaxTree
    let symbols: [Symbol]
    let dependencies: [Dependency]
    let highlights: [SyntaxHighlight]
    let parseTime: TimeInterval
}
```

## 5. Tree-sitter Integration

### 5.1 Tree-sitter Parser Implementation

```swift
class TreeSitterParser: CodeParser {
    private let parser: TSParser
    private let language: Language
    private let tsLanguage: UnsafePointer<TSLanguage>

    var supportedLanguage: Language { language }

    init(language: Language) {
        self.language = language
        self.parser = ts_parser_new()

        // Load tree-sitter language grammar
        self.tsLanguage = Self.loadLanguageGrammar(for: language)
        ts_parser_set_language(parser, tsLanguage)
    }

    deinit {
        ts_parser_delete(parser)
    }

    func parse(_ source: String) async throws -> SyntaxTree {
        let startTime = Date()

        guard let tree = source.withCString({ cString in
            ts_parser_parse_string(
                parser,
                nil,
                cString,
                UInt32(strlen(cString))
            )
        }) else {
            throw AnalysisError.parsingFailed
        }

        let rootNode = ts_tree_root_node(tree)
        let syntaxTree = buildSyntaxTree(from: rootNode, source: source)

        ts_tree_delete(tree)

        let parseTime = Date().timeIntervalSince(startTime)
        print("Parsed \(language.rawValue) in \(parseTime)s")

        return syntaxTree
    }

    func extractSymbols(from tree: SyntaxTree) -> [Symbol] {
        var symbols: [Symbol] = []
        extractSymbolsRecursive(node: tree.rootNode, symbols: &symbols, parent: nil)
        return symbols
    }

    private func extractSymbolsRecursive(
        node: SyntaxNode,
        symbols: inout [Symbol],
        parent: UUID?
    ) {
        // Language-specific symbol extraction
        if let symbol = createSymbol(from: node, parent: parent) {
            symbols.append(symbol)

            // Recurse with this symbol as parent
            for child in node.children {
                extractSymbolsRecursive(node: child, symbols: &symbols, parent: symbol.id)
            }
        } else {
            // Just recurse without changing parent
            for child in node.children {
                extractSymbolsRecursive(node: child, symbols: &symbols, parent: parent)
            }
        }
    }

    private func createSymbol(from node: SyntaxNode, parent: UUID?) -> Symbol? {
        let kind: Symbol.SymbolKind?

        // Map tree-sitter node types to symbol kinds
        switch language {
        case .javascript, .typescript:
            kind = mapJavaScriptNodeToSymbol(node.type)
        case .python:
            kind = mapPythonNodeToSymbol(node.type)
        case .swift:
            kind = mapSwiftNodeToSymbol(node.type)
        // ... other languages
        default:
            kind = nil
        }

        guard let symbolKind = kind else { return nil }

        // Extract symbol name from node
        guard let name = extractSymbolName(from: node) else { return nil }

        return Symbol(
            id: UUID(),
            name: name,
            kind: symbolKind,
            range: node.range,
            location: Symbol.Location(
                line: node.startPosition.line,
                column: node.startPosition.column,
                length: node.range.count
            ),
            signature: extractSignature(from: node),
            parent: parent,
            children: []
        )
    }

    func extractDependencies(from tree: SyntaxTree) -> [Dependency] {
        var dependencies: [Dependency] = []

        switch language {
        case .javascript, .typescript:
            extractJavaScriptDependencies(node: tree.rootNode, dependencies: &dependencies)
        case .python:
            extractPythonDependencies(node: tree.rootNode, dependencies: &dependencies)
        case .swift:
            extractSwiftDependencies(node: tree.rootNode, dependencies: &dependencies)
        default:
            break
        }

        return dependencies
    }

    func highlightSyntax(in tree: SyntaxTree) -> [SyntaxHighlight] {
        var highlights: [SyntaxHighlight] = []
        highlightRecursive(node: tree.rootNode, highlights: &highlights)
        return highlights
    }

    private func highlightRecursive(node: SyntaxNode, highlights: inout [SyntaxHighlight]) {
        if let tokenType = mapNodeTypeToToken(node.type, language: language) {
            highlights.append(SyntaxHighlight(range: node.range, token: tokenType))
        }

        for child in node.children {
            highlightRecursive(node: child, highlights: &highlights)
        }
    }

    // MARK: - Language-specific helpers

    private func mapJavaScriptNodeToSymbol(_ nodeType: String) -> Symbol.SymbolKind? {
        switch nodeType {
        case "function_declaration", "arrow_function", "function": return .function
        case "class_declaration": return .class
        case "method_definition": return .method
        case "variable_declaration": return .variable
        case "const_declaration": return .constant
        case "interface_declaration": return .interface
        case "enum_declaration": return .enum
        default: return nil
        }
    }

    private func mapPythonNodeToSymbol(_ nodeType: String) -> Symbol.SymbolKind? {
        switch nodeType {
        case "function_definition": return .function
        case "class_definition": return .class
        default: return nil
        }
    }

    private func mapSwiftNodeToSymbol(_ nodeType: String) -> Symbol.SymbolKind? {
        switch nodeType {
        case "function_declaration": return .function
        case "class_declaration": return .class
        case "struct_declaration": return .struct
        case "enum_declaration": return .enum
        case "protocol_declaration": return .interface
        case "property_declaration": return .property
        default: return nil
        }
    }

    private func extractJavaScriptDependencies(
        node: SyntaxNode,
        dependencies: inout [Dependency]
    ) {
        if node.type == "import_statement" {
            // Extract import path
            if let path = extractImportPath(from: node) {
                dependencies.append(Dependency(
                    id: UUID(),
                    sourceFile: "",
                    targetFile: path,
                    targetSymbol: nil,
                    type: .import,
                    location: Symbol.Location(
                        line: node.startPosition.line,
                        column: node.startPosition.column,
                        length: node.range.count
                    )
                ))
            }
        }

        for child in node.children {
            extractJavaScriptDependencies(node: child, dependencies: &dependencies)
        }
    }

    private func extractPythonDependencies(
        node: SyntaxNode,
        dependencies: inout [Dependency]
    ) {
        if node.type == "import_statement" || node.type == "import_from_statement" {
            if let path = extractImportPath(from: node) {
                dependencies.append(Dependency(
                    id: UUID(),
                    sourceFile: "",
                    targetFile: path,
                    targetSymbol: nil,
                    type: .import,
                    location: Symbol.Location(
                        line: node.startPosition.line,
                        column: node.startPosition.column,
                        length: node.range.count
                    )
                ))
            }
        }

        for child in node.children {
            extractPythonDependencies(node: child, dependencies: &dependencies)
        }
    }

    private func extractSwiftDependencies(
        node: SyntaxNode,
        dependencies: inout [Dependency]
    ) {
        if node.type == "import_declaration" {
            if let module = extractModuleName(from: node) {
                dependencies.append(Dependency(
                    id: UUID(),
                    sourceFile: "",
                    targetFile: module,
                    targetSymbol: nil,
                    type: .import,
                    location: Symbol.Location(
                        line: node.startPosition.line,
                        column: node.startPosition.column,
                        length: node.range.count
                    )
                ))
            }
        }

        for child in node.children {
            extractSwiftDependencies(node: child, dependencies: &dependencies)
        }
    }

    // MARK: - Helper methods

    private static func loadLanguageGrammar(for language: Language) -> UnsafePointer<TSLanguage> {
        // Load compiled tree-sitter language grammar
        switch language {
        case .javascript:
            return tree_sitter_javascript()
        case .typescript:
            return tree_sitter_typescript()
        case .python:
            return tree_sitter_python()
        case .java:
            return tree_sitter_java()
        case .go:
            return tree_sitter_go()
        case .rust:
            return tree_sitter_rust()
        case .cpp:
            return tree_sitter_cpp()
        default:
            fatalError("Unsupported language: \(language)")
        }
    }

    private func buildSyntaxTree(from tsNode: TSNode, source: String) -> SyntaxTree {
        let rootNode = convertNode(tsNode, source: source)
        return SyntaxTree(rootNode: rootNode, language: language, source: source)
    }

    private func convertNode(_ tsNode: TSNode, source: String) -> SyntaxNode {
        let type = String(cString: ts_node_type(tsNode))
        let startByte = Int(ts_node_start_byte(tsNode))
        let endByte = Int(ts_node_end_byte(tsNode))
        let range = startByte..<endByte

        let startPoint = ts_node_start_point(tsNode)
        let endPoint = ts_node_end_point(tsNode)

        let startPosition = SyntaxNode.Position(
            line: Int(startPoint.row),
            column: Int(startPoint.column)
        )
        let endPosition = SyntaxNode.Position(
            line: Int(endPoint.row),
            column: Int(endPoint.column)
        )

        let text = String(source[source.index(source.startIndex, offsetBy: startByte)..<source.index(source.startIndex, offsetBy: endByte)])

        var children: [SyntaxNode] = []
        let childCount = ts_node_child_count(tsNode)

        for i in 0..<childCount {
            let childNode = ts_node_child(tsNode, UInt32(i))
            children.append(convertNode(childNode, source: source))
        }

        return SyntaxNode(
            type: type,
            range: range,
            startPosition: startPosition,
            endPosition: endPosition,
            children: children,
            text: text
        )
    }

    private func extractSymbolName(from node: SyntaxNode) -> String? {
        // Look for identifier child
        for child in node.children {
            if child.type == "identifier" || child.type == "property_identifier" {
                return child.text
            }
        }
        return nil
    }

    private func extractSignature(from node: SyntaxNode) -> String? {
        // Extract full signature (for functions, methods)
        return node.text.components(separatedBy: .newlines).first?.trimmingCharacters(in: .whitespaces)
    }

    private func extractImportPath(from node: SyntaxNode) -> String? {
        // Find string literal in import statement
        for child in node.children {
            if child.type == "string" || child.type == "string_literal" {
                var path = child.text
                path = path.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                return path
            }
        }
        return nil
    }

    private func extractModuleName(from node: SyntaxNode) -> String? {
        for child in node.children {
            if child.type == "identifier" {
                return child.text
            }
        }
        return nil
    }

    private func mapNodeTypeToToken(
        _ nodeType: String,
        language: Language
    ) -> SyntaxHighlight.TokenType? {
        // Map tree-sitter node types to syntax highlighting tokens
        // This is simplified - real implementation would be more comprehensive

        let commonKeywords = [
            "if", "else", "for", "while", "return", "function",
            "class", "const", "let", "var", "import", "export"
        ]

        if commonKeywords.contains(nodeType) {
            return .keyword
        }

        switch nodeType {
        case "string", "string_literal", "template_string":
            return .string
        case "number", "integer", "float":
            return .number
        case "comment":
            return .comment
        case "identifier":
            return .identifier
        case "type_identifier":
            return .type
        case "function_declaration", "method_definition":
            return .function
        case "property_identifier":
            return .property
        default:
            return nil
        }
    }
}
```

## 6. SourceKit Integration (Swift)

### 6.1 SourceKit Parser

```swift
class SourceKitParser: CodeParser {
    var supportedLanguage: Language { .swift }

    func parse(_ source: String) async throws -> SyntaxTree {
        // Use SourceKittenFramework or SwiftSyntax
        let syntaxTree = try SwiftParser.parse(source: source)
        return convertSwiftSyntaxTree(syntaxTree)
    }

    func extractSymbols(from tree: SyntaxTree) -> [Symbol] {
        // Use SourceKit's symbol extraction
        var symbols: [Symbol] = []

        // SwiftSyntax provides structured access to symbols
        // Walk the syntax tree and extract declarations

        return symbols
    }

    func extractDependencies(from tree: SyntaxTree) -> [Dependency] {
        // Extract import statements and type references
        var dependencies: [Dependency] = []

        // Process import declarations
        // Process inheritance clauses
        // Process type references

        return dependencies
    }

    func highlightSyntax(in tree: SyntaxTree) -> [SyntaxHighlight] {
        // Use SwiftSyntax for accurate highlighting
        var highlights: [SyntaxHighlight] = []

        // SwiftSyntax provides token information directly

        return highlights
    }

    private func convertSwiftSyntaxTree(_ swiftSyntax: SwiftSyntax.SourceFileSyntax) -> SyntaxTree {
        // Convert SwiftSyntax tree to our internal representation
        // ...
        fatalError("Not implemented")
    }
}
```

## 7. Caching Strategy

### 7.1 Parse Result Cache

```swift
class ParseCache {
    private var cache: [String: CachedParseResult] = [:]
    private let queue = DispatchQueue(label: "com.spatialcodereviewer.cache")

    struct CachedParseResult {
        let result: ParseResult
        let contentHash: String
        let timestamp: Date
    }

    func get(for file: CodeFile) -> ParseResult? {
        queue.sync {
            guard let cached = cache[file.path] else { return nil }

            // Check if content has changed
            let currentHash = file.content.hashValue
            if String(currentHash) != cached.contentHash {
                cache.removeValue(forKey: file.path)
                return nil
            }

            // Check if cache is stale (older than 5 minutes)
            if Date().timeIntervalSince(cached.timestamp) > 300 {
                cache.removeValue(forKey: file.path)
                return nil
            }

            return cached.result
        }
    }

    func set(_ result: ParseResult, for file: CodeFile) {
        queue.async(flags: .barrier) {
            let hash = String(file.content.hashValue)
            self.cache[file.path] = CachedParseResult(
                result: result,
                contentHash: hash,
                timestamp: Date()
            )
        }
    }

    func invalidate(file: String) {
        queue.async(flags: .barrier) {
            self.cache.removeValue(forKey: file)
        }
    }

    func clear() {
        queue.async(flags: .barrier) {
            self.cache.removeAll()
        }
    }
}
```

## 8. Incremental Parsing

### 8.1 Incremental Update Strategy

```swift
class IncrementalParser {
    private var previousTree: TSTree?
    private let parser: TSParser

    func parseIncremental(
        _ newSource: String,
        changes: [TextEdit]
    ) throws -> SyntaxTree {
        // Convert changes to tree-sitter input edits
        let tsEdits = changes.map { convertToTSInputEdit($0) }

        // Apply edits to previous tree
        if let oldTree = previousTree {
            for edit in tsEdits {
                var mutableEdit = edit
                ts_tree_edit(oldTree, &mutableEdit)
            }
        }

        // Parse with previous tree for incremental parsing
        let newTree = newSource.withCString { cString in
            ts_parser_parse_string(
                parser,
                previousTree,
                cString,
                UInt32(strlen(cString))
            )
        }

        // Store for next incremental parse
        if let previousTree = previousTree {
            ts_tree_delete(previousTree)
        }
        previousTree = newTree

        return buildSyntaxTree(from: ts_tree_root_node(newTree!), source: newSource)
    }

    private func convertToTSInputEdit(_ edit: TextEdit) -> TSInputEdit {
        // Convert our TextEdit to tree-sitter's TSInputEdit
        return TSInputEdit(
            start_byte: UInt32(edit.startByte),
            old_end_byte: UInt32(edit.oldEndByte),
            new_end_byte: UInt32(edit.newEndByte),
            start_point: TSPoint(row: UInt32(edit.startLine), column: UInt32(edit.startColumn)),
            old_end_point: TSPoint(row: UInt32(edit.oldEndLine), column: UInt32(edit.oldEndColumn)),
            new_end_point: TSPoint(row: UInt32(edit.newEndLine), column: UInt32(edit.newEndColumn))
        )
    }
}

struct TextEdit {
    let startByte: Int
    let oldEndByte: Int
    let newEndByte: Int
    let startLine: Int
    let startColumn: Int
    let oldEndLine: Int
    let oldEndColumn: Int
    let newEndLine: Int
    let newEndColumn: Int
}
```

## 9. Error Handling

### 9.1 Analysis Errors

```swift
enum AnalysisError: LocalizedError {
    case unsupportedLanguage(Language)
    case parsingFailed
    case invalidSyntax(line: Int, message: String)
    case dependencyResolutionFailed(String)
    case symbolExtractionFailed

    var errorDescription: String? {
        switch self {
        case .unsupportedLanguage(let lang):
            return "Language '\(lang.rawValue)' is not supported"
        case .parsingFailed:
            return "Failed to parse source code"
        case .invalidSyntax(let line, let message):
            return "Syntax error at line \(line): \(message)"
        case .dependencyResolutionFailed(let dep):
            return "Failed to resolve dependency: \(dep)"
        case .symbolExtractionFailed:
            return "Failed to extract symbols"
        }
    }
}
```

## 10. Performance Optimization

### 10.1 Parsing Performance Targets

| Metric | Target |
|--------|--------|
| Small file (< 500 LOC) | < 50ms |
| Medium file (500-2000 LOC) | < 200ms |
| Large file (2000-10000 LOC) | < 1s |
| Incremental parse | < 10ms |

### 10.2 Optimization Strategies

1. **Lazy Parsing**: Only parse visible code initially
2. **Background Parsing**: Parse on background queue
3. **Incremental Updates**: Use tree-sitter's incremental parsing
4. **Caching**: Cache parse results with content hashing
5. **Batch Processing**: Parse multiple files in parallel

## 11. Testing

### 11.1 Test Cases

```swift
class CodeAnalysisTests: XCTestCase {
    func testJavaScriptParsing() async throws {
        let source = """
        import { foo } from './bar';

        class Example {
            method() {
                return foo();
            }
        }
        """

        let parser = TreeSitterParser(language: .javascript)
        let tree = try await parser.parse(source)

        XCTAssertEqual(tree.language, .javascript)
        XCTAssertFalse(tree.rootNode.children.isEmpty)
    }

    func testSymbolExtraction() async throws {
        let source = """
        function hello(name) {
            return `Hello, ${name}`;
        }

        class Greeter {
            greet() {
                return hello('World');
            }
        }
        """

        let parser = TreeSitterParser(language: .javascript)
        let tree = try await parser.parse(source)
        let symbols = parser.extractSymbols(from: tree)

        XCTAssertEqual(symbols.filter { $0.kind == .function }.count, 1)
        XCTAssertEqual(symbols.filter { $0.kind == .class }.count, 1)
        XCTAssertEqual(symbols.filter { $0.kind == .method }.count, 1)
    }

    func testDependencyExtraction() async throws {
        let source = """
        import React from 'react';
        import { Button } from './components/Button';

        export default function App() {
            return <Button />;
        }
        """

        let parser = TreeSitterParser(language: .javascript)
        let tree = try await parser.parse(source)
        let dependencies = parser.extractDependencies(from: tree)

        XCTAssertEqual(dependencies.filter { $0.type == .import }.count, 2)
    }
}
```

## 12. References

- [System Architecture Document](./01-system-architecture.md)
- [Data Models Document](./02-data-models.md)
- tree-sitter Documentation: https://tree-sitter.github.io/tree-sitter/
- SwiftSyntax Documentation
- SourceKit-LSP Documentation

## 13. Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-24 | Engineering Team | Initial draft |
