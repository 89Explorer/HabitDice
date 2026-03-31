//
//  TriggerData.swift
//  HabitDice
//
//  Created by kwonjungguen on 3/31/26.
//

import Foundation


let recommendedTriggers: [Trigger] = [
    Trigger(
        title: "🔄 일상 고정 루틴",
        subTitle: "이미 하고 있는 일, 일상의 닻",
        items: [
            "양치질을 마쳤을 때",
            "커피 첫 모금을 마실 때",
            "컴퓨터 전원을 켰을 때",
            "신발을 벗어 현관에 두었을 때",
            "설거지를 마치고 손을 닦을 때"
        ]
    ),
    Trigger(
        title: "📍 장소 및 환경",
        subTitle: "특정 장소에서, 공간의 신호",
        items: [
            "현관문을 열고 들어왔을 때",
            "내 책상 의자에 앉았을 때",
            "엘리베이터를 기다릴 때",
            "카페에 자리를 잡았을 때",
            "침대에 눕기 직전"
        ]
    ),
    Trigger(
        title: "⏰ 하루의 마디",
        subTitle: "시간의 신호, 골든 타임",
        items: [
            "눈을 뜨자마자 (기상 직후)",
            "점심 식사 후 나른할 때",
            "퇴근 10분 전",
            "오후 4시, 집중력이 떨어질 때",
            "내일 옷을 미리 챙길 때 (취침 전)"
        ]
    ),
    Trigger(
        title: "⚡️ 내 몸의 신호",
        subTitle: "기분 전환이 필요할 때",
        items: [
            "스마트폰을 목적 없이 켰을 때",
            "뒷목이 뻐근하다고 느낄 때",
            "머릿속이 복잡해질 때",
            "단 것이 먹고 싶어질 때",
            "회의가 끝나고 한숨 돌릴 때"
        ]
    )
]
