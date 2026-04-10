//
//  TriggerData.swift
//  HabitDice
//
//  Created by kwonjungguen on 3/31/26.
//

import Foundation


enum TriggerData {
    
    enum TriggerCategory: String, CaseIterable {
        case routine = "📆 일상"
        case place   = "📍 장소"
        case time    = "🌞 하루"
        case body    = "💪 신체"
    }

    struct RecommendedTrigger: Identifiable {
        let id = UUID()
        let title: String
        let category: TriggerCategory
    }
    
    static let allTriggers: [RecommendedTrigger] = [
        // 일상
        .init(title: "양치질을 마쳤을 때",          category: .routine),
        .init(title: "커피 첫 모금을 마실 때",       category: .routine),
        .init(title: "컴퓨터 전원을 켰을 때",        category: .routine),
        .init(title: "신발을 벗어 현관에 두었을 때", category: .routine),
        .init(title: "설거지를 마치고 손을 닦을 때", category: .routine),

        // 장소
        .init(title: "현관문을 열고 들어왔을 때",    category: .place),
        .init(title: "내 책상 의자에 앉았을 때",     category: .place),
        .init(title: "엘리베이터를 기다릴 때",       category: .place),
        .init(title: "카페에 자리를 잡았을 때",      category: .place),
        .init(title: "침대에 눕기 직전",             category: .place),

        // 하루
        .init(title: "눈을 뜨자마자",                category: .time),
        .init(title: "점심 식사 후 나른할 때",       category: .time),
        .init(title: "퇴근 10분 전",                 category: .time),
        .init(title: "오후 4시, 집중력이 떨어질 때", category: .time),
        .init(title: "취침 전 옷을 챙길 때",         category: .time),

        // 내 몸
        .init(title: "스마트폰을 목적 없이 켰을 때", category: .body),
        .init(title: "뒷목이 뻐근하다고 느낄 때",    category: .body),
        .init(title: "머릿속이 복잡해질 때",         category: .body),
        .init(title: "단 것이 먹고 싶어질 때",       category: .body),
        .init(title: "회의가 끝나고 한숨 돌릴 때",   category: .body),
    ]

    // 카테고리별 필터링 — View에서 매번 filter 안 써도 됨
    static func options(for category: TriggerCategory) -> [RecommendedTrigger] {
        allTriggers.filter { $0.category == category }
    }
}

