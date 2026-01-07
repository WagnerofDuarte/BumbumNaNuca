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
import Observation

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
    
    var formattedTime: String {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var isCompleted: Bool {
        remainingTime <= 0 && isRunning
    }
    
    // MARK: - Public Methods
    
    func start(duration: TimeInterval) {
        guard duration > 0 else { return }
        
        totalTime = duration
        remainingTime = duration
        isRunning = true
        isPaused = false
        
        startBackgroundTask()
        startTimer()
    }
    
    func pause() {
        guard isRunning && !isPaused else { return }
        
        isPaused = true
        timer?.cancel()
        timer = nil
    }
    
    func resume() {
        guard isRunning && isPaused else { return }
        
        isPaused = false
        startTimer()
    }
    
    func skip() {
        stop()
    }
    
    func stop() {
        isRunning = false
        isPaused = false
        remainingTime = 0
        timer?.cancel()
        timer = nil
        endBackgroundTask()
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
            onTimerComplete()
            return
        }
        
        remainingTime -= 1
    }
    
    private func onTimerComplete() {
        isRunning = false
        isPaused = false
        remainingTime = 0
        timer?.cancel()
        timer = nil
        
        // Trigger feedback
        triggerHapticFeedback()
        playCompletionSound()
        
        endBackgroundTask()
    }
    
    private func triggerHapticFeedback() {
        hapticGenerator.notificationOccurred(.success)
    }
    
    private func playCompletionSound() {
        // Play system sound
        guard let soundURL = Bundle.main.url(forResource: "timer_complete", withExtension: "wav") else {
            // Fallback to system sound if custom sound not available
            AudioServicesPlaySystemSound(1315) // System notification sound
            return
        }
        
        do {
            // Respect silent mode
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            // Fallback to system sound on error
            AudioServicesPlaySystemSound(1315)
        }
    }
    
    private func startBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    private func endBackgroundTask() {
        guard backgroundTask != .invalid else { return }
        
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
    
    // MARK: - Deinitialization
    
    deinit {
        stop()
    }
}
