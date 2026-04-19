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
    var archivedDate: Date?    // 습관 졸업 날짜
    
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
    
    // 특정 날짜에 습관을 완료했는지 확인하는 함수 
    func isCompletedOnDay(on date: Date) -> Bool {
        return self.logs.contains { log in
            Calendar.current.isDate(log.date, inSameDayAs: date) && log.isDone
        }
    }
    
    func habitArchive() {
        self.isArchived = true
        self.archivedDate = Date()    // 현재 시간을 졸업일로 기록
    }
    
}

extension Habit {
    
    // 생성일로부터 현재 (또는 졸업일) 까지 습관을 실천했어야 하는 총 횟수
    var totalChallengeCount: Int {
        let calendar = Calendar.current
        var count = 0
        
        // 시작일: 생성일 자정
        var cursor = calendar.startOfDay(for: self.createdAt)
        // 종료일: 졸업했따면 졸업일, 아니면 오늘 자정
        let endDate = isArchived ? (archivedDate ?? Date()) : Date()
        let endCursor = calendar.startOfDay(for: endDate)
        
        while cursor <= endCursor {
            let weekday = calendar.component(.weekday, from: cursor)
            // 해당 날짜의 요일이 반복 설정에 포함되어 있다면 카운트
            if repeatDays.contains(weekday) {
                count += 1
            }
            
            // 다음날로 이동
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        
        return count
    }
    
    // 전체 기간 동안 실제 완료(isDone)한 총 횟수
    var totalSuccessCount: Int {
        // logs 중에서 isDone이 true 인 것들의 개수만 반환
        return logs.filter { $0.isDone }.count
    }
    
    // 전체 기간 동안 달성률 (0.0 ~ 1.0)
    var achievementRate: Double {
        let total = totalChallengeCount
        guard total > 0 else { return 0.0 }
        
        return Double(totalSuccessCount) / Double(total)
    }
    
    // UI 표시용 달성률 텍스트 (예: 85%)
    var achievementRateString: String {
        return "\(Int(achievementRate * 100))%"
    }
    
    // 습관 생성일로부터 현재 (또는 졸업일) 까지 며칠 째인지 반환 (1일차부터 시작)
    var daysSinceCreation: Int {
        let calendar = Calendar.current
        
        // 기준이 되는 시작일 (시간 정보를 00:00:00으로 초기화)
        let startDate = calendar.startOfDay(for: self.createdAt)
        
        // 기준이 되는 종료일 (졸업했다면 졸업일 아니면 오늘)
        let endDate = isArchived ? (archivedDate ?? Date()) : Date()
        let endOfTarget = calendar.startOfDay(for: endDate)
        
        // 두 날짜 사이의 일수 차이 계산
        let components = calendar.dateComponents([.day], from: startDate, to: endOfTarget)
        
        // 1일차부터 시작하게 하려면 +1을 합니다.
        return (components.day ?? 0) + 1
    }
    
    // 습관 생성일로부터 오늘까지 몇 주차인지 계산
    var weeksSinceCreation: Int {
        return (daysSinceCreation + 6) / 7 // 올림 계산법
    }
    
    // 이번 달 완료 횟수
    var monthlyCompletedCount: Int {
        let calendar = Calendar.current
        let now = Date()
        
        // isDate()는 연도까지 같이 비교
        return logs.filter {
            calendar.isDate($0.date, equalTo: now, toGranularity: .month) && $0.isDone }.count
    }
    
    // 최장 연속일
    var maxStreak: Int {
        let calendar = Calendar.current
        
        // 완료한 날짜만 정렬해서 가져오기
        let completedDays = Set(logs.filter { $0.isDone }.map { calendar.startOfDay(for: $0.date) })
        if completedDays.isEmpty { return 0 }
        
        var maxCount = 0
        var currentRunningStreak = 0
        
        // 생성일로부터 오늘(또는 졸업일)까지 하루 씩 전진
        var cursor = calendar.startOfDay(for: createdAt)
        let endDate = isArchived ? (archivedDate ?? Date()) : Date()
        let endCursor = calendar.startOfDay(for: endDate)
        
        while cursor <= endCursor {
            let weekday = calendar.component(.weekday, from: cursor)
            
            if repeatDays.contains(weekday) {
                if completedDays.contains(cursor) {
                    // 완료했다면 현재 스택을 올리고, 최대값 갱신
                    currentRunningStreak += 1
                    maxCount = max(maxCount, currentRunningStreak)
                } else {
                    // 실패했다면 스택 초기화
                    if cursor < calendar.startOfDay(for: Date()) {
                        currentRunningStreak = 0
                    }
                }
            }
            
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            
            cursor = next
        }
        return maxCount
    }
    
    
    // MARK: - 연속 달성일 (반복 요일 기준)
    var currentStreak: Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        
        // 완료한 날짜 Set (시간 제거)
        let completedDays = Set(
            logs.filter { $0.isDone }
                .map { calendar.startOfDay(for: $0.date) }
        )
        
        var streak = 0
        var cursor = startOfToday
        
        while true {
            let weekday = calendar.component(.weekday, from: cursor)
            
            if repeatDays.contains(weekday) {
                if completedDays.contains(cursor) {
                    // 반복 요일이고 완료 → 연속 카운트
                    streak += 1
                } else if cursor == startOfToday {
                    // 오늘은 아직 기회가 있으므로 건너뜀
                } else {
                    // 반복 요일인데 미완료 → 연속 끊김
                    break
                }
            }
            // 하루 전으로 이동
            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            
            // 습관 생성일 이전으로 가면 중단
            if prev < calendar.startOfDay(for: createdAt) { break }
            
            cursor = prev
        }
        
        return streak
    }
    
    // 이번 달 달성률
    var monthlyAchievementRate: Int {
        let calendar = Calendar.current
        let now = Date()
        
        // 이번 달 1일
        guard let startOfMonth = calendar.date(
            from: calendar.dateComponents([.year, .month], from: now)
        ) else { return 0 }
        
        // 1일부터 오늘까지 날짜 순회
        var expectedCount = 0
        var cursor = max(startOfMonth, calendar.startOfDay(for: createdAt))
        
        while cursor <= now {
            let weekday = calendar.component(.weekday, from: cursor)
            if repeatDays.contains(weekday) {
                expectedCount += 1
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            
            cursor = next
        }
        
        // 0 으로 나누기 방지
        guard expectedCount > 0 else { return 0 }
        
        // 이번 달 완료 횟수
        let completedCount = logs.filter {
            calendar.isDate($0.date, equalTo: now, toGranularity: .month) && $0.isDone
        }.count
        
        return Int((Double(completedCount) / Double(expectedCount)) * 100)
    }
    
}

extension Habit {
    
    // 단일 샘플 접근을 위한 정적 프로퍼티
    static let detailSample = sampleData[0]
    
    static let sampleData: [Habit] = [
        Habit(
            title: "물 2L 마시기",
            emoji: "💧",
            createdAt: Date().addingTimeInterval(-86400 * 7), // 7일 전 생성
            isArchived: false,
            selectedTriggerAction: "아침에 일어나자마자",
            isRepeatOn: true,
            repeatDays: [1, 3, 4, 6, 7], // 매일
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
            title: "헬스장가서 40분 근력하기",
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
            repeatDays: [1, 7], // 주말
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
        let habits = Habit.sampleData
        let calendar = Calendar.current
        
        func date(daysAgo: Int) -> Date {
            calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
        }
        
        // MARK: 1. 물 2L 마시기
        // repeatDays: [1,3,4,6,7] → 일(1),화(3),수(4),금(6),토(7)
        // 생성일: 4월 7일(화)
        // 해당 요일: 7(화), 8(수), 10(금), 11(토), 12(일), 14(화/오늘)
        // 시나리오: 7,8,12,14 완료 / 10,11 미완료
        
        habits[0].logs = [
            HabitLog(date: date(daysAgo: 7), isDone: true,  completedCount: 1), // 4/7  화 ✅
            HabitLog(date: date(daysAgo: 6), isDone: true,  completedCount: 2), // 4/8  수 ✅
            HabitLog(date: date(daysAgo: 4), isDone: false, completedCount: 2), // 4/10 금 ❌
            HabitLog(date: date(daysAgo: 3), isDone: false, completedCount: 2), // 4/11 토 ❌
            HabitLog(date: date(daysAgo: 2), isDone: true,  completedCount: 3), // 4/12 일 ✅
            HabitLog(date: date(daysAgo: 0), isDone: true,  completedCount: 4), // 4/14 화 ✅
        ]
        
        // MARK: 2. SwiftUI 공부하기
        // repeatDays: [1,2,3,4,5] → 일,월,화,수,목
        // 생성일: 3일 전 (4월 11일, 토) → 실제 시작은 4월 12일(일)부터
        // 해당 요일: 12일(일), 13일(월), 14일(화/오늘)
        // 시나리오: 12일, 13일 완료 / 오늘 아직 미완료
        habits[1].logs = [
            HabitLog(date: date(daysAgo: 2), isDone: true, completedCount: 1), // 4/12 일
            HabitLog(date: date(daysAgo: 1), isDone: true, completedCount: 2), // 4/13 월
        ]
        
        // MARK: 3. 헬스장 근력하기
        // repeatDays: [1,3,5] → 일,화,목
        // 생성일: 14일 전 (4월 1일, 수) → 실제 시작은 4월 5일(일)부터
        // 해당 요일: 5일(일), 7일(화), 9일(목), 12일(일), 14일(화/오늘)
        // 시나리오: 5일, 7일, 9일 완료 / 12일 미완료 / 오늘 완료
        habits[2].logs = [
            HabitLog(date: date(daysAgo: 9),  isDone: true,  completedCount: 1), // 4/5  일
            HabitLog(date: date(daysAgo: 7),  isDone: true,  completedCount: 2), // 4/7  화
            HabitLog(date: date(daysAgo: 5),  isDone: true,  completedCount: 3), // 4/9  목
            HabitLog(date: date(daysAgo: 2),  isDone: false, completedCount: 3), // 4/12 일 (미완료)
            HabitLog(date: date(daysAgo: 0),  isDone: true,  completedCount: 4), // 4/14 화 (오늘)
        ]
        
        // MARK: 4. 독서 10페이지
        // repeatDays: [1,7] → 일,토
        // 생성일: 5일 전 (4월 9일, 목) → 실제 시작은 4월 11일(토)부터
        // 해당 요일: 11일(토), 12일(일)
        // 시나리오: 11일 완료 / 12일 미완료 (신규라 아직 불안정)
        habits[3].logs = [
            HabitLog(date: date(daysAgo: 3), isDone: true,  completedCount: 1), // 4/11 토
            HabitLog(date: date(daysAgo: 2), isDone: false, completedCount: 1), // 4/12 일 (미완료)
        ]
        
        return habits
    }
}

