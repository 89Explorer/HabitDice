//
//  Date-Extensions.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/11/26.
//

import Foundation


extension Date {
    
    /// Custom Date Format
    // Swift의 Date 객체(날짜와 시간 정보)을 우리가 읽을 수 있는 특정 문자열(String) 형태로 반환하는 함수
    func format(_ format: String) -> String {
        
        // DateFormatter: 날짜와 문자열 사이를 변환해주는 '통역사'역할 하는 클래스
        let formatter = DateFormatter()
        
        // .dateFormat: 통역사에게 어떤 형식으로 보여줄지 알려주는 규칙
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
    
    
    // 특정 날짜가 포함된 일주일(7일)의 전체 날짜 데이터를 가져오는 함수
    func fetchWeek(_ date: Date = .init()) -> [WeekDay] {
        let calendar = Calendar.current
        
        // 기준점 잡기: 입력 받은 date를 해당 날짜의 오전 0시 0분 0초로 초기화 합니다.
        // 시간 차이로 인한 계산 오류를 방지하기 위한 아주 중요한 단계 입니다.
        let startOfDate = calendar.startOfDay(for: date)
        
        var week: [WeekDay] = []
        
        // 이번 주의 시작일 찾기
        // Calendar의 기능을 이용해 startOfDate가 속한 '이번 주의 시작점(보통 일요일)'을 찾습니다.
        // 예: 오늘이 수요일이라면, 그 주의 시작인 지난 일요일의 날짜를 가져옵니다.
        let weekForDate = calendar.dateInterval(of: .weekOfMonth, for: startOfDate)
        guard let startOfWeek = weekForDate?.start else {
            return []
        }
        
        // 7일간의 날짜 생성
        // 시작일 (startOfWeek)로부터 0일 부터 6일까지 차례대로 더하면서 7일간의 날짜 객체 만듭니다.
        // Index 0 -> 일요일 (시작일), Index 1 -> 월요일 ...Index 6 -> 토요일
        (0..<7).forEach { Index in
            if let weekDay = calendar.date(byAdding: .day, value: Index, to: startOfWeek) {
                week.append(.init(date: weekDay))
            }
        }
        
        return week
    }
    
    // "4월 2주차" 형태의 문자열을 반환
    func weekRangeTitle(from date: Date) -> String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let weekOfMonth = calendar.component(.weekOfMonth, from: date)
        return "\(month)월 \(weekOfMonth)주차"
    }
    
    struct WeekDay: Identifiable {
        var id: UUID = .init()
        var date: Date
    }
}
