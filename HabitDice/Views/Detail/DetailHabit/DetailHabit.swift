//
//  DetailHabit.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/13/26.
//

import SwiftUI
import SwiftData



struct DetailHabit: View {
    
    
    @Bindable var habit: Habit
    
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(Color(.secondarySystemBackground)).ignoresSafeArea()
            
            VStack(spacing: 0) {
                heroSection
            }
            
        }
    }
    
    @ViewBuilder
    private var heroSection: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        Color(.systemBlue).opacity(0.5)
                    )
                    .frame(width: 84, height: 84)
                
                Text(habit.emoji)
                    .font(.system(size: 42))
                    .foregroundStyle(.primary)
            }
            
            Text(habit.title)
                .font(.title)
                .fontWeight(.bold)
            
            let startDate = "\(habit.createdAt.formatted(.dateTime.year().month().day()))부터 -"
            Text(startDate)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        DetailHabit(habit: .detailSample)
            .sampleDataContainer()
    }
}
