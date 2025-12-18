//
//  FileNavigationManager.swift
//  SpatialCodeReviewer
//
//  Created by Claude on 2025-11-24.
//  Story 0.8: File Navigation
//

import RealityKit
import SwiftUI

/// Manages file tree navigation, expansion/collapse, and search
@MainActor
class FileNavigationManager: ObservableObject {

    // MARK: - Published State

    @Published var expandedDirectories: Set<String> = []
    @Published var searchQuery: String = ""
    @Published var filteredNodes: [FileNode] = []
    @Published var breadcrumbs: [String] = []

    // MARK: - Private Properties

    private var allNodes: [FileNode] = []
    private var nodeMap: [String: FileNode] = [:]

    // MARK: - Initialization

    func loadFileTree(_ rootNode: FileNode) {
        allNodes = flattenFileTree(rootNode)
        buildNodeMap()
        updateFilteredNodes()
    }

    // MARK: - Directory Expansion

    /// Toggles expansion state of a directory
    func toggleDirectory(_ path: String) {
        if expandedDirectories.contains(path) {
            // Collapse
            expandedDirectories.remove(path)
            print("📁 Collapsed: \(path)")
        } else {
            // Expand
            expandedDirectories.insert(path)
            print("📂 Expanded: \(path)")
        }

        updateFilteredNodes()
    }

    /// Checks if a directory is expanded
    func isExpanded(_ path: String) -> Bool {
        return expandedDirectories.contains(path)
    }

    /// Expands all ancestor directories of a given path
    func expandPathTo(_ targetPath: String) {
        let components = targetPath.components(separatedBy: "/")
        var currentPath = ""

        for component in components.dropLast() {
            currentPath += (currentPath.isEmpty ? "" : "/") + component
            expandedDirectories.insert(currentPath)
        }

        updateFilteredNodes()
    }

    // MARK: - Search

    /// Updates search query and filters nodes
    func updateSearch(_ query: String) {
        searchQuery = query
        updateFilteredNodes()

        // Auto-expand directories containing matches
        if !query.isEmpty {
            autoExpandMatches()
        }
    }

    /// Clears search and resets to normal view
    func clearSearch() {
        searchQuery = ""
        updateFilteredNodes()
    }

    // MARK: - Visible Nodes

    /// Returns list of nodes that should be visible based on expansion and search
    func getVisibleNodes() -> [FileNode] {
        return filteredNodes
    }

    /// Returns depth level of a node for indentation
    func getDepthLevel(_ node: FileNode) -> Int {
        return node.path.components(separatedBy: "/").count - 1
    }

    // MARK: - Private Methods

    private func flattenFileTree(_ node: FileNode) -> [FileNode] {
        var result: [FileNode] = [node]

        if let children = node.children {
            for child in children {
                result.append(contentsOf: flattenFileTree(child))
            }
        }

        return result
    }

    private func buildNodeMap() {
        nodeMap.removeAll()
        for node in allNodes {
            nodeMap[node.path] = node
        }
    }

    private func updateFilteredNodes() {
        if searchQuery.isEmpty {
            // No search: show based on expansion state
            filteredNodes = getVisibleNodesFromExpansion()
        } else {
            // Search active: show matching nodes and their ancestors
            filteredNodes = getMatchingNodes()
        }

        print("📊 Visible nodes: \(filteredNodes.count)")
    }

    private func getVisibleNodesFromExpansion() -> [FileNode] {
        guard let root = allNodes.first else { return [] }
        return getVisibleNodesRecursive(root, parentPath: "")
    }

    private func getVisibleNodesRecursive(_ node: FileNode, parentPath: String) -> [FileNode] {
        var result: [FileNode] = [node]

        // If this is an expanded directory, include its children
        if node.isDirectory && expandedDirectories.contains(node.path) {
            if let children = node.children {
                for child in children.sorted(by: { $0.name < $1.name }) {
                    result.append(contentsOf: getVisibleNodesRecursive(child, parentPath: node.path))
                }
            }
        }

        return result
    }

    private func getMatchingNodes() -> [FileNode] {
        let query = searchQuery.lowercased()
        var matches: [FileNode] = []

        for node in allNodes {
            if node.name.lowercased().contains(query) {
                matches.append(node)
            }
        }

        return matches.sorted { $0.path < $1.path }
    }

    private func autoExpandMatches() {
        let query = searchQuery.lowercased()

        for node in allNodes {
            if node.name.lowercased().contains(query) {
                // Expand all ancestors
                expandPathTo(node.path)
            }
        }
    }

    // MARK: - Breadcrumb Navigation

    /// Updates breadcrumb trail for current directory
    func updateBreadcrumbs(for path: String) {
        breadcrumbs = path.components(separatedBy: "/").filter { !$0.isEmpty }
    }

    /// Navigates to a breadcrumb level
    func navigateToBreadcrumb(at index: Int) {
        guard index < breadcrumbs.count else { return }

        let targetPath = breadcrumbs[0...index].joined(separator: "/")

        // Collapse all directories deeper than target
        let pathsToCollapse = expandedDirectories.filter { path in
            path.hasPrefix(targetPath) && path != targetPath
        }

        for path in pathsToCollapse {
            expandedDirectories.remove(path)
        }

        updateFilteredNodes()
        updateBreadcrumbs(for: targetPath)
    }
}

// MARK: - Nested Layout Algorithm

/// Layout algorithm for hierarchical nested file display
class NestedLayout {
    let indentSpacing: Float = 0.15  // 15cm per level
    let verticalSpacing: Float = 0.25 // 25cm between items
    let basePosition = SIMD3<Float>(0, 1.5, -2)

    /// Calculates positions for nested file tree
    func calculatePositions(for nodes: [FileNode], navigationManager: FileNavigationManager) -> [(node: FileNode, transform: Transform)] {
        var result: [(node: FileNode, transform: Transform)] = []
        var yOffset: Float = 0

        for node in nodes {
            let depth = navigationManager.getDepthLevel(node)
            let xOffset = Float(depth) * indentSpacing

            let position = basePosition + SIMD3<Float>(xOffset, yOffset, 0)

            result.append((
                node: node,
                transform: Transform(
                    scale: [1, 1, 1],
                    translation: position
                )
            ))

            yOffset -= verticalSpacing
        }

        return result
    }
}

// MARK: - Enhanced CodeWindowComponent

extension CodeWindowComponent {
    /// Indicates if this is an expanded directory
    var isExpanded: Bool {
        get { isDirectory }
        set { /* Stored elsewhere in FileNavigationManager */ }
    }
}

// MARK: - Search View Model

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var isSearching: Bool = false

    weak var navigationManager: FileNavigationManager?

    func updateSearch() {
        navigationManager?.updateSearch(searchText)
    }

    func clearSearch() {
        searchText = ""
        navigationManager?.clearSearch()
        isSearching = false
    }
}
