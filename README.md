# Remindly

**Remindly** is an iOS reminders app built with SwiftUI and SwiftData, designed to ensure you never miss your most critical events. Unlike standard reminder applications, Remindly introduces a unique "Urgency Level" system featuring a specialized "Spam" mode that aggressively notifies you until you explicitly acknowledge the alert.

## Features

- **Urgency Levels**: Categorize reminders by urgency (`None`, `Low`, `Meeting`, `High`, and `Custom`). 
- **High-Urgency Spam Notifications**: For critical reminders (`High` urgency or `Custom` with spam enabled), the app will send continuous burst notifications (one per second) to guarantee you notice them.
- **Custom Urgency Configurations**: Tailor exactly how and when you want to be notified by setting custom lead-time offsets and spam behaviors.
- **Persistent Background Tasks**: Uses Apple's `BackgroundTasks` API to keep notifications firing reliably in the background until dismissed.
- **Calendar & List Views**: Offers comprehensive views to check your schedule at a glance (Calendar mode) or manage tasks chronologically (List mode).
- **Core Integrations**: Built natively using `SwiftUI`, `SwiftData` for persistent local storage, and `UserNotifications` for robust alerting.

## Application Architecture

- **UI Framework**: SwiftUI
- **Database**: SwiftData (`@Model`)
- **App Lifecycle**: `@UIApplicationDelegateAdaptor` for deep integration with `UNUserNotificationCenterDelegate` and Background Task registration.

### Key Components

- **`Models/Reminder`**: The primary SwiftData model storing dates, titles, customized configurations, and tracking whether a spam cycle is actively firing.
- **`Services/NotificationService`**: Centralizes Apple's `UNUserNotificationCenter` handling. Manages the scheduling of single alerts and "Spam Bursts" (up to 60 sequential notifications).
- **`Services/RemindlyNotificationDelegate`**: Listens for the "STOP" action from the lock screen, gracefully ceasing the alarm and updating the database model.
- **`Views/CalendarTabView` & `Views/ReminderListView`**: Primary methods for the user to view upcoming tasks.

## Requirements

- iOS 17.0+
- Xcode 16.0+
- Swift 5.9+

## Setup & Installation

This project uses [XcodeGen](https://github.com/yonaskolb/XcodeGen) to manage its project file. You will not find a `.xcodeproj` committed to the repository. 

1. Ensure XcodeGen is installed:
   ```bash
   brew install xcodegen
   ```
2. Navigate to the project root and generate the Xcode project:
   ```bash
   xcodegen
   ```
3. Open `Remindly.xcodeproj` and build the application.

## Permissions

When run for the first time, Remindly will ask for Notification permissions. These are **essential** for the app to function properly. Without proper `.alert` and `.sound` notification authorization, the background high-urgency notifications will not work.

## Background Activity

Remindly utilizes `BGAppRefreshTask` (`com.henremindlyry.app.spamRefresh`) to wake up the app and schedule more notifications if a high-urgency reminder occurs. In testing, please use a physical device, as background background task execution behaves differently on the iOS Simulator.
