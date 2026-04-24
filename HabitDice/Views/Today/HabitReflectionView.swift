//
//  HabitReflectionView.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/22/26.
//

import SwiftUI
import SwiftData


struct HabitReflectionView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(HabitRepository.self) var habitRepository
    
    let habit: Habit
    let targetDate: Date
    
    // 선택된 상태값 관리
    @State private var selectedMood: Mood = .happy
    @State private var selectedTagIds: Set<String> = []
    @State private var memo: String = ""
    
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 12) {
                
                reflectHeaderView
                reflectMoodView
                reflectTagView
                
            }
        }
    }
    
    // MARK: 회고 헤더 뷰 (습관 이모지 + 습관 타이틀 + 습관 트리거)
    private var reflectHeaderView: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Color.white.opacity(0.5)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Text(habit.emoji)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text(habit.selectedTriggerAction ?? "아침에 일어날 때")
                    .font(.system(size: 12))
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .hSpacing(.leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.05))
            //                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
            //                .shadow(color: .white.opacity(0.9), radius: 1, x: 0, y: -1)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
    
    
    // MARK: 회고 습관을 어떻게 느꼈는지 확인하는 뷰
    private var reflectMoodView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("오늘 이 습관, 어떻게 느껴졌어요?")
                .font(.system(size: 14))
                .fontWeight(.black)
                .foregroundStyle(.secondary)
            
            HStack(alignment: .center) {
                
                ForEach(Mood.allCases, id:\.self) { m in
                    
                    let isSelected = selectedMood == m
                    
                    Button {
                        withAnimation(.easeInOut) {
                            selectedMood = m
                        }
                    } label: {
                        VStack(alignment: .center, spacing: 12) {
                            Text(m.rawValue)
                                .font(.system(size: 24))
                            Text(m.description)
                                .font(.system(size: 12))
                                .fontWeight(.bold)
                                .foregroundStyle(isSelected ? .blue : .secondary)
                        }
                        .hSpacing(.center)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isSelected ? Color.blue.opacity(0.05) : Color.gray.opacity(0.05))
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.blue : Color.black.opacity(0.1),
                                        lineWidth: isSelected ? 2 : 0.5)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
    
    
    private var reflectTagView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 4) {
                Text("어떤 점이 그랬나요?")
                    .fontWeight(.black)
                    .foregroundStyle(.secondary)
                    .font(.system(size: 14))
                Text("(복수 선택)")
                    .foregroundStyle(.secondary)
                    .fontWeight(.light)
                    .font(.system(size: 12))
            }
            
            let columns = [GridItem(.adaptive(minimum: 140))]
            
            ScrollView(.vertical){
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(HabitTagData.allTags, id:\.self) { tag in
                        Button {
                            //
                        } label: {
                            HStack(alignment: .center, spacing: 4) {
                                Text(tag.emoji)
                                    .font(.system(size: 12))
                                Text(tag.title)
                                    .font(.system(size: 12))
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
}

#Preview {
    HabitReflectionView(habit: Habit(
        title: "물 100ml 마시기",
        emoji: "💧",
        createdAt: .init(),
        isArchived: false,
        isRepeatOn: false,
        repeatDays: [1],
        isAlarmOn: false,
        logs: []),
                        targetDate: .init()
    )
    .sampleDataContainer()
}
