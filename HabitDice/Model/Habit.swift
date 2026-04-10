//
//  Habit.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/2/26.
//

import Foundation
import SwiftData


@Model
final class Habit {
    // 기본 정보
    var title: String     // 습관 명칭
    var emoji: String     // 습관 아이콘 (이모지)
    var createdAt: Date   // 습관 생성일
    
    // 상태 관리
    var isArchived: Bool  // 습관 졸업 여부 (True 면 더 이상 리스트에 표시 안함)
    
    // 트리거 정보
    var selectedTriggerAction: String?  // "양치질을 마쳤을 떄"
    
    // 반복 및 알람 설정
    var isRepeatOn: Bool  // 반복여부
    var repeatDays: [Int]  // [0,1,2] -> 일, 월, 화 (정렬된 배열로 저장)
    
    var isAlarmOn: Bool   // 알람 설정 여부
    @Relationship(deleteRule: .cascade) var notification: Notification?
    
    //var alarmTime: Date?  // 알람 시간 (시간 데이터만)
    // 관계 설정
    @Relationship(deleteRule: .cascade, inverse: \HabitLog.habit) var logs: [HabitLog] = []
    
    init(
        title: String,
        emoji: String,
        createdAt: Date,
        isArchived: Bool,
        selectedTriggerAction: String? = nil,
        isRepeatOn: Bool,
        repeatDays: [Int],
        isAlarmOn: Bool,
        alarmTime: Date? = nil,
        logs: [HabitLog]) {
            
        self.title = title
        self.emoji = emoji
        self.createdAt = createdAt
        self.isArchived = isArchived
        self.selectedTriggerAction = selectedTriggerAction
        self.isRepeatOn = isRepeatOn
        self.repeatDays = repeatDays
        self.isAlarmOn = isAlarmOn
        self.logs = logs
            
    }
    
    func isCompletedOnDay(on date: Date) -> Bool {
        return logs.first { log in
            Calendar.current.isDate(log.date, inSameDayAs: date)}?.isDone ?? false
    }
    
}


@Model
final class HabitLog {
    var date: Date              // 기록된 날짜 (시간 정보 포함)
    var isDone: Bool            // 완료 여부
    var completedCount: Int     // 누적 완료 횟수
    
    // 역관계: 이 로그가 어떤 습관에 속하는지 명시
    var habit: Habit?
    
    init(date: Date = Date(), isDone: Bool = false , completedCount: Int = 0) {
        self.date = date
        self.isDone = isDone
        self.completedCount = completedCount
    }
}



//@Model
//final class Habit {
//    var title: String       // "물 1잔 마시기"
//    var createdAt: Date     // 습관을 생성한 날짜
//    
//    @Relationship(deleteRule: .cascade) var logs: [HabitLog] = []    // 관계 설정: 하나의 습관을 여러 개의 로그를 가짐 (대신, 습관 삭제하면 기록도 삭제)
//    
//    var selectedTriggerAction: String?    // 사용자가 선택한 최종 트리거 문구 (예: 양치질을 마쳤을 때)
//    var triggerGroupName: String?         // 해당 트리거가 어떤 그룹(일상, 장소 등)이었는지 알고 싶다면
//    
//    init(title: String, createdAt: Date = Date(), triggerAction: String? = nil, groupName: String? = nil) {
//        self.title = title
//        self.createdAt = createdAt
//        self.selectedTriggerAction = triggerAction
//        self.triggerGroupName = groupName
//    }
//    
//    // UI에서 주간 현황을 그릴 때 "일 별 완료 여부" 확인 함수
//    func isCompletedOnDay(on date: Date) -> Bool {
//        return logs.first { log in Calendar.current.isDate(log.date, inSameDayAs: date)}?.isDone ?? false
//    }
//}




// 트리거 구조체
//struct RecommendedTrigger: Identifiable {
//    let id = UUID()
//    let title: String          // 예: "🔄 일상 고정 루틴"
//    let subTitle: String       // 예: "이미 하고 있는 일, 일상의 닻(Anchor)"
//    let items: [String]
//}


