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
    @State private var isPresentingCreateView: Bool = false
    
    
    @Query(sort: \Habit.createdAt) private var habit: [Habit]
    @Environment(HabitRepository.self) var habitRepository
    
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.secondarySystemBackground).ignoresSafeArea()
                
                VStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        homeHeaderView()
                        
                        habitListView()
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
            .overlay(alignment: .bottomTrailing) {
                Button {
                    isPresentingCreateView.toggle()
                } label: {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(Color.blue.shadow(.drop(color: .gray.opacity(0.50), radius: 5, x: 5, y: 5)), in: .circle)
                    
                }
                .padding(15)
                
            }
            .fullScreenCover(isPresented: $isPresentingCreateView) {
                HabitCreateContainerView()
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
    func habitListView() -> some View {
                
        // 필터링 로직 강화
        // 1회성 습관 (반복 여부 -> false)과 n회성 습관 (반복 여부 -> true) 구분
        let todayHabits = habit.filter { item in
            guard !item.isArchived else { return false }
            
            let weekday = Calendar.current.component(.weekday, from: currentDate)
            let containsWeekday = item.repeatDays.contains(weekday)
            let isCreatedToday = Calendar.current.isDate(item.createdAt, inSameDayAs: currentDate)
            
            // 1. 일단 오늘 요일에 해당하는 습관인가?
            if containsWeekday {
                if item.isRepeatOn {
                    // 반복 습관이면 요일만 맞으면 OK
                    return true
                } else {
                    // 일회성 습관이면 '오늘 만든 것'인지까지 확인
                    return isCreatedToday
                }
            }
            
            // "졸업은 안 했지만, 오늘 요일이 아닌" 습관들에 대비
            return false
        }
        
        
        VStack(alignment: .leading, spacing: 4) {
            Text("오늘, 도전할 습관을 선택하세요😙")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(Color(.secondaryLabel))
                .padding(.horizontal, 4)
            
  
            if habit.isEmpty {
                emptyHabitView(
                    icon: "plus.circle",
                    message: "아직 습관이 없네요 🌱",
                    subMessage: "첫 번째 습관을 만들어, 작은 변화를 시작해보세요 🍀"
                )
                .onTapGesture {
                    isPresentingCreateView = true
                }
            } else if todayHabits.isEmpty {
                emptyHabitView(
                    icon: "moon.stars",
                    message: "오늘은 쉬어가는 날이에요 🌙",
                    subMessage: "내일의 습관을 위해 충분히 쉬세요 ☁️"
                )
            } else {
                ForEach(todayHabits) { item in
                    NavigationLink {
                        DetailHabit(habit: item)
                    } label: {
                        habitCardView(habit: item)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(
                    Color(.systemBackground)
                )
        )
        .hSpacing(.leading)
    }
    
    @ViewBuilder
    func habitCardView(habit: Habit) -> some View {
        
        let isTodayDone = habit.logs.first { Calendar.current.isDateInToday($0.date) }?.isDone ?? false
        
        ZStack {
            
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
                    toggleHabitLog(for: habit)
                } label: {
                    ZStack {
                        Color(isTodayDone ? Color(.systemBlue) : Color(.systemBackground))
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())
                            .overlay {
                                Circle()
                                    .stroke(Color(.systemBlue), lineWidth: 2)
                            }
                        Image(systemName: "checkmark")
                            .font(.system(size: 20))
                            .foregroundStyle(Color(.systemBackground))
                    }
                    
                }
                
            }
            .padding(16)
            
            // 완료 시 카드 내용을 블러 처리
            .blur(radius: isTodayDone ? 3.0 : 0)
            
            if isTodayDone {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemBackground).opacity(0.5))
                
                Button {
                    toggleHabitLog(for: habit)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("다시하기")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(Color(.systemBlue))
                    .padding(16)
                    .background(
                        Capsule()
                            .fill(Color(.systemBackground))
                            .overlay {
                                Capsule()
                                    .stroke(Color(.systemBlue), lineWidth: 2)
                            }
                    )
                }
            }
            
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
        .animation(.easeInOut(duration: 0.15), value: isTodayDone)
        .padding(2)
        
    }
    
    @ViewBuilder
    func emptyHabitView(icon: String, message: String, subMessage: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundStyle(Color(.systemBlue).opacity(0.6))
            
            Text(message)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color(.label))
            
            Text(subMessage)
                .font(.caption)
                .foregroundStyle(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
        }
        .hSpacing(.center)
        .padding(.vertical, 32)
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
                    VStack(spacing: 4) {
                        
                        Text(Date().weekRangeTitle(from: firstDate))
                            .font(.subheadline)
                            .fontWeight(.regular)
                            .foregroundStyle(Color(.systemBlue))
                        
                        Text("(\(firstDate.format("M/d")) - \(lastDate.format("M/d")))")
                            .font(.caption)
                            .foregroundStyle(Color(.secondaryLabel))
                        
                    }
                }
            }
            .padding(.horizontal, 4)
            
            if habit.isEmpty {
                emptyHabitView(
                    icon: "chart.bar",
                    message: "아직 기록할 습관이 없어요 🎯",
                    subMessage: "습관을 추가하면, 이곳에서 주간 현황을 확인할 수 있어요 📊")
            } else {
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
    
    
    func toggleHabitLog(for habit: Habit) {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let existingLog = habit.logs.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today)
        }) {
            existingLog.isDone.toggle()
        } else {
            let newLog = HabitLog(
                date: today,
                isDone: true,
                completedCount: habit.logs.filter { $0.isDone }.count + 1
            )
            habit.logs.append(newLog)
            habitRepository.insert(newLog)
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .sampleDataContainer()
    }
}


#Preview("빈 데이터") {
    let repository = HabitRepository(isInMemoryOnly: false)
    
    NavigationStack {
        HomeView()
            .environment(repository)
            .modelContainer(repository.modelContainer)
    }
}
