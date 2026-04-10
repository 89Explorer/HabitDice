//
//  HabitDiceApp.swift
//  HabitDice
//
//  Created by kwonjungguen on 3/29/26.
//

import SwiftUI
import SwiftData


@main
struct HabitDiceApp: App {
    
    // 앱의 생명주기 동안 딱 한 번만 생성되도록 @State로 선언
    @State private var habitRepository = HabitRepository()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(habitRepository)
            
        }
        .modelContainer(habitRepository.modelContainer)
    }
}
