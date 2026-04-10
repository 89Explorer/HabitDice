//
//  Notification.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/9/26.
//

import Foundation
import SwiftData


@Model
class Notification {
    var id: String
    var time: Date
    var isEnabled: Bool
    var timestamp: Date
    
    // 관계 설정 (선택 사항)
    var habit: Habit?

    init(
        id: String = UUID().uuidString,      // 호출 시 생략하면 자동으로 새 UUID 생성
        time: Date,                           
        isEnabled: Bool = true,              // 기본적으로 알람은 켜진 상태로 생성
        timestamp: Date = .now               // 생성 시점 기록
    ) {
        self.id = id
        self.time = time
        self.isEnabled = isEnabled
        self.timestamp = timestamp
    }
    
}
