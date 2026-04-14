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
    
    
    // MARK: - 계산 프로퍼티
    
    // 습관 생성일로부터 오늘까지 며칠 쨰인지 제어하는 변수
    private var daysSinceCreation: Int {
        Calendar.current.dateComponents([.day], from: habit.createdAt, to: Date()).day ?? 0
    }
    
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(Color(.secondarySystemBackground)).ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        heroSection
                        infoSection
                        statSection
                    }
                }
            }
            
        }
    }
    
    
    // MARK: - 히어로 섹션 (습관 이모지 + 습관 타이틀 + 습관 생성일)
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
            
            let startDate = "\(habit.createdAt.formatted(.dateTime.year().month().day()))부터"
            
            HStack {
                Text(startDate)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Text("D+\(daysSinceCreation)일")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                Color(.systemBlue).opacity(0.5)
                            )
                    )
            }
        }
        .hSpacing(.center)
        .padding(.vertical, 8)
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // 트리거
            infoRow(
                label: "🔫 트리거",
                content: {
                Text(habit.selectedTriggerAction ?? "선택 안함")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.trailing)
                }
            )
            .padding(.top, 12)
            Divider().padding(.horizontal, 24)
            
            // 반복
            infoRow(
                label: "🔄 반복",
                content: {
                    HStack(spacing: 4) {
                        ForEach(DayOfWeek.allCases) { day in
                            let isOn = habit.repeatDays.contains(day.rawValue)
                            
                            Text(day.label)
                                .font(.body)
                                .fontWeight(.bold)
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(
                                            isOn ? Color(.systemBlue).opacity(0.25) : Color(.systemGray5)
                                        )
                                )
                                .foregroundStyle(isOn ? .primary: .secondary)
                        }
                    }
                }
            )
            
            Divider().padding(.horizontal, 24)
            
            infoRow(
                label: "🔔 알람",
                content: {
                    if let time = habit.notification?.time {
                        Text(formattedTime(time))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                    } else {
                        Text("설정 안함")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                    }
                }
            )
            .padding(.bottom, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    Color(.systemBackground)
                )
        )
        .padding(.horizontal, 24)
    }
    
    
    // MARK: - 인포 섹션 공통 행 레이아웃
    @ViewBuilder
    private func infoRow<Content: View>(
        label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            content()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }
    
    private var statSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("이번 달 현황")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.top, 4)
            
            HStack(spacing: 0) {
                statItem(value: "\(habit.monthlyCompletedCount)회", label: "완료 횟수")
                Divider().frame(height: 40)
                statItem(value: "\(habit.currentStreak)일", label: "연속 달성")
                Divider().frame(height: 40)
                statItem(value: "\(habit.monthlyAchievementRate)%", label: "달성률")
            }
            .padding(.vertical, 12)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    Color(.systemBackground)
                )
        )
        .padding(.horizontal, 24)

        
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
    
    
    // MARK: - 인포 섹션 (시간 포맷)
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a hh:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        DetailHabit(habit: .detailSample)
            .sampleDataContainer()
    }
}
