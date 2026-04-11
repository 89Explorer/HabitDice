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
    @State private var weekSlider: [Date.WeekDay] = []
    

    @Query(sort: \Habit.createdAt) private var habit: [Habit]
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.secondarySystemBackground).ignoresSafeArea()
            
                VStack {
                    ScrollView(.vertical) {
                        homeHeaderView()
                        
                        habitListview()
                            .padding(.top, 12)
                        
                        weeklyHabitStatus()
                            .padding(.top, 12)

                    }
                    
                }
                .padding(20)
            }
            .onAppear {
                if weekSlider.isEmpty {
                    let currentWeek = Date().fetchWeek()
                    weekSlider = currentWeek
                }
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
            Text("습관 목록 😙")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(Color(.secondaryLabel))
                .padding(.horizontal, 4)
            
            ForEach(habit) { item in
                triggerCardView(habit: item)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 32)
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
        .padding(16)
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
    func weeklyHabitStatus() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // 헤더
            HStack(alignment: .firstTextBaseline) {
                Text("주간 현황 📊")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(.secondaryLabel))
                
                Spacer()
                
                // 이번주 날짜 범위를 "4월 1주차"
                if let firstDate = weekSlider.first?.date,
                   let lastDate = weekSlider.last?.date {
                    HStack(spacing: 4) {
                        Text(Date().weekRangeTitle(from: firstDate))
                            .font(.caption)
                            .fontWeight(.regular)
                            .foregroundStyle(Color(.systemBlue))
                        Text("(\(firstDate.format("M/d")) - \(lastDate.format("M/d")))")
                            .font(.caption)
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                }
            }
            .padding(.horizontal, 4)
            
            GeometryReader { geo in
                let totalWidth = geo.size.width
                let titleWidth = totalWidth * 0.5
                let daysWidth = totalWidth * 0.5
                let dayCount = CGFloat(weekSlider.count) // 7
                let cellSize = daysWidth / dayCount
                
                VStack(spacing: 8) {
                    
                    HStack(spacing: 0) {
                        Text("")
                            .frame(width: titleWidth, alignment: .leading)
                        
                        ForEach(weekSlider) { day in
                            let isToday = Calendar.current.isDateInToday(day.date)
                            Text(day.date.format("E"))
                                .font(.body)
                                .fontWeight(isToday ? .bold : .regular)
                                .foregroundStyle(isToday ? Color(.systemBlue) : Color(.secondaryLabel))
                                .frame(width: cellSize)
                            
                        }
                    }
                    
                    Divider()
                    
                    // 습관별 행
                    ForEach(habit) { item in
                        HStack( spacing: 0) {
                            // 습관 타이틀
                            Text(item.title)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .frame(width: titleWidth, alignment: .leading)
                        
                            // logs를 weekSlider의 각 날짜에 맞는 log를 찾아서 표시
                            ForEach(weekSlider) { day in
                                let matchedLog = item.logs.first {
                                    Calendar.current.isDate($0.date, inSameDayAs: day.date)
                                }
                                logCell(isDone: matchedLog?.isDone ?? false, cellSize: cellSize)
                            }
                        }
                        .hSpacing(.leading)
                    }
                }
            }
            .frame(height: CGFloat(habit.count) * 28 + 40)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color(.systemBackground))
        )

        
    }
    
    // 로그 셀
    @ViewBuilder
    func logCell(isDone: Bool, cellSize: CGFloat) -> some View {
        ZStack {
            if isDone {
                // 완료 -> systemBlue 채우기 + 체크 아이콘
                //RoundedRectangle(cornerRadius: 8)
                Circle()
                    .fill(Color(.systemBlue))
                    .frame(width: cellSize - 4, height: cellSize - 4)
                Image(systemName: "checkmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(Color(.systemBackground))
            } else {
                // 미완료 -> 연환 회색 테두리만 표시
                //RoundedRectangle(cornerRadius: 8)
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 2)
                    .frame(width: cellSize - 4, height: cellSize - 4)
            }
        }
        .frame(width: cellSize)
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .sampleDataContainer()
    }
}
