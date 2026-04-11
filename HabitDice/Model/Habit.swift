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

extension Habit {
    static let sampleData: [Habit] = [
        Habit(
            title: "물 2L 마시기",
            emoji: "💧",
            createdAt: Date().addingTimeInterval(-86400 * 7), // 7일 전 생성
            isArchived: false,
            selectedTriggerAction: "아침에 일어나자마자",
            isRepeatOn: true,
            repeatDays: [0, 1, 2, 3, 4, 5, 6], // 매일
            isAlarmOn: true,
            logs: []
        ),
        
        Habit(
            title: "SwiftUI 공부하기",
            emoji: "💻",
            createdAt: Date().addingTimeInterval(-86400 * 3), // 3일 전 생성
            isArchived: false,
            selectedTriggerAction: "퇴근하고 책상에 앉았을 때",
            isRepeatOn: true,
            repeatDays: [1, 2, 3, 4, 5], // 월~금
            isAlarmOn: true,
            logs: []
        ),
        
        Habit(
            title: "헬스장 가기",
            emoji: "🏋️‍♂️",
            createdAt: Date().addingTimeInterval(-86400 * 14), // 14일 전 생성
            isArchived: false,
            selectedTriggerAction: "운동복으로 갈아입었을 때",
            isRepeatOn: true,
            repeatDays: [1, 3, 5], // 월, 수, 금
            isAlarmOn: false,
            logs: []
        ),
        
        Habit(
            title: "독서 10페이지",
            emoji: "📚",
            createdAt: Date().addingTimeInterval(-86400 * 5), // 5일 전 생성
            isArchived: false,
            selectedTriggerAction: "잠들기 전 침대에 누웠을 때",
            isRepeatOn: true,
            repeatDays: [0, 6], // 주말
            isAlarmOn: true,
            logs: []
        )
        
    ]
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


extension Habit {
    static var sampleDataWithLogs: [Habit] {
        let habits = Habit.sampleData // 기존에 정의하신 4개의 습관 가져오기
        
        // 1. 물 2L 마시기 (최근 3일간 연속 완료)
        let log1_1 = HabitLog(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, isDone: true, completedCount: 1)
        let log1_2 = HabitLog(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, isDone: true, completedCount: 2)
        let log1_3 = HabitLog(date: Date(), isDone: true, completedCount: 3)
        habits[0].logs = [log1_1, log1_2, log1_3]
        
        // 2. SwiftUI 공부하기 (어제는 완료, 오늘은 아직 미완료)
        let log2_1 = HabitLog(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, isDone: true, completedCount: 1)
        let log2_2 = HabitLog(date: Date(), isDone: false, completedCount: 1)
        habits[1].logs = [log2_1, log2_2]
        
        // 3. 헬스장 가기 (그저께 완료)
        let log3_1 = HabitLog(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, isDone: true, completedCount: 1)
        habits[2].logs = [log3_1]
        
        // 4. 독서 10페이지 (신규 습관, 기록 없음)
        habits[3].logs = []
        
        return habits
    }
}
