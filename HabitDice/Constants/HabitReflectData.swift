//
//  HabitReflectData.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/22/26.
//

import Foundation


// 습관의 회고 관련 상수 데이터

// MARK: - 무드 상수 데이터
enum Mood: String, Codable, CaseIterable {
    case happy = "😊"
    case neutral = "😐"
    case tired = "😓"
    
    var description: String {
        switch self {
        case .happy: return "좋았어요"
        case .neutral: return "보통이에요"
        case .tired: return "힘들었어요"
        }
    }
}


// MARK: UI 및 로직에서 사용할 정적 데이터 모델
struct HabitTag: Hashable {
    let id: String    // DB 저장용 고정 키
    let emoji: String    // UI 표시용 (변경 가능)
    let title: String    // UI 표시용 (변경 가능)
    let category: TagCategory
}


// 태그 데이터를 구분하는 카테고리
enum TagCategory {
    case internalFactor // 내적 요인 (내 마음, 몸 상태)
    case externalFactor // 외적 요인 (환경, 상황)
}


// 태그 상수 데이터 
struct HabitTagData {
    static let allTags: [HabitTag] = [
        // --- 내적 요인 (Internal) ---
        HabitTag(id: "internal_easy", emoji: "✅", title: "생각보다 쉬웠어요", category: .internalFactor),
        HabitTag(id: "internal_willpower", emoji: "💪", title: "의지로 해냈어요", category: .internalFactor),
        HabitTag(id: "internal_focus", emoji: "🎯", title: "집중이 잘 됐어요", category: .internalFactor),
        HabitTag(id: "internal_tired", emoji: "😴", title: "몸 컨디션이 저조했어요", category: .internalFactor),
        HabitTag(id: "internal_habitual", emoji: "🔄", title: "습관이 되어가는 느낌", category: .internalFactor),
        HabitTag(id: "internal_forgot", emoji: "😮", title: "하마터면 잊을 뻔했어요", category: .internalFactor),
        
        // --- 외적 요인 (External) ---
        HabitTag(id: "external_environment", emoji: "🌿", title: "환경이 딱 갖춰졌어요", category: .externalFactor),
        HabitTag(id: "external_no_time", emoji: "⏰", title: "시간이 부족했어요", category: .externalFactor),
        HabitTag(id: "external_help", emoji: "🚀", title: "주변의 도움을 받았어요", category: .externalFactor),
        HabitTag(id: "external_sudden_event", emoji: "⚡️", title: "갑작스러운 일이 생겼어요", category: .externalFactor),
        HabitTag(id: "external_no_distraction", emoji: "🔇", title: "방해 요소가 없었어요", category: .externalFactor),
        HabitTag(id: "external_bad_place", emoji: "🏢", title: "장소가 마땅치 않았어요", category: .externalFactor)
    ]
}
