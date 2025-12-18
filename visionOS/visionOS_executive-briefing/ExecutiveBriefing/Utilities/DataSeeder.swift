import Foundation
import SwiftData
import OSLog

/// Seeds the database with initial briefing content
actor DataSeeder {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ExecutiveBriefing", category: "DataSeeder")

    enum SeedingError: Error, LocalizedError {
        case alreadySeeded
        case parsingFailed(Error)
        case saveFailed(Error)

        var errorDescription: String? {
            switch self {
            case .alreadySeeded:
                return "Database already contains data"
            case .parsingFailed(let error):
                return "Failed to parse content: \(error.localizedDescription)"
            case .saveFailed(let error):
                return "Failed to save data: \(error.localizedDescription)"
            }
        }
    }

    /// Seed the database with briefing content
    /// - Parameters:
    ///   - modelContext: SwiftData model context
    ///   - force: Force reseed even if data exists
    func seedInitialData(modelContext: ModelContext, force: Bool = false) async throws {
        logger.info("Starting data seeding process...")

        // Check if already seeded
        unless force {
            let descriptor = FetchDescriptor<BriefingSection>()
            let existingSections = try modelContext.fetch(descriptor)

            if !existingSections.isEmpty {
                logger.info("Database already seeded with \(existingSections.count) sections")
                throw SeedingError.alreadySeeded
            }
        }

        do {
            // Parse markdown content
            logger.info("Parsing markdown content...")
            let parser = MarkdownParser()
            let sectionDataList = try await parser.parseBriefing(from: "Executive-Briefing-AR-VR-2025")

            logger.info("Parsed \(sectionDataList.count) sections")

            // Convert to SwiftData models and insert
            for sectionData in sectionDataList {
                let section = createBriefingSection(from: sectionData)
                modelContext.insert(section)
            }

            // Create sample use cases
            logger.info("Creating use cases...")
            let useCases = createUseCases()
            for useCase in useCases {
                modelContext.insert(useCase)
            }

            // Create sample action items
            logger.info("Creating action items...")
            let actionItems = createActionItems()
            for item in actionItems {
                modelContext.insert(item)
            }

            // Create investment phases
            logger.info("Creating investment phases...")
            let phases = createInvestmentPhases()
            for phase in phases {
                modelContext.insert(phase)
            }

            // Create user progress
            logger.info("Creating user progress...")
            let progress = UserProgress()
            modelContext.insert(progress)

            // Save all changes
            logger.info("Saving to database...")
            try modelContext.save()

            logger.info("✅ Data seeding completed successfully")
        } catch let error as MarkdownParser.ParsingError {
            logger.error("❌ Parsing failed: \(error.localizedDescription)")
            throw SeedingError.parsingFailed(error)
        } catch {
            logger.error("❌ Save failed: \(error.localizedDescription)")
            throw SeedingError.saveFailed(error)
        }
    }

    /// Create BriefingSection model from parsed data
    private func createBriefingSection(from data: BriefingSectionData) -> BriefingSection {
        let contentBlocks = data.content.map { blockData in
            ContentBlock(
                type: blockData.type,
                content: blockData.content,
                metadata: blockData.metadata,
                order: blockData.order
            )
        }

        return BriefingSection(
            title: data.title,
            order: data.order,
            icon: data.icon,
            content: contentBlocks,
            visualizationType: data.visualizationType
        )
    }

    /// Create sample use cases with ROI data
    private func createUseCases() -> [UseCase] {
        return [
            UseCase(
                title: "Remote Expert Assistance",
                roi: 400,
                timeframe: "12 months",
                metrics: [
                    Metric(label: "Travel cost reduction", value: "67%", trend: .down),
                    Metric(label: "Problem resolution speed", value: "50%", trend: .up)
                ],
                example: "Mercedes-Benz reduced service time by 40% using HoloLens",
                category: "Field Service",
                order: 0
            ),
            UseCase(
                title: "Immersive Training & Simulation",
                roi: 350,
                timeframe: "18 months",
                metrics: [
                    Metric(label: "Training time reduction", value: "75%", trend: .down),
                    Metric(label: "Knowledge retention", value: "40%", trend: .up)
                ],
                example: "Walmart trained 1M+ employees with 30% higher satisfaction",
                category: "Training",
                order: 1
            ),
            UseCase(
                title: "Surgical Planning & Guidance",
                roi: 250,
                timeframe: "24 months",
                metrics: [
                    Metric(label: "OR time reduction", value: "25%", trend: .down),
                    Metric(label: "Complication reduction", value: "15%", trend: .down)
                ],
                example: "Johns Hopkins reduced surgery time by 30% with AR guidance",
                category: "Healthcare",
                order: 2
            ),
            UseCase(
                title: "Virtual Showrooms & Try-Before-Buy",
                roi: 300,
                timeframe: "12 months",
                metrics: [
                    Metric(label: "Conversion rate increase", value: "3x", trend: .up),
                    Metric(label: "Return reduction", value: "64%", trend: .down)
                ],
                example: "IKEA Place drives 5x higher purchase intent",
                category: "Retail",
                order: 3
            ),
            UseCase(
                title: "Collaborative Design Review",
                roi: 200,
                timeframe: "18 months",
                metrics: [
                    Metric(label: "Design cycle reduction", value: "65%", trend: .down),
                    Metric(label: "Rework reduction", value: "50%", trend: .down)
                ],
                example: "Ford reduced design time from months to weeks",
                category: "Manufacturing",
                order: 4
            ),
            UseCase(
                title: "Field Service Optimization",
                roi: 450,
                timeframe: "12 months",
                metrics: [
                    Metric(label: "First-time fix rate", value: "90%", trend: .up),
                    Metric(label: "Productivity gain", value: "30%", trend: .up)
                ],
                example: "Thyssenkrupp elevator service efficiency up 4x",
                category: "Field Service",
                order: 5
            ),
            UseCase(
                title: "Virtual Real Estate Tours",
                roi: 275,
                timeframe: "12 months",
                metrics: [
                    Metric(label: "Physical showing reduction", value: "40%", trend: .down),
                    Metric(label: "Sales speed increase", value: "25%", trend: .up)
                ],
                example: "Sotheby's increased international sales by 35%",
                category: "Real Estate",
                order: 6
            ),
            UseCase(
                title: "Mental Health Therapy",
                roi: 200,
                timeframe: "24 months",
                metrics: [
                    Metric(label: "Treatment effectiveness", value: "60%", trend: .up),
                    Metric(label: "Patient satisfaction", value: "85%", trend: .stable)
                ],
                example: "Oxford VR treating 10,000+ patients successfully",
                category: "Healthcare",
                order: 7
            ),
            UseCase(
                title: "Data Center Visualization",
                roi: 350,
                timeframe: "12 months",
                metrics: [
                    Metric(label: "Issue identification speed", value: "50%", trend: .up),
                    Metric(label: "Error reduction", value: "30%", trend: .down)
                ],
                example: "Microsoft reduced incidents by 40% with AR",
                category: "IT Operations",
                order: 8
            ),
            UseCase(
                title: "Manufacturing Assembly Guidance",
                roi: 300,
                timeframe: "12 months",
                metrics: [
                    Metric(label: "Assembly error reduction", value: "90%", trend: .down),
                    Metric(label: "Training time reduction", value: "25%", trend: .down)
                ],
                example: "Boeing cut wiring time by 25% with AR instructions",
                category: "Manufacturing",
                order: 9
            )
        ]
    }

    /// Create action items for each executive role
    private func createActionItems() -> [ActionItem] {
        return [
            // CEO
            ActionItem(
                role: .ceo,
                title: "Announce AR/VR as strategic priority",
                descriptionText: "Make public announcement at next all-hands or board meeting",
                priority: 1,
                order: 0
            ),
            ActionItem(
                role: .ceo,
                title: "Allocate 2-5% of innovation budget",
                descriptionText: "Commit budget for AR/VR initiatives in next fiscal year",
                priority: 2,
                order: 1
            ),
            ActionItem(
                role: .ceo,
                title: "Appoint executive sponsor",
                descriptionText: "Designate C-level leader to champion AR/VR strategy",
                priority: 1,
                order: 2
            ),

            // CFO
            ActionItem(
                role: .cfo,
                title: "Develop AR/VR investment thesis",
                descriptionText: "Create financial model and ROI projections",
                priority: 1,
                order: 0
            ),
            ActionItem(
                role: .cfo,
                title: "Create new ROI metrics",
                descriptionText: "Define success metrics specific to AR/VR initiatives",
                priority: 2,
                order: 1
            ),
            ActionItem(
                role: .cfo,
                title: "Budget for multi-year journey",
                descriptionText: "Plan phased investment across 3-5 years",
                priority: 2,
                order: 2
            ),

            // CTO/CIO
            ActionItem(
                role: .cto,
                title: "Assess technical readiness",
                descriptionText: "Evaluate current infrastructure and skill gaps",
                priority: 1,
                order: 0
            ),
            ActionItem(
                role: .cto,
                title: "Build security framework",
                descriptionText: "Define security and privacy requirements for AR/VR",
                priority: 1,
                order: 1
            ),
            ActionItem(
                role: .cto,
                title: "Evaluate platform options",
                descriptionText: "Compare HoloLens, Meta Quest, Vision Pro, and others",
                priority: 2,
                order: 2
            ),

            // CHRO
            ActionItem(
                role: .chro,
                title: "Plan workforce transformation",
                descriptionText: "Identify training needs and new roles",
                priority: 2,
                order: 0
            ),
            ActionItem(
                role: .chro,
                title: "Address cultural resistance",
                descriptionText: "Develop change management strategy",
                priority: 2,
                order: 1
            ),
            ActionItem(
                role: .chro,
                title: "Develop training programs",
                descriptionText: "Create AR/VR skills development curriculum",
                priority: 3,
                order: 2
            ),

            // CMO
            ActionItem(
                role: .cmo,
                title: "Explore customer experiences",
                descriptionText: "Pilot AR/VR customer touchpoints",
                priority: 2,
                order: 0
            ),
            ActionItem(
                role: .cmo,
                title: "Test virtual showrooms",
                descriptionText: "Create proof-of-concept virtual product experiences",
                priority: 3,
                order: 1
            ),
            ActionItem(
                role: .cmo,
                title: "Plan PR strategy",
                descriptionText: "Communicate AR/VR innovation to market",
                priority: 3,
                order: 2
            ),

            // Legal
            ActionItem(
                role: .legal,
                title: "Review liability frameworks",
                descriptionText: "Assess legal risks and compliance requirements",
                priority: 1,
                order: 0
            ),
            ActionItem(
                role: .legal,
                title: "Update privacy policies",
                descriptionText: "Address biometric data and user tracking",
                priority: 1,
                order: 1
            ),
            ActionItem(
                role: .legal,
                title: "Develop vendor contracts",
                descriptionText: "Create standard agreements for AR/VR vendors",
                priority: 2,
                order: 2
            )
        ]
    }

    /// Create investment phases
    private func createInvestmentPhases() -> [InvestmentPhase] {
        return [
            InvestmentPhase(
                name: "Foundation",
                timeline: "Q1-Q2 2025",
                budgetMin: 2000,
                budgetMax: 5000,
                checklist: [
                    ChecklistItem(task: "Establish innovation lab", priority: 1),
                    ChecklistItem(task: "Recruit AR/VR leadership", priority: 1),
                    ChecklistItem(task: "Launch 3-5 pilot programs", priority: 2),
                    ChecklistItem(task: "Develop governance framework", priority: 2)
                ],
                order: 0,
                descriptionText: "Build foundational capabilities and launch initial pilots"
            ),
            InvestmentPhase(
                name: "Scaling",
                timeline: "Q3-Q4 2025",
                budgetMin: 5000,
                budgetMax: 15000,
                checklist: [
                    ChecklistItem(task: "Deploy successful pilots", priority: 1),
                    ChecklistItem(task: "Build internal capabilities", priority: 1),
                    ChecklistItem(task: "Expand to 3 business units", priority: 2),
                    ChecklistItem(task: "Measure and optimize ROI", priority: 2)
                ],
                order: 1,
                descriptionText: "Scale successful initiatives across organization"
            ),
            InvestmentPhase(
                name: "Transformation",
                timeline: "2026+",
                budgetMin: 15000,
                budgetMax: 50000,
                checklist: [
                    ChecklistItem(task: "Enterprise-wide rollout", priority: 1),
                    ChecklistItem(task: "Custom platform development", priority: 2),
                    ChecklistItem(task: "Ecosystem partnerships", priority: 2),
                    ChecklistItem(task: "Market leadership position", priority: 3)
                ],
                order: 2,
                descriptionText: "Achieve enterprise-wide adoption and market leadership"
            )
        ]
    }
}
