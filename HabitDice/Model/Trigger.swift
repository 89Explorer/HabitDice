//
//  Trigger.swift
//  HabitDice
//
//  Created by kwonjungguen on 3/31/26.
//

import Foundation


// 트리거 구조체
struct Trigger: Identifiable {
    let id = UUID()
    let title: String          // 예: "🔄 일상 고정 루틴"
    let subTitle: String       // 예: "이미 하고 있는 일, 일상의 닻(Anchor)"
    let items: [String]
}

