# Description

After receiving the first `WKWatchConnectivityRefreshBackgroundTask` via `handleBackgroundTasks:`, the default `WCSession` delegate intercepts and handles future WatchConnectivity messages from iPhone to Apple Watch without triggering a second call to `handleBackgroundTasks:`. Apple documentation says to not call `setTaskCompleted` on *any* task until the `[WCSession defaultSession].hasContentPending == NO`. However, because there's no `WKWatchConnectivityRefreshBackgroundTask` associated with the subsequent messages intercepted by the `WCSessionDelegate`, the tasks can never be completed.

Even if Apple documentation is ignored, and the watchOS app immediately calls `setTaskCompleted` on all tasks as soon as they are received, the behavior is the same -- only the first message triggers a call to `handleBackgroundTasks` and subsequent messages are handled directly by the delegate.

One cannot nil `[WCSession defaultSession]` or forcefully shut it down.

# Steps to Reproduce

 1. Launch the watchOS app via Xcode scheme.
 2. Command + Shift + H in the watch simulator to put watchOS app into the background.
 3. Manually launch the iOS counterpart app from the Simulator.
 4. Clear Xcode console (Command + K).
 5. Click "Activate WatchConnectivity Session" button.
 6. Click "Send User Info to Apple Watch" button.
 7. Click "Send User Info to Apple Watch" button a second time.

# Expected Result

```
Watch app woke up for background task
Handling WatchConnectivity background task
WatchConnectivity session activation changed to "activated"
Received message with counter value = 0
No pending content. Marking all tasks (1 tasks) as complete.
Watch app woke up for background task
Handling WatchConnectivity background task
WatchConnectivity session activation changed to "activated"
Received message with counter value = 1
No pending content. Marking all tasks (1 tasks) as complete.
```

# Actual Result
```
Watch app woke up for background task
Handling WatchConnectivity background task
WatchConnectivity session activation changed to "activated"
Received message with counter value = 0
Task not completed. More content pending...
Received message with counter value = 1
No pending content. Marking all tasks (1 tasks) as complete.
```

# Notes

 * The first UserInfo transmission always seems to have more content pending, but there shouldn't be any.
 * "`Watch app woke up for background task`" is only printed once, indicating that `handleBackgroundTasks` is only called once.
