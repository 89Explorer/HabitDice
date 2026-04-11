//
//  HomeView.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/11/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    
    // MARK: - 프로퍼티
    @State private var currentDate: Date = .init()

    @Query(sort: \Habit.createdAt) private var habit: [Habit]
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.secondarySystemBackground).ignoresSafeArea()
            
                VStack {
                    ScrollView(.vertical) {
                        homeHeaderView()
                        
                        habitListview()
                        
                        ForEach(habit) { item in
                            habitStatusRow(habit: item)
                        }
                        
                    }
                    
                }
                .padding(20)
            }
        }
    }
    
    
    @ViewBuilder
    func homeHeaderView() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(currentDate.formatted(date: .abbreviated, time: .omitted))
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("주사위를 획득하세요 🎲")
                .font(.title2)
                .fontWeight(.bold)
        }
        .hSpacing(.leading)
        .vSpacing(.topLeading)
    }
    
    @ViewBuilder
    func habitListview() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("오늘의 습관")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            ForEach(habit) { item in
                triggerCardView(habit: item)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    Color(.systemBackground)
                )
        )
    }
    
    @ViewBuilder
    func triggerCardView(habit: Habit) -> some View {
        
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(habit.selectedTriggerAction ?? "")
                    .font(.caption)
                    .foregroundStyle(Color(.systemBlue))
                
                HStack(spacing: 12) {
                    Text(habit.emoji)
                        .font(.body)
                        .fontWeight(.bold)
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemBlue).opacity(0.15))
                        )
                    
                    Text(habit.title)
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(.label))
                }
            }
            
            Spacer()
            
            Button {
                
            } label: {
                ZStack {
                    Color(.systemBlue)
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(Color(.systemGray5), lineWidth: 1)
                        }
                    Image(systemName: "checkmark")
                        .font(.system(size: 20))
                        .foregroundStyle(Color(.systemBackground))
                }
                    
            }
            
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    Color(.systemBackground)
                )
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    Color(.systemGray)
                )
        }
        .padding(2)
        
    }
    
    
    
    
    @ViewBuilder
    func habitStatusRow(habit: Habit) -> some View {
        GridRow {
            Text(habit.title)
                .font(.body)
                .fontWeight(.medium)
                .gridColumnAlignment(.leading)
            Spacer()
                .gridCellUnsizedAxes(.horizontal)
            ForEach(habit.logs, id: \.self) { item in
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        item.isDone ? Color(.systemBlue).opacity(0.5) : Color.clear
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(
                                Color(.systemGray5), lineWidth: 2
                            )
                    }
                    .frame(width: 16, height: 16)
            }
            
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .sampleDataContainer()
    }
}
