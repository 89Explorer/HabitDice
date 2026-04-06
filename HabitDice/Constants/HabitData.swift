//
//  HabitData.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/4/26.
//

import Foundation


enum HabitData {
    
    // 추천 습관 하나하나의 정보를 담을 구조체
    struct RecommendedHabit: Identifiable {
        let id = UUID()
        let emoji: String
        let title: String
        let category: habitCategory
    }
    
    // 카테고리 구분 (UI에서 탭으로 나눌 목적)
    enum habitCategory: String, CaseIterable {
        case mental = "🧠 정신"
        case selfImprovement = "📚 성장"
        case body = "💪 신체"
        case health = "💧 건강"
        case review = "🌙 마무리"
    }
    
    // 전체 추천 습관 리스트
    static let allHabits: [RecommendedHabit] = [
        // 🧠 정신
        RecommendedHabit(emoji: "🧠", title: "명상 1분 하기", category: .mental),
        RecommendedHabit(emoji: "📓", title: "감사 1줄 쓰기", category: .mental),
        RecommendedHabit(emoji: "🎯", title: "오늘 목표 1개 적기", category: .mental),
        
        // 📚 자기계발
        RecommendedHabit(emoji: "📖", title: "1페이지 읽기", category: .selfImprovement),
        RecommendedHabit(emoji: "📝", title: "짧은 메모 1줄 남기기", category: .selfImprovement),
        RecommendedHabit(emoji: "🎧", title: "유익한 콘텐츠 1분 듣기", category: .selfImprovement),
        
        // 💪 신체
        RecommendedHabit(emoji: "🚶", title: "제자리 걸음 1분 하기", category: .body),
        RecommendedHabit(emoji: "🏋️", title: "스쿼트 5개 하기", category: .body),
        RecommendedHabit(emoji: "🏃‍♀️", title: "달리기 30분 하기", category: .body),
        
        // 💧 건강
        RecommendedHabit(emoji: "🚰", title: "물 1잔 마시기", category: .health),
        RecommendedHabit(emoji: "🍎", title: "과일 1종류 먹기", category: .health),
        RecommendedHabit(emoji: "😙", title: "야식 먹지 않기", category: .health),
        
        // 🌙 마무리
        RecommendedHabit(emoji: "📚", title: "책상 정리 1분 하기", category: .review),
        RecommendedHabit(emoji: "📱", title: "SNS 10분만 하기", category: .review),
        RecommendedHabit(emoji: "✍️", title: "오늘 한 일 1줄 기록하기", category: .review)
    ]
    
    static func options(for category: habitCategory) -> [RecommendedHabit] {
        allHabits.filter { $0.category == category }
    }
}
