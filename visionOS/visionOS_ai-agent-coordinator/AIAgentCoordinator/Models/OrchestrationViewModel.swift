//
//  OrchestrationViewModel.swift
//  AIAgentCoordinator
//
//  Created by AI Agent Coordinator on 2025-01-20.
//

import Foundation
import Observation

/// ViewModel for workflow orchestration and automation
/// Manages agent workflows, triggers, and automation rules
@Observable
@MainActor
final class OrchestrationViewModel {

    // MARK: - Properties

    /// Agent coordinator
    private let coordinator: AgentCoordinator

    /// Performance view model for metrics
    private let performanceViewModel: PerformanceViewModel

    /// Active workflows
    private(set) var workflows: [Workflow] = []

    /// Workflow execution history
    private(set) var executionHistory: [WorkflowExecution] = []

    /// Automation rules
    private(set) var automationRules: [AutomationRule] = []

    /// Is orchestration engine running
    private(set) var isRunning = false

    /// Orchestration task
    private var orchestrationTask: Task<Void, Never>?

    /// Error state
    private(set) var error: Error?

    // MARK: - Initialization

    init(coordinator: AgentCoordinator, performanceViewModel: PerformanceViewModel) {
        self.coordinator = coordinator
        self.performanceViewModel = performanceViewModel
        loadDefaultWorkflows()
        loadDefaultRules()
    }

    convenience init() {
        self.init(
            coordinator: AgentCoordinator(),
            performanceViewModel: PerformanceViewModel()
        )
    }

    // MARK: - Lifecycle

    /// Start orchestration engine
    func start() {
        guard !isRunning else { return }

        isRunning = true
        orchestrationTask = Task {
            await runOrchestrationLoop()
        }
    }

    /// Stop orchestration engine
    func stop() {
        isRunning = false
        orchestrationTask?.cancel()
        orchestrationTask = nil
    }

    // MARK: - Orchestration Loop

    /// Main orchestration loop - checks rules and executes workflows
    private func runOrchestrationLoop() async {
        while !Task.isCancelled {
            // Check automation rules
            await checkAutomationRules()

            // Process scheduled workflows
            await processScheduledWorkflows()

            // Sleep for 5 seconds
            try? await Task.sleep(for: .seconds(5))
        }
    }

    /// Check automation rules and trigger workflows
    private func checkAutomationRules() async {
        for rule in automationRules where rule.isEnabled {
            if await shouldTriggerRule(rule) {
                await executeWorkflow(rule.workflowId)
            }
        }
    }

    /// Check if a rule should trigger
    private func shouldTriggerRule(_ rule: AutomationRule) async -> Bool {
        switch rule.trigger {
        case .highCPU(let threshold):
            let metrics = performanceViewModel.aggregateMetrics
            return metrics.totalCPU > threshold

        case .highMemory(let threshold):
            let metrics = performanceViewModel.aggregateMetrics
            return metrics.totalMemoryMB > threshold

        case .highErrorRate(let threshold):
            let metrics = performanceViewModel.aggregateMetrics
            return metrics.totalErrorRate > threshold

        case .agentFailed(let agentId):
            if let agent = coordinator.agents.first(where: { $0.id == agentId }) {
                return agent.status == .error
            }
            return false

        case .schedule(let cronExpression):
            // Simplified - would use proper cron parser in production
            return false

        case .custom:
            return false
        }
    }

    /// Process scheduled workflows
    private func processScheduledWorkflows() async {
        let now = Date()

        for workflow in workflows where workflow.isEnabled {
            // Check if workflow should run based on schedule
            if let lastRun = workflow.lastExecutionDate {
                let interval = now.timeIntervalSince(lastRun)
                if interval >= workflow.scheduleInterval {
                    await executeWorkflow(workflow.id)
                }
            }
        }
    }

    // MARK: - Workflow Management

    /// Execute a workflow
    func executeWorkflow(_ workflowId: UUID) async {
        guard let workflow = workflows.first(where: { $0.id == workflowId }) else {
            return
        }

        let execution = WorkflowExecution(
            id: UUID(),
            workflowId: workflow.id,
            workflowName: workflow.name,
            startTime: Date(),
            status: .running
        )

        executionHistory.append(execution)

        // Execute steps
        var completedSteps = 0

        for step in workflow.steps {
            do {
                try await executeStep(step)
                completedSteps += 1
            } catch {
                // Mark execution as failed
                if let index = executionHistory.firstIndex(where: { $0.id == execution.id }) {
                    executionHistory[index].status = .failed
                    executionHistory[index].endTime = Date()
                    executionHistory[index].error = error.localizedDescription
                }
                return
            }
        }

        // Mark execution as completed
        if let index = executionHistory.firstIndex(where: { $0.id == execution.id }) {
            executionHistory[index].status = .completed
            executionHistory[index].endTime = Date()
            executionHistory[index].stepsCompleted = completedSteps
        }

        // Update workflow last execution
        if let index = workflows.firstIndex(where: { $0.id == workflowId }) {
            workflows[index].lastExecutionDate = Date()
            workflows[index].executionCount += 1
        }
    }

    /// Execute a single workflow step
    private func executeStep(_ step: WorkflowStep) async throws {
        switch step.action {
        case .startAgent(let agentId):
            if let agent = coordinator.agents.first(where: { $0.id == agentId }) {
                try await coordinator.startAgent(agent)
            }

        case .stopAgent(let agentId):
            if let agent = coordinator.agents.first(where: { $0.id == agentId }) {
                try await coordinator.stopAgent(agent)
            }

        case .restartAgent(let agentId):
            if let agent = coordinator.agents.first(where: { $0.id == agentId }) {
                try await coordinator.restartAgent(agent)
            }

        case .scaleAgents(let count):
            // Simplified - would implement actual scaling logic
            print("Scaling to \(count) agents")

        case .sendNotification(let message):
            // Would send actual notification
            print("Notification: \(message)")

        case .runScript(let script):
            // Would execute actual script
            print("Running script: \(script)")

        case .wait(let seconds):
            try await Task.sleep(for: .seconds(seconds))
        }
    }

    /// Create a new workflow
    func createWorkflow(_ workflow: Workflow) {
        workflows.append(workflow)
    }

    /// Update workflow
    func updateWorkflow(_ workflow: Workflow) {
        if let index = workflows.firstIndex(where: { $0.id == workflow.id }) {
            workflows[index] = workflow
        }
    }

    /// Delete workflow
    func deleteWorkflow(_ workflowId: UUID) {
        workflows.removeAll { $0.id == workflowId }
    }

    // MARK: - Automation Rules

    /// Create automation rule
    func createRule(_ rule: AutomationRule) {
        automationRules.append(rule)
    }

    /// Update rule
    func updateRule(_ rule: AutomationRule) {
        if let index = automationRules.firstIndex(where: { $0.id == rule.id }) {
            automationRules[index] = rule
        }
    }

    /// Delete rule
    func deleteRule(_ ruleId: UUID) {
        automationRules.removeAll { $0.id == ruleId }
    }

    /// Toggle rule enabled state
    func toggleRule(_ ruleId: UUID) {
        if let index = automationRules.firstIndex(where: { $0.id == ruleId }) {
            automationRules[index].isEnabled.toggle()
        }
    }

    // MARK: - Default Data

    private func loadDefaultWorkflows() {
        workflows = [
            Workflow(
                id: UUID(),
                name: "Restart Failed Agents",
                description: "Automatically restart agents in error state",
                steps: [
                    WorkflowStep(action: .wait(5)),
                    WorkflowStep(action: .sendNotification("Checking for failed agents..."))
                ],
                scheduleInterval: 300, // 5 minutes
                isEnabled: true
            ),
            Workflow(
                id: UUID(),
                name: "Scale Up on High Load",
                description: "Add more agents when CPU is high",
                steps: [
                    WorkflowStep(action: .scaleAgents(10)),
                    WorkflowStep(action: .wait(60)),
                    WorkflowStep(action: .sendNotification("Scaled up agents"))
                ],
                scheduleInterval: 600, // 10 minutes
                isEnabled: false
            )
        ]
    }

    private func loadDefaultRules() {
        automationRules = [
            AutomationRule(
                id: UUID(),
                name: "High CPU Alert",
                description: "Alert when CPU usage exceeds 80%",
                trigger: .highCPU(80),
                workflowId: workflows.first?.id ?? UUID(),
                isEnabled: true
            ),
            AutomationRule(
                id: UUID(),
                name: "High Error Rate",
                description: "Alert when error rate exceeds 5%",
                trigger: .highErrorRate(0.05),
                workflowId: workflows.first?.id ?? UUID(),
                isEnabled: true
            )
        ]
    }
}

// MARK: - Supporting Types

/// Workflow definition
struct Workflow: Identifiable {
    let id: UUID
    var name: String
    var description: String
    var steps: [WorkflowStep]
    var scheduleInterval: TimeInterval
    var isEnabled: Bool
    var lastExecutionDate: Date?
    var executionCount: Int = 0
}

/// Workflow step
struct WorkflowStep: Identifiable {
    let id = UUID()
    let action: WorkflowAction
}

/// Workflow actions
enum WorkflowAction {
    case startAgent(UUID)
    case stopAgent(UUID)
    case restartAgent(UUID)
    case scaleAgents(Int)
    case sendNotification(String)
    case runScript(String)
    case wait(TimeInterval)
}

/// Workflow execution record
struct WorkflowExecution: Identifiable {
    let id: UUID
    let workflowId: UUID
    let workflowName: String
    let startTime: Date
    var endTime: Date?
    var status: ExecutionStatus
    var stepsCompleted: Int = 0
    var error: String?
}

enum ExecutionStatus {
    case running
    case completed
    case failed
}

/// Automation rule
struct AutomationRule: Identifiable {
    let id: UUID
    var name: String
    var description: String
    var trigger: RuleTrigger
    var workflowId: UUID
    var isEnabled: Bool
}

/// Rule triggers
enum RuleTrigger {
    case highCPU(Double)
    case highMemory(Double)
    case highErrorRate(Double)
    case agentFailed(UUID)
    case schedule(String) // Cron expression
    case custom
}
