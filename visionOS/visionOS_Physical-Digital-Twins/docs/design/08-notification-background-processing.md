# Notification & Background Processing Design

## Overview

This document defines the notification system and background processing strategy for Physical-Digital Twins, including expiration alerts, warranty reminders, and recall notifications.

## Notification Types

### 1. Expiration Warnings

```swift
enum ExpirationNotificationType {
    case warning3Days    // 3 days before expiration
    case warning1Day     // 1 day before
    case expiresToday   // Day of expiration
    case expired        // After expiration
}
```

### 2. Warranty & Maintenance

```swift
enum MaintenanceNotificationType {
    case warrantyExpiring30Days
    case warrantyExpiring7Days
    case maintenanceDue
}
```

### 3. Product Recalls

```swift
enum RecallNotificationType {
    case criticalRecall    // Safety issue
    case standardRecall    // Non-critical
}
```

## Notification Implementation

### Schedule Notifications

```swift
import UserNotifications

class NotificationScheduler {
    func scheduleExpirationNotification(for food: FoodTwin) async throws {
        guard let expirationDate = food.expirationDate else { return }

        // Schedule 3 notifications: 3 days, 1 day, day of
        let intervals: [(TimeInterval, ExpirationNotificationType)] = [
            (-3 * 86400, .warning3Days),
            (-1 * 86400, .warning1Day),
            (0, .expiresToday)
        ]

        for (offset, type) in intervals {
            let triggerDate = expirationDate.addingTimeInterval(offset)
            guard triggerDate > Date() else { continue } // Skip past dates

            let content = UNMutableNotificationContent()
            content.title = type.title
            content.body = type.body(for: food)
            content.sound = .default
            content.categoryIdentifier = "EXPIRATION"
            content.userInfo = ["twinID": food.id.uuidString, "type": type.rawValue]

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour], from: triggerDate),
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: "\(food.id)_\(type.rawValue)",
                content: content,
                trigger: trigger
            )

            try await UNUserNotificationCenter.current().add(request)
        }
    }

    func cancelNotifications(for twinID: UUID) {
        let identifiers = [
            "\(twinID)_warning3Days",
            "\(twinID)_warning1Day",
            "\(twinID)_expiresToday"
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}

extension ExpirationNotificationType {
    var title: String {
        switch self {
        case .warning3Days: return "Food Expiring Soon"
        case .warning1Day: return "Food Expires Tomorrow"
        case .expiresToday: return "Food Expires Today"
        case .expired: return "Food Expired"
        }
    }

    func body(for food: FoodTwin) -> String {
        switch self {
        case .warning3Days:
            return "\(food.productName) expires in 3 days"
        case .warning1Day:
            return "\(food.productName) expires tomorrow. Use it soon!"
        case .expiresToday:
            return "\(food.productName) expires today. Use it now or freeze it."
        case .expired:
            return "\(food.productName) has expired. Consider removing it."
        }
    }
}
```

### Notification Actions

```swift
class NotificationActionHandler {
    func setupNotificationCategories() {
        let expirationCategory = UNNotificationCategory(
            identifier: "EXPIRATION",
            actions: [
                UNNotificationAction(
                    identifier: "USED",
                    title: "Mark as Used",
                    options: .foreground
                ),
                UNNotificationAction(
                    identifier: "RECIPES",
                    title: "Find Recipes",
                    options: .foreground
                ),
                UNNotificationAction(
                    identifier: "SNOOZE",
                    title: "Remind Later",
                    options: []
                )
            ],
            intentIdentifiers: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([expirationCategory])
    }

    func handleNotificationAction(response: UNNotificationResponse) async {
        let twinID = UUID(uuidString: response.notification.request.content.userInfo["twinID"] as! String)!

        switch response.actionIdentifier {
        case "USED":
            await markItemAsUsed(twinID)
        case "RECIPES":
            await showRecipes(for: twinID)
        case "SNOOZE":
            await snoozeNotification(twinID, hours: 12)
        default:
            break
        }
    }
}
```

## Background Processing

### Background Tasks

```swift
import BackgroundTasks

class BackgroundTaskManager {
    static let refreshTaskID = "com.app.physicaldigitaltwins.refresh"
    static let syncTaskID = "com.app.physicaldigitaltwins.sync"

    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.refreshTaskID,
            using: nil
        ) { task in
            self.handleRefreshTask(task: task as! BGAppRefreshTask)
        }

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.syncTaskID,
            using: nil
        ) { task in
            self.handleSyncTask(task: task as! BGProcessingTask)
        }
    }

    private func handleRefreshTask(task: BGAppRefreshTask) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        let operation = RefreshOperation()

        task.expirationHandler = {
            queue.cancelAllOperations()
        }

        operation.completionBlock = {
            task.setTaskCompleted(success: !operation.isCancelled)
            self.scheduleNextRefresh()
        }

        queue.addOperation(operation)
    }

    func scheduleNextRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: Self.refreshTaskID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 4 * 3600) // 4 hours

        try? BGTaskScheduler.shared.submit(request)
    }
}
```

### Refresh Operations

```swift
class RefreshOperation: Operation {
    override func main() {
        guard !isCancelled else { return }

        // 1. Check for new recalls
        checkProductRecalls()

        guard !isCancelled else { return }

        // 2. Update expiration notifications
        updateExpirationNotifications()

        guard !isCancelled else { return }

        // 3. Sync with CloudKit (if enabled)
        syncWithCloud()
    }

    private func checkProductRecalls() {
        // Query recall databases for user's products
        let recallChecker = RecallChecker()
        let recalls = recallChecker.checkForRecalls()

        for recall in recalls {
            NotificationScheduler().sendRecallAlert(recall)
        }
    }

    private func updateExpirationNotifications() {
        // Cancel outdated notifications
        // Reschedule for newly added items
        let scheduler = NotificationScheduler()
        let foodItems = fetchAllFoodItems()

        for item in foodItems {
            try? scheduler.scheduleExpirationNotification(for: item)
        }
    }
}
```

## Permission Management

```swift
class NotificationPermissionManager {
    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Failed to request notification permission: \(error)")
            return false
        }
    }

    func checkPermissionStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
}
```

## Smart Scheduling

### Adaptive Notifications

```swift
class AdaptiveNotificationScheduler {
    func scheduleNotification(for food: FoodTwin) async {
        // Adjust timing based on user behavior
        let userStats = await fetchUserStats()

        // If user typically checks app in morning, schedule for 8 AM
        // If user ignores notifications, reduce frequency
        let optimalTime = calculateOptimalTime(userStats: userStats)

        // Schedule at optimal time
        scheduleAtTime(optimalTime, for: food)
    }

    private func calculateOptimalTime(userStats: UserStats) -> Date {
        // Analyze when user typically opens app
        // Analyze when user dismisses vs acts on notifications
        // Return optimal notification time
        return Date()
    }
}
```

## Summary

This notification system provides:
- **Timely Alerts**: Expiration warnings 3 days, 1 day, day-of
- **Actionable**: Quick actions from notifications
- **Smart Scheduling**: Adaptive timing based on user behavior
- **Background Processing**: Automatic recall checks and updates
- **Privacy Respecting**: No unnecessary notifications

Notifications should be helpful, not annoying. Quality over quantity.
