//
//  GraduationPopupView.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/14/26.
//

import SwiftUI


struct GraduationPopupView: View {
    
    let habit: Habit
    let onDismiss: () -> Void
    
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        
        ZStack {
            Color(.clear).ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("🎉")
                    .font(.system(size: 48))
                    .padding(.bottom,12)
                
                Text("졸업을 축하해요!")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)
                
                Text("\(habit.title)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                Color(.systemBlue).opacity(0.15)
                            )
                    )
                
                    .padding(.bottom, 20)
                
                HStack(spacing: 0) {
                    statItem(value: "\(habit.daysSinceCreation)회", label: "도전 횟수")
                    Divider().frame(height: 40)
                    statItem(value: "\(habit.monthlyCompletedCount)회", label: "완료 횟수")
                    Divider().frame(height: 40)
                    statItem(value: "\(habit.currentStreak)일", label: "연속 달성")
                    Divider().frame(height: 40)
                    statItem(value: "\(habit.monthlyAchievementRate)%", label: "달성률")
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            Color(.systemBackground)
                        )
                )
                .padding(.bottom, 12)
                
                Button {
                    onDismiss()
                } label: {
                    Text("메인으로 돌아가기")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.accentColor)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        Color(.systemBackground)
                    )
            )
            .padding(.horizontal, 12)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    scale = 1.0
                    opacity = 1.0 
                }
            }
        }
        
    }
    
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .hSpacing(.center)
    }
}

#Preview {
    GraduationPopupView(
        habit: .detailSample,
        onDismiss: {}
    )
}
