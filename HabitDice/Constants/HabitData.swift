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
        let icon: String
        let title: String
        let category: Category
    }
    
    // 카테고리 구분 (UI에서 탭으로 나눌 목적)
    enum Category: String, CaseIterable {
        case mental = "🧠 정신"
        case selfImprovement = "📚 자기계발"
        case body = "💪 신체"
        case health = "💧 건강"
        case review = "🌙 마무리"
    }
    
    // 전체 추천 습관 리스트
    static let allHabits: [RecommendedHabit] = [
        // 🧠 정신
        RecommendedHabit(icon: "brain.head.profile", title: "명상 1분 하기", category: .mental),
        RecommendedHabit(icon: "pencil", title: "감사 1줄 쓰기", category: .mental),
        RecommendedHabit(icon: "target", title: "오늘 목표 1개 적기", category: .mental),
        
        // 📚 자기계발
        RecommendedHabit(icon: "book.fill", title: "1페이지 읽기", category: .selfImprovement),
        RecommendedHabit(icon: "note.text", title: "짧은 메모 1줄 남기기", category: .selfImprovement),
        RecommendedHabit(icon: "headphones", title: "유익한 콘텐츠 1분 듣기", category: .selfImprovement),
        
        // 💪 신체
        RecommendedHabit(icon: "figure.walk", title: "제자리 걸음 1분 하기", category: .body),
        RecommendedHabit(icon: "figure.strengthtraining.traditional", title: "스쿼트 5개 하기", category: .body),
        RecommendedHabit(icon: "figure.walk.treadmill", title: "달리기 30분 하기", category: .body),
        
        // 💧 건강
        RecommendedHabit(icon: "drop.fill", title: "물 1잔 마시기", category: .health),
        RecommendedHabit(icon: "applelogo", title: "과일 1종류 먹기", category: .health),
        RecommendedHabit(icon: "moon.stars", title: "야식 먹지 않기", category: .health),
        
        // 🌙 마무리
        RecommendedHabit(icon: "sparkles", title: "책상 정리 1분 하기", category: .review),
        RecommendedHabit(icon: "iphone", title: "SNS 10분만 하기", category: .review),
        RecommendedHabit(icon: "moon.stars.fill", title: "오늘 한 일 1줄 기록하기", category: .review)
    ]
}
