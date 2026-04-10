//
//  NotificationRepository.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/9/26.
//

import Foundation
import SwiftData
import UserNotifications
import UIKit


class NotificationRepository {
    
    private let modelContainer: ModelContainer
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
    
    private let center = UNUserNotificationCenter.current()
    
    // 권한 체크 함수
    @discardableResult // 반환값을 사용하지 않아도 경고가 뜨지 않게 함
    func checkAndRequestNotificationAuth() async -> Bool {
        let settings = await center.notificationSettings()
        
        switch settings.authorizationStatus {
        case .notDetermined:
            // 최초 요청 후 결과 반환
            await requestNotificationAuth()
            let newSettings = await center.notificationSettings()
            return newSettings.authorizationStatus == .authorized
            
        case .denied:
            // 거절 상태면 설정으로 보내고 false 반환
            return false
            
        case .authorized, .provisional:
            return true
            
        default:
            return false
        }
    }
    
    
    // 권한 요청
    func requestNotificationAuth() async {
        do {
            let success = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            if success {
                print("✅ [NotificationManager] 권한 허용됨")
            } else {
                print("❌ [NotificationManager] 권한 거부됨")
            }
        } catch {
            print("⚠️ [NotificationManager] 권한 요청 에러: \(error.localizedDescription)")
        }
    }
    
    
    func registerNotification(habit: Habit) async {
        
        let settings = await center.notificationSettings()
        
        guard settings.authorizationStatus == .authorized else {
            print("❌ [NotificationManager] 권한이 없어 알림을 등록할 수 없습니다.")
            return
        }
        
        // 안전하게 Notification 객체를 추출
        guard let notification = habit.notification else {
            print("⚠️ [NotificationManager] 등록할 알람 데이터가 없습니다.")
            return
        }
        
        print("🚀 [NotificationManager] 알림 등록 시작: \(notification.id)")
        
        //cancelNotification(notification: notification)
        
        let content = UNMutableNotificationContent()
        content.title = "\(habit.emoji) \(habit.title), 실천할 시간이에요!"
        content.body = habit.selectedTriggerAction.map { "\($0) 잊지 말고 실행하세요! 🔥" } ?? "지금 바로 습관을 실천해 보세요! ✨"
        content.sound = .default
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: notification.time)
        let minute = calendar.component(.minute, from: notification.time)
        
        do {
            if habit.repeatDays.isEmpty {
                let component = DateComponents(hour: hour, minute: minute)
                let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: false)
                let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
                
                try await center.add(request)
                print("🔔 [NotificationManager] 단일 알람 등록 완료 (\(hour):\(minute))")
                
            } else {
                for weekNum in habit.repeatDays {
                    var dateComponent = DateComponents()
                    dateComponent.hour = hour
                    dateComponent.minute = minute
                    dateComponent.weekday = weekNum
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
                    let identifier = "\(notification.id)_\(weekNum)"
                    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                    try await center.add(request)
                    print("🔁 [NotificationManager] 요일(\(weekNum)) 반복 알람 등록 완료")
                }
            }
        } catch {
            print("⚠️ [NotificationManager] 알람 등록 중 에러 발생: \(error.localizedDescription)")
        }
        
    }
    
    
    // 알람 취소
    func cancelNotification(notification: Notification) {
        var identifiers = ["\(notification.id)"]
        for i in 1...7 {
            identifiers.append("\(notification.id)_\(i)")
        }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("🗑️ [NotificationManager] 기존 알림 제거 완료 (ID: \(notification.id))")
    }
    
    func checkPendingNotifications() {
        center.getPendingNotificationRequests { requests in
            print("📝 --- 현재 예약된 알림 목록 (총 \(requests.count)개) ---")
            for request in requests {
                print("ID: \(request.identifier) | Trigger: \(String(describing: request.trigger))")
            }
            print("---------------------------------------")
        }
    }
}
