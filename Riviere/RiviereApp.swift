//
//  RiviereApp.swift
//  Riviere
//

import SwiftUI
import BackgroundTasks

@main
struct RiviereApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerBackgroundTasks()
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleAppRefresh()
    }

    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "ca.point.riviere.refresh", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }

    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "ca.point.riviere.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60) // 1 hour

        do {
            try BGTaskScheduler.shared.submit(request)
            print("Scheduled background refresh in 1 hour")
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }

    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()

        let taskOperation = Task {
            do {
                _ = try await ForecastService.shared.fetchForecast()
                print("Background refresh completed")
            } catch {
                print("Background refresh failed: \(error)")
            }
        }

        task.expirationHandler = {
            taskOperation.cancel()
        }

        Task {
            await taskOperation.value
            task.setTaskCompleted(success: true)
        }
    }
}
