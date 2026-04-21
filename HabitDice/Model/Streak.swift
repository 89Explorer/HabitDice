//
//  Streak.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/20/26.
//

import Foundation

struct StreakLevel {
    let count: Int // 현재 연속일
    
    // 단계 판정 로직
    enum LevelType {
        case starting, enduring, familiar, solid, miraculous
    }
    
    var type: LevelType {
        switch count {
        case 1...3:   return .starting
        case 4...10:  return .enduring
        case 11...30: return .familiar
        case 31...65: return .solid
        case 66... : return .miraculous
        default: return .starting
        }
    }

    // 1. 단계별 이름
    var name: String {
        switch type {
        case .starting:   return "아기불"
        case .enduring:   return "기특불"
        case .familiar:   return "익숙불"
        case .solid:      return "단단불"
        case .miraculous: return "내몸불"
        }
    }

    // 2. 메인 메시지
    var mainMessage: String {
        switch type {
        case .starting:   return "시작이 반! 이제 막 타오른 귀한 불꽃이에요."
        case .enduring:   return "포기하고 싶을 때 잘 버텨낸 대견한 불꽃입니다."
        case .familiar:   return "안 하면 허전할 정도로 익숙해진 불꽃이네요."
        case .solid:      return "어떤 유혹에도 흔들리지 않는 단단한 불꽃입니다."
        case .miraculous: return "내 몸의 일부가 된 기적의 불꽃이 완성되었어요!"
        }
    }

    // 3. 서브 메시지 (이제 함수가 아닌 프로퍼티!)
    var subMessage: String {
        switch type {
        case .starting:
            return "작심삼일 고비까지 딱 \(4 - count)일 남았어요!"
        case .enduring:
            return "뇌가 기억하기 시작하는 11일까지 \(11 - count)일 더!"
        case .familiar:
            return "습관이 뿌리 내리는 31일까지 \(31 - count)일 남았네요."
        case .solid:
            return "기적의 66일까지 이제 \(66 - count)일뿐이에요. 거의 다 왔어요!"
        case .miraculous:
            return "이제 이 습관은 당신의 정체성입니다. 정말 자랑스러워요!"
        }
    }
    
    var fontSize: CGFloat {
        switch type {
        case .starting: return 30
        case .enduring: return 45
        case .familiar: return 60
        case .solid: return 80
        case .miraculous: return 100
        }
    }
}
