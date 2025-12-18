import Foundation
import simd

/// IFC (Industry Foundation Classes) file parser
/// Parses IFC files and extracts building elements, properties, and spatial hierarchy
actor IFCParser {
    // MARK: - Properties

    private var elements: [ParsedElement] = []
    private var spatialStructure: SpatialHierarchy?
    private var properties: [String: [String: Any]] = [:]
    private var errors: [ParsingError] = []

    // MARK: - Public Interface

    /// Parse an IFC file and extract elements
    func parse(fileURL: URL) async throws -> ParsingResult {
        elements.removeAll()
        properties.removeAll()
        errors.removeAll()

        // Read file content
        let content = try String(contentsOf: fileURL, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)

        // Parse header
        let header = try parseHeader(lines: lines)

        // Parse entity instances
        let instances = try parseInstances(lines: lines)

        // Build spatial hierarchy
        spatialStructure = try buildSpatialHierarchy(instances: instances)

        // Extract building elements
        try extractElements(from: instances)

        // Extract properties
        try extractProperties(from: instances)

        return ParsingResult(
            header: header,
            elements: elements,
            spatialStructure: spatialStructure!,
            properties: properties,
            errors: errors
        )
    }

    // MARK: - Header Parsing

    private func parseHeader(lines: [String]) throws -> IFCHeader {
        var headerLines: [String] = []
        var inHeader = false

        for line in lines {
            if line.contains("HEADER;") {
                inHeader = true
                continue
            }
            if line.contains("ENDSEC;") {
                break
            }
            if inHeader {
                headerLines.append(line)
            }
        }

        // Extract header information
        var fileName = ""
        var timeStamp = Date()
        var author = ""
        var organization = ""
        var preprocessorVersion = ""
        var originatingSystem = ""
        var authorization = ""
        var fileDescription: [String] = []
        var implementationLevel = ""
        var schemaIdentifiers: [String] = []

        for line in headerLines {
            if line.contains("FILE_NAME") {
                fileName = extractParameter(from: line, at: 0)
                if let timestamp = extractParameter(from: line, at: 1, as: Date.self) {
                    timeStamp = timestamp
                }
                author = extractParameter(from: line, at: 2)
                organization = extractParameter(from: line, at: 3)
                preprocessorVersion = extractParameter(from: line, at: 4)
                originatingSystem = extractParameter(from: line, at: 5)
                authorization = extractParameter(from: line, at: 6)
            }
            else if line.contains("FILE_DESCRIPTION") {
                fileDescription = extractArray(from: line, at: 0)
                implementationLevel = extractParameter(from: line, at: 1)
            }
            else if line.contains("FILE_SCHEMA") {
                schemaIdentifiers = extractArray(from: line, at: 0)
            }
        }

        return IFCHeader(
            fileName: fileName,
            timeStamp: timeStamp,
            author: author,
            organization: organization,
            preprocessorVersion: preprocessorVersion,
            originatingSystem: originatingSystem,
            authorization: authorization,
            fileDescription: fileDescription,
            implementationLevel: implementationLevel,
            schemaIdentifiers: schemaIdentifiers
        )
    }

    // MARK: - Instance Parsing

    private func parseInstances(lines: [String]) throws -> [String: IFCInstance] {
        var instances: [String: IFCInstance] = [:]
        var inData = false

        for line in lines {
            if line.contains("DATA;") {
                inData = true
                continue
            }
            if line.contains("ENDSEC;") {
                break
            }

            guard inData else { continue }

            // Parse instance line: #123=IFCWALL('2eF8...',#5,'Wall-001',$,$,#10,#15,$,.STANDARD.);
            if line.hasPrefix("#") {
                do {
                    let instance = try parseInstance(line: line)
                    instances[instance.id] = instance
                } catch {
                    errors.append(.instanceParsingFailed(line: line, error: error))
                }
            }
        }

        return instances
    }

    private func parseInstance(line: String) throws -> IFCInstance {
        // Extract ID
        guard let idRange = line.range(of: "^#(\\d+)", options: .regularExpression) else {
            throw ParsingError.invalidInstanceFormat(line: line)
        }
        let idString = String(line[idRange]).dropFirst()
        guard let id = Int(idString) else {
            throw ParsingError.invalidInstanceID(line: line)
        }

        // Extract type
        guard let typeRange = line.range(of: "IFC[A-Z]+", options: .regularExpression) else {
            throw ParsingError.missingEntityType(line: line)
        }
        let type = String(line[typeRange])

        // Extract parameters
        let parametersStart = line.firstIndex(of: "(")!
        let parametersEnd = line.lastIndex(of: ")")!
        let parametersString = String(line[line.index(after: parametersStart)..<parametersEnd])
        let parameters = parseParameters(parametersString)

        return IFCInstance(
            id: "#\(id)",
            type: type,
            parameters: parameters
        )
    }

    private func parseParameters(_ string: String) -> [IFCParameter] {
        var parameters: [IFCParameter] = []
        var current = ""
        var depth = 0
        var inString = false

        for char in string {
            switch char {
            case "'" where !inString:
                inString = true
                current.append(char)
            case "'" where inString:
                inString = false
                current.append(char)
            case "(" where !inString:
                depth += 1
                current.append(char)
            case ")" where !inString:
                depth -= 1
                current.append(char)
            case "," where depth == 0 && !inString:
                parameters.append(parseParameter(current.trimmingCharacters(in: .whitespaces)))
                current = ""
            default:
                current.append(char)
            }
        }

        if !current.isEmpty {
            parameters.append(parseParameter(current.trimmingCharacters(in: .whitespaces)))
        }

        return parameters
    }

    private func parseParameter(_ string: String) -> IFCParameter {
        if string == "$" {
            return .null
        } else if string.hasPrefix("'") && string.hasSuffix("'") {
            let value = String(string.dropFirst().dropLast())
            return .string(value)
        } else if string.hasPrefix("#") {
            return .reference(string)
        } else if let intValue = Int(string) {
            return .integer(intValue)
        } else if let doubleValue = Double(string) {
            return .real(doubleValue)
        } else if string == ".T." {
            return .boolean(true)
        } else if string == ".F." {
            return .boolean(false)
        } else if string.hasPrefix("(") && string.hasSuffix(")") {
            let inner = String(string.dropFirst().dropLast())
            let items = parseParameters(inner)
            return .array(items)
        } else {
            return .enumeration(string)
        }
    }

    // MARK: - Spatial Hierarchy

    private func buildSpatialHierarchy(instances: [String: IFCInstance]) throws -> SpatialHierarchy {
        // Find project
        guard let projectInstance = instances.values.first(where: { $0.type == "IFCPROJECT" }) else {
            throw ParsingError.missingProject
        }

        let project = SpatialElement(
            id: projectInstance.id,
            type: .project,
            name: extractName(from: projectInstance),
            children: []
        )

        // Find sites
        let sites = instances.values.filter { $0.type == "IFCSITE" }
        for siteInstance in sites {
            let site = try buildSpatialElement(siteInstance, instances: instances, type: .site)
            project.children.append(site)
        }

        return SpatialHierarchy(root: project)
    }

    private func buildSpatialElement(
        _ instance: IFCInstance,
        instances: [String: IFCInstance],
        type: SpatialElementType
    ) throws -> SpatialElement {
        let element = SpatialElement(
            id: instance.id,
            type: type,
            name: extractName(from: instance),
            children: []
        )

        // Find child elements through relationships
        let relContains = instances.values.filter { inst in
            inst.type == "IFCRELAGGREGATES" &&
            inst.parameters.contains { param in
                if case .reference(let ref) = param, ref == instance.id {
                    return true
                }
                return false
            }
        }

        for rel in relContains {
            // Extract related elements
            if case .array(let children) = rel.parameters.last ?? .null {
                for child in children {
                    if case .reference(let childId) = child,
                       let childInstance = instances[childId] {
                        let childType = spatialTypeFromIFC(childInstance.type)
                        if let childType = childType {
                            let childElement = try buildSpatialElement(
                                childInstance,
                                instances: instances,
                                type: childType
                            )
                            element.children.append(childElement)
                        }
                    }
                }
            }
        }

        return element
    }

    private func spatialTypeFromIFC(_ ifcType: String) -> SpatialElementType? {
        switch ifcType {
        case "IFCPROJECT": return .project
        case "IFCSITE": return .site
        case "IFCBUILDING": return .building
        case "IFCBUILDINGSTOREY": return .storey
        case "IFCSPACE": return .space
        default: return nil
        }
    }

    // MARK: - Element Extraction

    private func extractElements(from instances: [String: IFCInstance]) throws {
        let buildingElements = instances.values.filter { instance in
            instance.type.hasPrefix("IFC") &&
            !instance.type.contains("REL") &&
            !instance.type.contains("PROPERTY") &&
            isPhysicalElement(instance.type)
        }

        for instance in buildingElements {
            do {
                let element = try parseElement(instance, instances: instances)
                elements.append(element)
            } catch {
                errors.append(.elementExtractionFailed(id: instance.id, error: error))
            }
        }
    }

    private func parseElement(_ instance: IFCInstance, instances: [String: IFCInstance]) throws -> ParsedElement {
        // Extract GUID
        let guid: String
        if case .string(let guidString) = instance.parameters.first ?? .null {
            guid = guidString
        } else {
            guid = instance.id
        }

        // Extract name
        let name = extractName(from: instance)

        // Extract discipline
        let discipline = determineDiscipline(from: instance.type)

        // Extract geometry
        let geometry = try extractGeometry(from: instance, instances: instances)

        // Extract properties
        let props = extractElementProperties(from: instance, instances: instances)

        return ParsedElement(
            guid: guid,
            type: instance.type,
            name: name,
            discipline: discipline,
            geometry: geometry,
            properties: props
        )
    }

    private func isPhysicalElement(_ type: String) -> Bool {
        let physicalTypes = [
            "IFCWALL", "IFCWALLSTANDARDCASE", "IFCSLAB", "IFCROOF",
            "IFCBEAM", "IFCCOLUMN", "IFCDOOR", "IFCWINDOW",
            "IFCSTAIR", "IFCRAILING", "IFCCURTAINWALL",
            "IFCFURNISHINGELEMENT", "IFCBUILDINGELEMENTPROXY",
            "IFCMEMBER", "IFCPLATE", "IFCFOOTING", "IFCPILE",
            "IFCCHIMNEY", "IFCCOVERING", "IFCFURNITURE"
        ]
        return physicalTypes.contains(type)
    }

    private func determineDiscipline(from type: String) -> Discipline {
        if type.contains("WALL") || type.contains("SLAB") || type.contains("COLUMN") ||
           type.contains("BEAM") || type.contains("FOOTING") || type.contains("PILE") {
            return .structural
        } else if type.contains("DOOR") || type.contains("WINDOW") || type.contains("STAIR") ||
                  type.contains("RAILING") || type.contains("FURNISHING") || type.contains("FURNITURE") {
            return .architectural
        } else if type.contains("DUCT") || type.contains("PIPE") {
            return .mechanical
        } else if type.contains("CABLE") || type.contains("LIGHT") {
            return .electrical
        } else {
            return .architectural
        }
    }

    // MARK: - Geometry Extraction

    private func extractGeometry(
        from instance: IFCInstance,
        instances: [String: IFCInstance]
    ) throws -> ElementGeometry? {
        // Find placement
        guard let placementParam = instance.parameters.first(where: { param in
            if case .reference(let ref) = param,
               let refInstance = instances[ref],
               refInstance.type.contains("PLACEMENT") {
                return true
            }
            return false
        }) else {
            return nil
        }

        guard case .reference(let placementRef) = placementParam,
              let placementInstance = instances[placementRef] else {
            return nil
        }

        // Extract position
        let position = try extractPosition(from: placementInstance, instances: instances)

        // Extract representation (shape)
        let shape = try extractShape(from: instance, instances: instances)

        return ElementGeometry(
            position: position,
            rotation: simd_quatf(angle: 0, axis: [0, 1, 0]),
            scale: SIMD3<Float>(1, 1, 1),
            shape: shape
        )
    }

    private func extractPosition(
        from placementInstance: IFCInstance,
        instances: [String: IFCInstance]
    ) throws -> SIMD3<Float> {
        // Extract location from IFCLOCALPLACEMENT
        guard let locationParam = placementInstance.parameters.last,
              case .reference(let locationRef) = locationParam,
              let locationInstance = instances[locationRef],
              locationInstance.type.contains("CARTESIANPOINT") else {
            return SIMD3<Float>(0, 0, 0)
        }

        // Extract coordinates
        guard case .array(let coords) = locationInstance.parameters.first ?? .null else {
            return SIMD3<Float>(0, 0, 0)
        }

        var position = SIMD3<Float>(0, 0, 0)
        if case .real(let x) = coords.dropFirst(0).first ?? .null {
            position.x = Float(x)
        }
        if case .real(let y) = coords.dropFirst(1).first ?? .null {
            position.y = Float(y)
        }
        if coords.count > 2, case .real(let z) = coords.dropFirst(2).first ?? .null {
            position.z = Float(z)
        }

        return position
    }

    private func extractShape(
        from instance: IFCInstance,
        instances: [String: IFCInstance]
    ) throws -> Shape {
        // Simplified shape extraction - real implementation would be much more complex
        // Would need to handle: IFCSHAPEREPRESENTATION, IFCEXTRUDEDAREASOLID, etc.

        return .box(width: 1.0, height: 1.0, depth: 1.0)
    }

    // MARK: - Property Extraction

    private func extractProperties(from instances: [String: IFCInstance]) throws {
        let propertySets = instances.values.filter { $0.type == "IFCPROPERTYSET" }

        for propertySet in propertySets {
            guard let nameParam = propertySet.parameters.dropFirst(3).first,
                  case .string(let setName) = nameParam else {
                continue
            }

            var setProperties: [String: Any] = [:]

            // Extract properties from set
            if let propsParam = propertySet.parameters.last,
               case .array(let propRefs) = propsParam {
                for propRef in propRefs {
                    if case .reference(let ref) = propRef,
                       let propInstance = instances[ref] {
                        let (name, value) = extractProperty(from: propInstance)
                        setProperties[name] = value
                    }
                }
            }

            properties[propertySet.id] = setProperties
        }
    }

    private func extractElementProperties(
        from instance: IFCInstance,
        instances: [String: IFCInstance]
    ) -> [String: Any] {
        var props: [String: Any] = [:]

        // Find property relationships
        let relDefines = instances.values.filter { inst in
            inst.type == "IFCRELDEFINESBYPROPERTIES" &&
            inst.parameters.contains { param in
                if case .array(let refs) = param {
                    return refs.contains { ref in
                        if case .reference(let id) = ref {
                            return id == instance.id
                        }
                        return false
                    }
                }
                return false
            }
        }

        for rel in relDefines {
            if let propSetRef = rel.parameters.last,
               case .reference(let ref) = propSetRef,
               let storedProps = properties[ref] {
                props.merge(storedProps) { _, new in new }
            }
        }

        return props
    }

    private func extractProperty(from instance: IFCInstance) -> (name: String, value: Any) {
        guard case .string(let name) = instance.parameters.dropFirst(0).first ?? .null else {
            return ("unknown", "")
        }

        // Extract value based on property type
        var value: Any = ""

        if instance.type == "IFCPROPERTYSINGLEVALUE" {
            if case .reference(let valueRef) = instance.parameters.dropFirst(2).first ?? .null {
                // Nominal value
                value = valueRef
            }
        }

        return (name, value)
    }

    // MARK: - Helper Methods

    private func extractName(from instance: IFCInstance) -> String {
        // Name is typically the 3rd or 4th parameter
        for param in instance.parameters.dropFirst(2).prefix(2) {
            if case .string(let name) = param, !name.isEmpty {
                return name
            }
        }
        return "Unnamed"
    }

    private func extractParameter<T>(from line: String, at index: Int, as type: T.Type = String.self) -> T? {
        // Simplified parameter extraction
        return nil
    }

    private func extractParameter(from line: String, at index: Int) -> String {
        return ""
    }

    private func extractArray(from line: String, at index: Int) -> [String] {
        return []
    }
}

// MARK: - Supporting Types

struct IFCHeader {
    let fileName: String
    let timeStamp: Date
    let author: String
    let organization: String
    let preprocessorVersion: String
    let originatingSystem: String
    let authorization: String
    let fileDescription: [String]
    let implementationLevel: String
    let schemaIdentifiers: [String]
}

struct IFCInstance {
    let id: String
    let type: String
    let parameters: [IFCParameter]
}

enum IFCParameter {
    case null
    case string(String)
    case integer(Int)
    case real(Double)
    case boolean(Bool)
    case reference(String)
    case enumeration(String)
    case array([IFCParameter])
}

struct SpatialHierarchy {
    let root: SpatialElement
}

class SpatialElement {
    let id: String
    let type: SpatialElementType
    let name: String
    var children: [SpatialElement]

    init(id: String, type: SpatialElementType, name: String, children: [SpatialElement]) {
        self.id = id
        self.type = type
        self.name = name
        self.children = children
    }
}

enum SpatialElementType {
    case project, site, building, storey, space
}

struct ParsedElement {
    let guid: String
    let type: String
    let name: String
    let discipline: Discipline
    let geometry: ElementGeometry?
    let properties: [String: Any]
}

struct ElementGeometry {
    let position: SIMD3<Float>
    let rotation: simd_quatf
    let scale: SIMD3<Float>
    let shape: Shape
}

enum Shape {
    case box(width: Float, height: Float, depth: Float)
    case cylinder(radius: Float, height: Float)
    case mesh(vertices: [SIMD3<Float>], indices: [UInt32])
}

struct ParsingResult {
    let header: IFCHeader
    let elements: [ParsedElement]
    let spatialStructure: SpatialHierarchy
    let properties: [String: [String: Any]]
    let errors: [ParsingError]
}

enum ParsingError: Error {
    case invalidInstanceFormat(line: String)
    case invalidInstanceID(line: String)
    case missingEntityType(line: String)
    case missingProject
    case instanceParsingFailed(line: String, error: Error)
    case elementExtractionFailed(id: String, error: Error)
}
