//
//  MainView.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/2/26.
//

import SwiftUI

struct MainView: View {
    
    @State private var currentDate: Date = .init()
    @State private var progress = 0.75
    
    var body: some View {
        VStack(alignment: .leading) {
            HeaderView(
                title: "오늘의 습관",
                subTitle: currentDate.formatted(date: .abbreviated, time: .omitted)
            )
            
            todayProcessView()
                .shadow(
                    color: Color.gray.opacity(0.25), radius: 3, x: 0, y: 3
                )
            
            availableTriggerView()
                .shadow(
                    color: Color.gray.opacity(0.25), radius: 3, x: 0, y: 3
                )
            
            
        }
        .vSpacing(.top)
        .padding(.horizontal, 12)
    }
    
    
    @ViewBuilder
    func todayProcessView() -> some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Text("오늘 진행")
                    .font(.headline)
                Spacer()
                Text("2 / 3 완료")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: progress)
                .tint(.blue)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    Color(uiColor: .systemBackground)
                )
        )
    }
    
    @ViewBuilder
    func availableTriggerView() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("지금 가능한 트리거")
                .font(.headline)
            
            triggerCardView(trigger: "양치질을 마쳤을 때", habit: "제자리 걸음 1분 하기", tag: "🔄 일상", isCompleted: true)
            triggerCardView(trigger: "양치질을 마쳤을 때", habit: "제자리 걸음 1분 하기", tag: "🔄 일상")
            triggerCardView(trigger: "양치질을 마쳤을 때", habit: "제자리 걸음 1분 하기", tag: "🔄 일상")
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    Color(uiColor: .systemBackground)
                )
        )
    }
    
    @ViewBuilder
    func triggerCardView(trigger: String, habit: String, tag: String, isCompleted: Bool = false) -> some View {
        HStack(alignment: .center, spacing: 16) {
            
            VStack(alignment: .leading, spacing: 6) {
                Text(trigger)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 4) {
                    Image(systemName: "arrow.right")
                        .font(.caption2.bold())
                        .foregroundStyle(.secondary)
                    Text(habit)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Text(tag)
                .font(.caption)
                .fontWeight(.bold)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    Capsule()
                        .fill(Color.accentColor.opacity(0.12))
                )
                .foregroundColor(.accentColor)
        }
        .padding(.all, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isCompleted ? Color.blue.opacity(0.10) : Color(uiColor: .secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                )
        )
    }
    
//    @ViewBuilder
//    func triggerCardView(trigger: String, habit: String, tag: String) -> some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 4) {
//                Text(tag)
//                    .font(.caption)
//                    .foregroundStyle(.primary)
//                    .padding(8)
//                    .background(
//                        RoundedRectangle(cornerRadius: 12)
//                            .fill(
//                                Color.accentColor.opacity(0.15)
//                            )
//                    )
//                
//                Text("\(trigger) \n ➡️ \(habit)")
//                    .font(.title3)
//                    .foregroundStyle(.primary)
//                    .padding(8)
//                    .lineHeight(.loose)
//            }
//            
//            Spacer()
//            
//            Image(systemName: "play.circle.fill")
//                .font(.title)
//                .foregroundStyle(Color.accentColor)
//
//        }
//        .padding(.horizontal, 12)
//        .padding(.vertical, 12)
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(
//                    Color(uiColor: .lightGray.withAlphaComponent(0.15))
//                )
//        )
//
//    }
    
}

#Preview {
    ContentView()
}


