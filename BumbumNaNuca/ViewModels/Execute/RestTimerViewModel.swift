//
//  RestTimerViewModel.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 07/01/26.
//

import Foundation
import Combine
import AVFoundation
import UIKit
import UserNotifications
import Observation
import OSLog

@Observable
final class RestTimerViewModel {
    // MARK: - Properties
    
    private(set) var remainingTime: TimeInterval = 0
    private(set) var totalTime: TimeInterval = 0
    private(set) var isRunning: Bool = false
    private(set) var isPaused: Bool = false
    
    private var timer: AnyCancellable?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private let hapticGenerator = UINotificationFeedbackGenerator()
    private var audioPlayer: AVAudioPlayer?
    
    // MARK: - Computed Properties
    
    var progress: Double {
        guard totalTime > 0 else { return 0 }
        return (totalTime - remainingTime) / totalTime
    }
    
    var timeString: String {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var formattedTime: String {
        timeString
    }
    
    var isCompleted: Bool {
        remainingTime <= 0 && !isRunning
    }
    
    // MARK: - Initialization
    
    init(duration: TimeInterval = 60) {
        self.totalTime = duration
        self.remainingTime = duration
    }
    
    // MARK: - Public Methods
    
    func start() {
        guard totalTime > 0 else { return }
        
        if remainingTime <= 0 {
            remainingTime = totalTime
        }
        
        isRunning = true
        isPaused = false
        
        startBackgroundTask()
        startTimer()
        
        AppLogger.execution.info("Rest timer started: \(self.totalTime)s")
    }
    
    func pause() {
        guard isRunning && !isPaused else { return }
        
        isPaused = true
        timer?.cancel()
        timer = nil
        
        AppLogger.execution.info("Rest timer paused at \(self.remainingTime)s")
    }
    
    func resume() {
        guard isRunning && isPaused else { return }
        
        isPaused = false
        startTimer()
        
        AppLogger.execution.info("Rest timer resumed at \(self.remainingTime)s")
    }
    
    func skip() {
        AppLogger.execution.info("Rest timer skipped")
        stop()
    }
    
    func stop() {
        isRunning = false
        isPaused = false
        timer?.cancel()
        timer = nil
        endBackgroundTask()
        
        // Cancel any pending notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Private Methods
    
    private func startTimer() {
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    private func tick() {
        guard remainingTime > 0 else {
            complete()
            return
        }
        
        remainingTime -= 1
    }
    
    private func complete() {
        isRunning = false
        isPaused = false
        remainingTime = 0
        timer?.cancel()
        timer = nil
        
        // Trigger feedback
        triggerHapticFeedback()
        playCompletionSound()
        
        // Schedule notification if in background
        if UIApplication.shared.applicationState != .active {
            scheduleCompletionNotification()
        }
        
        endBackgroundTask()
        
        AppLogger.execution.info("Rest timer completed")
    }
    
    private func triggerHapticFeedback() {
        hapticGenerator.notificationOccurred(.success)
    }
    
    private func playCompletionSound() {
        // Play system sound (1322 is a nice timer completion sound)
        AudioServicesPlaySystemSound(1322)
    }
    
    private func scheduleCompletionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Descanso concluído"
        content.body = "Hora da próxima série!"
        content.sound = .default
        content.categoryIdentifier = "REST_TIMER"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "rest-timer-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                AppLogger.execution.error("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func startBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            AppLogger.execution.warning("Background task expired for rest timer")
            self?.endBackgroundTask()
        }
        
        if backgroundTask != .invalid {
            AppLogger.execution.info("Background task started for rest timer")
        }
    }
    
    private func endBackgroundTask() {
        guard backgroundTask != .invalid else { return }
        
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
        
        AppLogger.execution.info("Background task ended for rest timer")
    }
    
    // MARK: - Deinitialization
    
    deinit {
        stop()
    }
}
