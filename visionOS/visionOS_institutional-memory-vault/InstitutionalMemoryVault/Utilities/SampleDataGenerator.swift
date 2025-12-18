//
//  SampleDataGenerator.swift
//  Institutional Memory Vault
//
//  Generates realistic sample data for testing and demos
//

import Foundation
import SwiftData

@MainActor
final class SampleDataGenerator {

    static func generateSampleData(modelContext: ModelContext) async throws {
        print("🌱 Generating sample data...")

        // Create organization
        let org = createOrganization()
        modelContext.insert(org)

        // Create departments
        let departments = createDepartments(organization: org)
        departments.forEach { modelContext.insert($0) }

        // Create employees
        let employees = createEmployees(departments: departments)
        employees.forEach { modelContext.insert($0) }

        // Create knowledge entities
        let knowledge = createKnowledgeEntities(departments: departments, employees: employees)
        knowledge.forEach { modelContext.insert($0) }

        // Create connections between knowledge
        let connections = createConnections(knowledge: knowledge, employees: employees)
        connections.forEach { modelContext.insert($0) }

        // Save everything
        try modelContext.save()

        print("✅ Sample data generated:")
        print("   - Organization: 1")
        print("   - Departments: \(departments.count)")
        print("   - Employees: \(employees.count)")
        print("   - Knowledge: \(knowledge.count)")
        print("   - Connections: \(connections.count)")
    }

    // MARK: - Organization

    private static func createOrganization() -> Organization {
        return Organization(
            name: "Acme Corporation",
            foundingDate: Calendar.current.date(byAdding: .year, value: -25, to: Date())!,
            culturalValues: [
                "Innovation",
                "Collaboration",
                "Customer Focus",
                "Integrity",
                "Excellence"
            ],
            strategicMilestones: [
                Milestone(
                    date: Calendar.current.date(byAdding: .year, value: -20, to: Date())!,
                    title: "Founded",
                    description: "Company established",
                    significance: 1.0
                ),
                Milestone(
                    date: Calendar.current.date(byAdding: .year, value: -15, to: Date())!,
                    title: "Series A Funding",
                    description: "$10M raised",
                    significance: 0.8
                ),
                Milestone(
                    date: Calendar.current.date(byAdding: .year, value: -10, to: Date())!,
                    title: "IPO",
                    description: "Public offering",
                    significance: 1.0
                ),
                Milestone(
                    date: Calendar.current.date(byAdding: .year, value: -5, to: Date())!,
                    title: "Global Expansion",
                    description: "Opened offices in 15 countries",
                    significance: 0.9
                )
            ]
        )
    }

    // MARK: - Departments

    private static func createDepartments(organization: Organization) -> [Department] {
        let deptNames = [
            "Executive Leadership",
            "Engineering",
            "Product",
            "Marketing",
            "Sales",
            "Operations",
            "Human Resources",
            "Finance"
        ]

        return deptNames.enumerated().map { index, name in
            Department(
                name: name,
                spatialLocation: SpatialCoordinate(
                    x: Float(cos(Float(index) * .pi / 4) * 3),
                    y: 0,
                    z: Float(sin(Float(index) * .pi / 4) * 3)
                )
            )
        }
    }

    // MARK: - Employees

    private static func createEmployees(departments: [Department]) -> [Employee] {
        let sampleEmployees: [(name: String, role: String, expertise: [String], deptIndex: Int)] = [
            // Executive
            ("Jane Chen", "CEO", ["Leadership", "Strategy", "Vision"], 0),
            ("Michael Torres", "CTO", ["Technology", "Architecture", "Innovation"], 0),

            // Engineering
            ("Sarah Kim", "Senior Engineer", ["iOS", "Swift", "visionOS"], 1),
            ("David Park", "Engineering Manager", ["Team Leadership", "Agile", "System Design"], 1),
            ("Lisa Wang", "Staff Engineer", ["Distributed Systems", "Backend", "Scalability"], 1),

            // Product
            ("James Rodriguez", "Product Manager", ["Product Strategy", "User Research", "Roadmapping"], 2),
            ("Emily Foster", "Senior PM", ["B2B", "Enterprise", "Product-Market Fit"], 2),

            // Marketing
            ("Robert Jackson", "CMO", ["Brand Strategy", "Growth Marketing", "Content"], 3),
            ("Maria Garcia", "Content Lead", ["Content Strategy", "SEO", "Community"], 3),

            // Sales
            ("Thomas Anderson", "VP Sales", ["Enterprise Sales", "Partnerships", "Revenue"], 4),
            ("Jennifer Lee", "Account Executive", ["B2B Sales", "Relationship Building"], 4),

            // Operations
            ("William Brown", "COO", ["Operations", "Process Optimization", "Efficiency"], 5),
            ("Amanda Martinez", "Operations Manager", ["Project Management", "Logistics"], 5),

            // HR
            ("Jessica Taylor", "VP People", ["Talent", "Culture", "Leadership Development"], 6),
            ("Christopher Davis", "Recruiter", ["Hiring", "Candidate Experience"], 6),

            // Finance
            ("Daniel Wilson", "CFO", ["Finance", "Strategy", "Fundraising"], 7),
            ("Nicole Thompson", "Financial Analyst", ["Financial Modeling", "Analysis"], 7)
        ]

        return sampleEmployees.map { emp in
            let startDate = Calendar.current.date(
                byAdding: .year,
                value: -Int.random(in: 1...10),
                to: Date()
            )!

            return Employee(
                name: emp.name,
                email: "\(emp.name.lowercased().replacingOccurrences(of: " ", with: "."))@acme.com",
                department: departments[emp.deptIndex],
                role: emp.role,
                expertiseAreas: emp.expertise,
                startDate: startDate,
                careerJourney: [
                    CareerMilestone(
                        date: startDate,
                        title: "Joined as \(emp.role)",
                        description: "Started at Acme Corporation",
                        department: departments[emp.deptIndex].name
                    )
                ]
            )
        }
    }

    // MARK: - Knowledge Entities

    private static func createKnowledgeEntities(
        departments: [Department],
        employees: [Employee]
    ) -> [KnowledgeEntity] {
        var knowledge: [KnowledgeEntity] = []

        // Decisions
        knowledge.append(contentsOf: [
            KnowledgeEntity(
                title: "Product Pivot Decision - 2019",
                content: "After analyzing market feedback and competitive landscape, we decided to pivot from B2C to B2B enterprise focus. This decision was driven by:\n\n1. Higher customer LTV in enterprise\n2. More predictable revenue\n3. Stronger product-market fit signals\n\n Result: 300% revenue growth over 2 years.",
                contentType: .decision,
                createdDate: date(yearsAgo: 5),
                author: employees.first { $0.role == "CEO" },
                department: departments[0],
                tags: ["strategy", "pivot", "enterprise"],
                accessLevel: .publicOrg
            ),
            KnowledgeEntity(
                title: "Remote-First Policy",
                content: "Decision to adopt remote-first work policy. Key considerations:\n- Employee satisfaction and retention\n- Access to global talent\n- Cost savings on office space\n- Async communication practices\n\nImplementation began March 2020.",
                contentType: .decision,
                createdDate: date(yearsAgo: 4),
                author: employees.first { $0.role == "VP People" },
                department: departments[6],
                tags: ["remote", "culture", "policy"],
                accessLevel: .publicOrg
            )
        ])

        // Expertise
        knowledge.append(contentsOf: [
            KnowledgeEntity(
                title: "visionOS Development Best Practices",
                content: "Key learnings from building spatial computing applications:\n\n## Architecture\n- Use MVVM with @Observable\n- SwiftData for persistence\n- Async/await throughout\n\n## Performance\n- Target 90 FPS minimum\n- LOD for 3D assets\n- Object pooling for repeated entities\n\n## UX\n- Content 10-15° below eye level\n- 60pt minimum hit targets\n- Progressive disclosure\n\nSee also: Apple HIG for visionOS",
                contentType: .expertise,
                createdDate: date(monthsAgo: 6),
                author: employees.first { $0.name == "Sarah Kim" },
                department: departments[1],
                tags: ["visionOS", "spatial computing", "best practices"],
                accessLevel: .publicOrg
            ),
            KnowledgeEntity(
                title: "Enterprise Sales Playbook",
                content: "Proven strategies for closing enterprise deals:\n\n1. **Discovery**: Understand pain points deeply\n2. **Champion Building**: Find internal advocates\n3. **Value Selling**: Demonstrate clear ROI\n4. **Multi-threading**: Build relationships across org\n5. **Legal & Security**: Address early\n\nAverage deal cycle: 6-9 months\nSuccess rate with this approach: 35%",
                contentType: .expertise,
                createdDate: date(monthsAgo: 12),
                author: employees.first { $0.role == "VP Sales" },
                department: departments[4],
                tags: ["sales", "enterprise", "playbook"],
                accessLevel: .department
            )
        ])

        // Processes
        knowledge.append(contentsOf: [
            KnowledgeEntity(
                title: "Product Development Lifecycle",
                content: "Our standard process for shipping features:\n\nPhase 1: Discovery (2 weeks)\n- User research\n- Competitive analysis\n- Requirements gathering\n\nPhase 2: Design (2 weeks)\n- Wireframes\n- Prototypes\n- User testing\n\nPhase 3: Development (4-6 weeks)\n- Sprint planning\n- Implementation\n- Code review\n\nPhase 4: Launch (1 week)\n- Beta testing\n- Documentation\n- Rollout\n\nPhase 5: Iteration\n- Metrics monitoring\n- User feedback\n- Improvements",
                contentType: .process,
                createdDate: date(monthsAgo: 18),
                author: employees.first { $0.role == "Product Manager" },
                department: departments[2],
                tags: ["process", "development", "lifecycle"],
                accessLevel: .publicOrg
            )
        ])

        // Stories
        knowledge.append(contentsOf: [
            KnowledgeEntity(
                title: "The All-Nighter That Saved the Launch",
                content: "Story from our Q4 2021 product launch:\n\nTwo days before launch, we discovered a critical bug that crashed the app for 20% of users. The team rallied:\n\n- Engineering pulled an all-nighter\n- Product delayed launch by 24 hours\n- Support prepared messaging\n\nBy morning, we had:\n- Bug fixed\n- Extra testing completed\n- Improved monitoring in place\n\nLesson: Always have a backup plan for launches. The 24-hour delay was better than a buggy release.\n\nTeam members involved: Sarah, David, Lisa, James",
                contentType: .story,
                createdDate: date(yearsAgo: 3),
                author: employees.first { $0.name == "David Park" },
                department: departments[1],
                tags: ["launch", "teamwork", "crisis"],
                accessLevel: .publicOrg
            )
        ])

        // Lessons
        knowledge.append(contentsOf: [
            KnowledgeEntity(
                title: "Failed Product Experiment: Consumer App",
                content: "Lessons from our failed B2C product (2018-2019):\n\n## What We Tried\n- Built consumer-facing mobile app\n- Invested $2M over 12 months\n- Acquired 50K users\n\n## Why It Failed\n- Poor retention (15% month-over-month)\n- High CAC, low LTV\n- Crowded market\n- Wrong team expertise\n\n## Key Learnings\n1. Validate assumptions with small experiments first\n2. Focus on our strengths (B2B)\n3. User acquisition is expensive in consumer\n4. Team expertise matters\n5. Know when to quit\n\n## What We Did Next\n- Pivoted to B2B enterprise\n- Leveraged existing relationships\n- Much better PMF\n\nThis \"failure\" led to our most successful product direction.",
                contentType: .lesson,
                createdDate: date(yearsAgo: 6),
                author: employees.first { $0.role == "CEO" },
                department: departments[0],
                tags: ["failure", "pivot", "learning"],
                accessLevel: .publicOrg
            )
        ])

        // Innovations
        knowledge.append(contentsOf: [
            KnowledgeEntity(
                title: "Spatial Computing Platform Innovation",
                content: "Our breakthrough approach to enterprise spatial computing:\n\n## Innovation\nFirst-to-market institutional memory platform for visionOS, transforming organizational knowledge into explorable 3D environments.\n\n## Technical Innovations\n- Force-directed knowledge graphs in 3D\n- Memory palace architecture\n- AI-powered semantic search\n- Real-time collaboration in spatial contexts\n\n## Business Impact\n- Created new market category\n- 10x faster knowledge discovery\n- Patent applications filed\n- Competitive moat established\n\n## Team\nCross-functional effort across Engineering, Product, and Design.\n\nDevelopment: 16 weeks from concept to MVP",
                contentType: .innovation,
                createdDate: date(monthsAgo: 3),
                author: employees.first { $0.role == "CTO" },
                department: departments[0],
                tags: ["innovation", "visionOS", "spatial computing", "platform"],
                accessLevel: .publicOrg
            )
        ])

        return knowledge
    }

    // MARK: - Connections

    private static func createConnections(
        knowledge: [KnowledgeEntity],
        employees: [Employee]
    ) -> [KnowledgeConnection] {
        var connections: [KnowledgeConnection] = []

        // Find specific knowledge items
        let pivotDecision = knowledge.first { $0.title.contains("Product Pivot") }
        let failedExperiment = knowledge.first { $0.title.contains("Failed Product") }
        let salesPlaybook = knowledge.first { $0.title.contains("Sales Playbook") }
        let visionOSBestPractices = knowledge.first { $0.title.contains("visionOS") }
        let spatialInnovation = knowledge.first { $0.title.contains("Spatial Computing Platform") }

        // Pivot decision caused by failed experiment
        if let pivot = pivotDecision, let failed = failedExperiment {
            connections.append(KnowledgeConnection(
                sourceEntity: failed,
                targetEntity: pivot,
                connectionType: .causedBy,
                strength: 1.0,
                context: "Failed B2C experiment led directly to B2B pivot decision"
            ))
        }

        // Sales playbook supports pivot decision
        if let sales = salesPlaybook, let pivot = pivotDecision {
            connections.append(KnowledgeConnection(
                sourceEntity: sales,
                targetEntity: pivot,
                connectionType: .supports,
                strength: 0.8,
                context: "Enterprise sales playbook developed to execute on pivot"
            ))
        }

        // visionOS best practices prerequisite for spatial innovation
        if let practices = visionOSBestPractices, let innovation = spatialInnovation {
            connections.append(KnowledgeConnection(
                sourceEntity: practices,
                targetEntity: innovation,
                connectionType: .prerequisiteFor,
                strength: 0.9,
                context: "Technical expertise enabled platform innovation"
            ))
        }

        // Add some general "related to" connections
        for i in 0..<knowledge.count {
            for j in (i+1)..<min(i+3, knowledge.count) {
                if Int.random(in: 0...2) == 0 {
                    connections.append(KnowledgeConnection(
                        sourceEntity: knowledge[i],
                        targetEntity: knowledge[j],
                        connectionType: .relatedTo,
                        strength: Float.random(in: 0.3...0.7),
                        context: "Related topics"
                    ))
                }
            }
        }

        return connections
    }

    // MARK: - Helper Functions

    private static func date(yearsAgo: Int) -> Date {
        Calendar.current.date(byAdding: .year, value: -yearsAgo, to: Date())!
    }

    private static func date(monthsAgo: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: -monthsAgo, to: Date())!
    }
}
