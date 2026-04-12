//
//  HabitRepository.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/3/26.
//

import Foundation
import SwiftData
import SwiftUI


@Observable
@MainActor    // UI 관련된 mainContext 사용을 위해 추가
class HabitRepository {
    
    let modelContainer: ModelContainer
    let notificationRepository: NotificationRepository
    
    
    var context: ModelContext {
        modelContainer.mainContext
    }
    
    init(isInMemoryOnly: Bool = false) {
        let schema = Schema([
            Habit.self,
            HabitLog.self,
            Notification.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isInMemoryOnly)
        
        do {

            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            notificationRepository = NotificationRepository(modelContainer: modelContainer)
            
            if isInMemoryOnly {
                try loadSampleHabits()
            }
            
        } catch {
            
            print("데이터베이스 초기화 실패: \(error.localizedDescription)")
            fatalError("저장소를 열 수 없습니다.")
        }
    }
    
    func insert(_ model: some PersistentModel) {
        context.insert(model)
    }

    func save() {
        try? context.save()
    }
    
    private func loadSampleHabits() throws {
        for habit in Habit.sampleData {
            context.insert(habit)
        }
        
        for habitLog in Habit.sampleDataWithLogs {
            context.insert(habitLog)
        }
    }
    
}


private let sampleContainer = HabitRepository(isInMemoryOnly: true)

extension View {
    func sampleDataContainer() -> some View {
        self.environment(sampleContainer)
            .modelContainer(sampleContainer.modelContainer)
    }
}
