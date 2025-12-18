# Dependency Graph Algorithms Design Document

## Document Information
- **Version**: 1.0
- **Last Updated**: 2025-11-24
- **Status**: Draft
- **Owner**: Engineering Team

## 1. Overview

This document specifies the algorithms for building, analyzing, and visualizing code dependency graphs in 3D space.

## 2. Graph Data Structure

### 2.1 Graph Model

```swift
struct DependencyGraph {
    var nodes: [Node]
    var edges: [Edge]

    struct Node {
        let id: UUID
        let filePath: String
        let symbolCount: Int
        let language: Language
        var position: SIMD2<Float> // For layout
    }

    struct Edge {
        let id: UUID
        let source: Int // Node index
        let target: Int // Node index
        let type: DependencyType
        let weight: Float // Strength of dependency
    }
}
```

## 3. Graph Construction

### 3.1 Building the Graph

```swift
class DependencyGraphBuilder {
    func buildGraph(from parseResults: [ParseResult]) -> DependencyGraph {
        var nodes: [DependencyGraph.Node] = []
        var edges: [DependencyGraph.Edge] = []

        // Create nodes for each file
        for result in parseResults {
            nodes.append(DependencyGraph.Node(
                id: UUID(),
                filePath: result.file.path,
                symbolCount: result.symbols.count,
                language: Language.detect(from: result.file.path),
                position: .zero
            ))
        }

        // Create edges from dependencies
        for (sourceIndex, result) in parseResults.enumerated() {
            for dependency in result.dependencies {
                if let targetIndex = findNodeIndex(
                    for: dependency.targetFile,
                    in: nodes
                ) {
                    edges.append(DependencyGraph.Edge(
                        id: UUID(),
                        source: sourceIndex,
                        target: targetIndex,
                        type: dependency.type,
                        weight: 1.0
                    ))
                }
            }
        }

        return DependencyGraph(nodes: nodes, edges: edges)
    }
}
```

## 4. Layout Algorithms

### 4.1 Force-Directed Layout

```swift
class ForceDirectedLayout {
    let iterations: Int = 50
    let k: Float // Optimal distance
    let temperature: Float = 1.0

    func layout(graph: DependencyGraph) -> [SIMD2<Float>] {
        var positions = initializeRandomPositions(nodeCount: graph.nodes.count)

        for iteration in 0..<iterations {
            var forces = calculateForces(graph: graph, positions: positions)
            let temp = temperature * Float(iterations - iteration) / Float(iterations)

            // Apply forces
            for i in 0..<positions.count {
                let displacement = forces[i] * temp
                positions[i] += displacement

                // Keep within bounds
                positions[i].x = max(-5, min(5, positions[i].x))
                positions[i].y = max(-5, min(5, positions[i].y))
            }
        }

        return positions
    }

    private func calculateForces(
        graph: DependencyGraph,
        positions: [SIMD2<Float>]
    ) -> [SIMD2<Float>] {
        var forces = [SIMD2<Float>](repeating: .zero, count: positions.count)

        // Repulsive forces between all nodes
        for i in 0..<positions.count {
            for j in 0..<positions.count where i != j {
                let delta = positions[i] - positions[j]
                let distance = max(length(delta), 0.1)
                let repulsion = (k * k) / distance
                forces[i] += normalize(delta) * repulsion
            }
        }

        // Attractive forces along edges
        for edge in graph.edges {
            let delta = positions[edge.target] - positions[edge.source]
            let distance = length(delta)
            let attraction = (distance * distance) / k * edge.weight
            let force = normalize(delta) * attraction

            forces[edge.source] += force
            forces[edge.target] -= force
        }

        return forces
    }
}
```

### 4.2 Hierarchical Layout

```swift
class HierarchicalLayout {
    func layout(graph: DependencyGraph) -> [SIMD2<Float>] {
        // 1. Detect layers using topological sort
        let layers = detectLayers(graph: graph)

        // 2. Position nodes by layer
        var positions = [SIMD2<Float>](
            repeating: .zero,
            count: graph.nodes.count
        )

        for (layerIndex, layer) in layers.enumerated() {
            let y = Float(layerIndex) * 2.0
            let spacing = 1.5

            for (indexInLayer, nodeIndex) in layer.enumerated() {
                let x = Float(indexInLayer - layer.count / 2) * spacing
                positions[nodeIndex] = SIMD2<Float>(x, y)
            }
        }

        // 3. Minimize edge crossings
        minimizeCrossings(&positions, graph: graph, layers: layers)

        return positions
    }

    private func detectLayers(graph: DependencyGraph) -> [[Int]] {
        // Topological sort with layer assignment
        var inDegree = [Int](repeating: 0, count: graph.nodes.count)
        var layers: [[Int]] = []

        // Calculate in-degrees
        for edge in graph.edges {
            inDegree[edge.target] += 1
        }

        // Process nodes layer by layer
        var remaining = Set(0..<graph.nodes.count)

        while !remaining.isEmpty {
            // Find nodes with zero in-degree
            let currentLayer = remaining.filter { inDegree[$0] == 0 }

            if currentLayer.isEmpty {
                // Circular dependency - break arbitrarily
                break
            }

            layers.append(Array(currentLayer))

            // Remove processed nodes
            for node in currentLayer {
                remaining.remove(node)

                // Decrease in-degree of neighbors
                for edge in graph.edges where edge.source == node {
                    inDegree[edge.target] -= 1
                }
            }
        }

        return layers
    }
}
```

## 5. Circular Dependency Detection

### 5.1 Tarjan's Algorithm

```swift
class CircularDependencyDetector {
    func detectCycles(in graph: DependencyGraph) -> [[Int]] {
        var index = 0
        var stack: [Int] = []
        var indices = [Int?](repeating: nil, count: graph.nodes.count)
        var lowLinks = [Int](repeating: 0, count: graph.nodes.count)
        var onStack = [Bool](repeating: false, count: graph.nodes.count)
        var cycles: [[Int]] = []

        for node in 0..<graph.nodes.count {
            if indices[node] == nil {
                strongConnect(
                    node,
                    graph: graph,
                    index: &index,
                    stack: &stack,
                    indices: &indices,
                    lowLinks: &lowLinks,
                    onStack: &onStack,
                    cycles: &cycles
                )
            }
        }

        return cycles.filter { $0.count > 1 } // Only actual cycles
    }

    private func strongConnect(
        _ node: Int,
        graph: DependencyGraph,
        index: inout Int,
        stack: inout [Int],
        indices: inout [Int?],
        lowLinks: inout [Int],
        onStack: inout [Bool],
        cycles: inout [[Int]]
    ) {
        indices[node] = index
        lowLinks[node] = index
        index += 1
        stack.append(node)
        onStack[node] = true

        // Consider successors
        for edge in graph.edges where edge.source == node {
            let successor = edge.target

            if indices[successor] == nil {
                strongConnect(
                    successor,
                    graph: graph,
                    index: &index,
                    stack: &stack,
                    indices: &indices,
                    lowLinks: &lowLinks,
                    onStack: &onStack,
                    cycles: &cycles
                )
                lowLinks[node] = min(lowLinks[node], lowLinks[successor])
            } else if onStack[successor] {
                lowLinks[node] = min(lowLinks[node], indices[successor]!)
            }
        }

        // If node is a root, pop cycle
        if lowLinks[node] == indices[node]! {
            var cycle: [Int] = []
            var w: Int

            repeat {
                w = stack.removeLast()
                onStack[w] = false
                cycle.append(w)
            } while w != node

            cycles.append(cycle)
        }
    }
}
```

## 6. Graph Simplification

### 6.1 Transitive Reduction

```swift
class GraphSimplifier {
    func reduceTransitiveEdges(graph: DependencyGraph) -> DependencyGraph {
        var simplified = graph

        // For each edge, check if there's an alternative path
        var edgesToRemove: Set<UUID> = []

        for edge in graph.edges {
            if hasAlternativePath(
                from: edge.source,
                to: edge.target,
                excluding: edge,
                in: graph
            ) {
                edgesToRemove.insert(edge.id)
            }
        }

        simplified.edges.removeAll { edgesToRemove.contains($0.id) }
        return simplified
    }

    private func hasAlternativePath(
        from source: Int,
        to target: Int,
        excluding edge: DependencyGraph.Edge,
        in graph: DependencyGraph
    ) -> Bool {
        // BFS to find alternative path
        var visited = Set<Int>()
        var queue = [source]
        visited.insert(source)

        while !queue.isEmpty {
            let current = queue.removeFirst()

            if current == target {
                return true
            }

            for e in graph.edges where e.source == current && e.id != edge.id {
                if !visited.contains(e.target) {
                    visited.insert(e.target)
                    queue.append(e.target)
                }
            }
        }

        return false
    }
}
```

## 7. Graph Metrics

### 7.1 Centrality Measures

```swift
class GraphMetrics {
    func calculateBetweennessCentrality(graph: DependencyGraph) -> [Float] {
        // Implementation of Brandes' algorithm
        // Returns centrality score for each node
        return []
    }

    func calculatePageRank(graph: DependencyGraph, iterations: Int = 20) -> [Float] {
        let dampingFactor: Float = 0.85
        let nodeCount = graph.nodes.count
        var ranks = [Float](repeating: 1.0 / Float(nodeCount), count: nodeCount)

        for _ in 0..<iterations {
            var newRanks = [Float](repeating: (1.0 - dampingFactor) / Float(nodeCount), count: nodeCount)

            for edge in graph.edges {
                let outDegree = graph.edges.filter { $0.source == edge.source }.count
                if outDegree > 0 {
                    newRanks[edge.target] += dampingFactor * ranks[edge.source] / Float(outDegree)
                }
            }

            ranks = newRanks
        }

        return ranks
    }
}
```

## 8. References

- [System Architecture Document](./01-system-architecture.md)
- [3D Rendering & Spatial Layout](./03-spatial-rendering.md)

## 9. Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-24 | Engineering Team | Initial draft |
