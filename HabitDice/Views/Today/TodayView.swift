//
//  TodayView.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/19/26.
//

import SwiftUI
import SwiftData


struct TodayView: View {
    
    @State private var currentDate: Date = .init()    // 오늘 날짜를 제어하는 변수
    
    @Query(sort: \Habit.createdAt) private var habit: [Habit]    // Swift Data에 저장된 습관 데이터를 생성일 기준으로 불러오는 변수
    @Environment(HabitRepository.self) var habitRepository    // 습관 데이터를 관리하는 매니저 역할
    
    
    
    // MARK: - 필터링된 습관 리스트 (Computed Properties)
    // 오늘 요일에 해당하면서 반복 습관 + 일회성 습관 필터링하여 담는 변수
    private var todayHabits: [Habit] {
        let weekday = Calendar.current.component(.weekday, from: currentDate)
        
        return habit.filter { item in
            // 졸업한 습관은 제외
            guard !item.isArchived else { return false }
            
            let containsWeekday = item.repeatDays.contains(weekday)
            let isCreatedToday = Calendar.current.isDate(item.createdAt, inSameDayAs: currentDate)
            
            // 오늘 요일에 해당하면서 반복 습관 + 일회성 습관
            if containsWeekday {
                return item.isRepeatOn ? true : isCreatedToday
            }
            
            // 졸업은 안 했지만, 오늘 요일이 아닌 습관들에 대비
            return false
        }
    }
    
    // 오늘 해야하는 습관의 갯수
    private var todayHabitCount: Int {
        return todayHabits.count
    }
    
    // 완료된 습관 갯수
    private var todayCompletedCount: Int {
        return todayHabits.filter { habit in
            habit.isCompletedOnDay(on: currentDate)
        }.count
    }
    
    // 진행률 (ProgressView 용)
    private var progress: Double {
        guard !todayHabits.isEmpty else { return 0 }
        return Double(todayCompletedCount) / Double(todayHabitCount)
    }
    
    
    // 연속일 계산 프로퍼티
    private var currentStreak: Int {
        var streak = 0
        var daysAgo = 0
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: currentDate)
        
        // 기록이 끊길 때까지 무한히 과거로 탐색
        while true {
            guard let dateToCheck = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { break }
            
            // 1. 해당 날짜에 해야 할 습관 필터링
            let habitsOnThatDay = habit.filter { h in
                let weekday = calendar.component(.weekday, from: dateToCheck)
                let isRepeatDay = h.repeatDays.contains(weekday)
                let isCreatedBefore = calendar.startOfDay(for: h.createdAt) <= dateToCheck
                return !h.isArchived && isRepeatDay && isCreatedBefore
            }
            
            // 2. 쉬는 날이면 카운트 유지하고 계속 진행
            if habitsOnThatDay.isEmpty {
                daysAgo += 1
                continue
            }
            
            // 3. 습관이 있는 날 완료 여부 확인
            let isDone = habitsOnThatDay.contains { h in
                h.logs.contains { log in
                    calendar.isDate(log.date, inSameDayAs: dateToCheck) && log.isDone
                }
            }
            
            if isDone {
                streak += 1
                daysAgo += 1
            } else {
                // 오늘(daysAgo == 0)인데 아직 안 한 거면 계속 탐색,
                // 하지만 과거 날짜인데 안 한 거면 여기서 스트릭 종료!
                if daysAgo > 0 { break }
                daysAgo += 1
            }
            
            // 안전장치: 혹시 모를 무한 루프 방지 (예: 10년치)
            if daysAgo > 3650 { break }
        }
        return streak
    }
    
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                
                Color(.blue).opacity(0.1).ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    todayHeaderView
                        .padding(.top, 12)
                        .padding(.horizontal, 20)
                    
                    todayHabitListView
                        .padding(.top, 12)
                        .padding(.horizontal, 20)
                    
                    WeeklyFlowView
                        .padding(.top, 12)
                        .padding(.horizontal, 20)
                    
                    habitInventoryView
                        .padding(.top, 12)
                        .padding(.horizontal, 20)
                }
            }
            .navigationTitle("✨오늘 하루도 힘내세요")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        print("달력 탭")
                    } label: {
                        Image(systemName: "calendar")
                    }
                }
            }
        }
        
    }
    
    
    // MARK: - 화면 헤더뷰 (오늘 날짜 + 오늘 습관 갯수 안내 멘트 + 진행바 + 데이터 유무에 따른 안내문구 적용)
    private var todayHeaderView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(currentDate.formatted(date: .complete, time: .omitted))
                .font(.caption)
                .foregroundStyle(.secondary)
                .fontWeight(.semibold)
            
            // 메인 메시지 분기 처리
            let titleMessage: String = {
                if habit.isEmpty { return "환영합니다!\n첫 습관을 만들어 보세요 🎉" }
                if todayHabits.isEmpty {  return "오늘은 쉬는 날이에요 ☕️" }
                return "오늘 \(todayHabitCount)개의 습관이\n기다리고 있어요 🎯"
            }()
            
            ColoredText(
                originalText: titleMessage,
                coloredText: "\(todayHabitCount)",
                originalFont: .subheadline,
                coloredFont: .headline)
                .fontWeight(.bold)
            
            // 진행 바 영역 분기 처리
            if !todayHabits.isEmpty {
                HStack {
                    ProgressView(value: progress)
                        .tint(.blue)
                    
                    ColoredText(
                        originalText: "\(todayCompletedCount) / \(todayHabitCount) 완료",
                        coloredText: "\(todayCompletedCount)",
                        originalFont: .caption2,
                        coloredFont: .callout
                    )
                    .fontWeight(.medium)
                }
            } else {
                // 습관이 없을 떄는 진행 바 대신 따뜻한 문구 하나 더 축 ㅏ
                Text(habit.isEmpty ? "아래 버튼을 눌러 시작해보세요!" : "재충전 후 내일부터 다시 달려봐요!")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
        }
        .hSpacing(.leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    Color(.systemBackground)
                )
        )
    }
    
    
    // MARK: - 오늘 습관 리스트뷰 (오늘 요일에 맞는 반복 또는 일회성 습관 리스트 + 완료 체크 가능 + 데이터 유무에 따른 안내문구 적용)
    private var todayHabitListView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("오늘의 습관")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                
                if habit.isEmpty {
                    emptyHabitView(
                        icon: "plus.circle",
                        message: "아직 습관이 없네요 🌱",
                        subMessage: "첫 번째 습관을 만들어, 작은 변화를 시작해보세요 🍀"
                    )
                } else if todayHabits.isEmpty {
                    emptyHabitView(
                        icon: "moon.stars",
                        message: "오늘은 쉬어가는 날이에요 🌙",
                        subMessage: "내일의 습관을 위해 충분히 쉬세요 ☁️"
                    )
                } else {
                    ForEach(todayHabits) { item in
                        habitCardView(item)
                        
                        Divider()
                    }
                }
            }
            .hSpacing(.leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        Color(.systemBackground)
                    )
            )
        }
    }
    
    
    // MARK: - 오늘 습관 행 뷰 (리스트 내부에 개발 습관을 보여주는 카드 형태의 뷰)
    private func habitCardView(_ habit: Habit) -> some View {
        // 오늘 날짜 완료 여부
        let isTodayDone = habit.logs.contains {
            Calendar.current.isDate($0.date, inSameDayAs: currentDate) && $0.isDone
        }
        
        return ZStack { // 최상위 계층을 ZStack으로 묶음
            // 메인 카드 뷰
            VStack(alignment: .leading, spacing: 8) {
                Text(habit.selectedTriggerAction ?? "트리거가 없어요 😅")
                    .font(.caption)
                    .foregroundStyle(.blue)
                    .fontWeight(.medium)
                
                HStack {
                    
                    // 습관 이모지
                    ZStack {
                        Color.blue.opacity(0.05)
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        Text(habit.emoji)
                            .font(.system(size: 24))
                    }
                    
                    // 습관 타이틀 및 진행도
                    VStack(alignment: .leading, spacing: 4) {
                        Text(habit.title)
                            .font(.body)
                            .fontWeight(.bold)
                        
                        // 주간 달성 횟수 표시
                        ColoredText(
                            originalText: "\(habit.logs.filter { $0.isDone }.count) / \(habit.repeatDays.count) 이번 주",
                            coloredText: "\(habit.logs.filter { $0.isDone }.count)",
                            originalFont: .caption2,
                            coloredFont: .callout
                        )
                    }
                    
                    Spacer()
                    
                    // 체크 버튼
                    Button  {
                        withAnimation(.spring) {
                            toggleCompletion(for: habit)
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(isTodayDone ? Color.blue : Color.clear)
                                .frame(width: 36, height: 36)
                                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(isTodayDone ? .white : .blue)
                        }
                    }
                    .disabled(isTodayDone)
                }
            }
            .blur(radius: isTodayDone ? 4.0 : 0.0)    // 완료 시 블러 처리
            .opacity(isTodayDone ? 0.6 : 1.0)    // 블러와 함께 투명도 조절 시 더 고급스러움
            
            // --- 다시하기 버튼 (완료 시에만 노출) ---
            if isTodayDone {			
                Button {
                    withAnimation(.spring()) {
                        toggleCompletion(for: habit) // 다시 누르면 false가 됨
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("다시하기")
                    }
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(
                        Capsule()
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 5)
                    )
                    .overlay(Capsule().stroke(Color.blue, lineWidth: 1))
                }
            }
        }
    }
    
    
    // MARK: - 오늘 습관 리스트 또는 습관 자체가 없을 경우 보여줄 emptyView
    private func emptyHabitView(icon: String, message: String, subMessage: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(.blue)
            
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
        .padding(.vertical, 8)
    }
    
    
    // MARK: - 이번 주 흐름을 보여주는 뷰
    private var WeeklyFlowView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("이번 주 흐름")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 12) {
                HStack(alignment: .top) {
                    ForEach(DayOfWeek.allCases) { day in
                        // 전체 습관 리스트
                        dayProgressColumn(day: day, habits: habit)
                    }
                }
                
                Divider()
                
                streakStatusView
               
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        Color(.systemBackground)
                    )
            )
        }

    }
    
    
    // MARK: - 요일 별 완료 습관 건수 / 전체 습관 건수를 표시하는 뷰 (이번 주 흐름 뷰에서 사용)
    private func dayProgressColumn(day: DayOfWeek, habits: [Habit]) -> some View {
        // 해당 요일에 해야 할 전체 습관 필터링
        let totalHabitsForDay = habits.filter { $0.repeatDays.contains(day.rawValue) }.count
        
        // 해당 요일에 완료한 습관 개수 계산
        // 이번주 리스트이므로 logs 내의 요일 정보와 매칭
        let completedHabitsForDay = habits.reduce(0) { count, habit in
            let doneInDay = habit.logs.contains { log in
                // 로그의 날짜가 이 요일(day)와 일치하고 완료되었는지 확인
                Calendar.current.component(.weekday, from: log.date) == day.rawValue && log.isDone
            }
            return count + (doneInDay ? 1 : 0)
        }
        
        // 오늘 여부 확인
        let isToday = Calendar.current.component(.weekday, from: currentDate) == day.rawValue
        
        // 달성률 (0.0 ~ 1.0)
        let rate = totalHabitsForDay > 0 ? Double(completedHabitsForDay) / Double(totalHabitsForDay) : 0.0
        
        return VStack(spacing: 8) {
            // 요일 레이블
            Text(day.label)
                .font(.caption)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundStyle(isToday ? Color.yellow : Color.secondary)
                
            // 원형 게이지 (Bottom-up Fill)
            ZStack(alignment: .center) {
                ZStack(alignment: .bottom) {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(Color.blue, lineWidth: 1.0))
                    
                    // 아래에서 위로 차오르는 파란색 원
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 40, height: min(40 * rate, 40))
                }
                .clipShape(Circle())
                
                // 완료 숫자
                Text("\(completedHabitsForDay)")
                    .font(isToday ? .title3 : .callout)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundStyle(.primary)
            }
            
            // 하단 상태 텍스트
            Group {
                if isToday {
                    Text("진행중")
                        .foregroundStyle(.yellow)
                        .fontWeight(.bold)
                } else if totalHabitsForDay == 0 {
                    Text("없음")
                        .foregroundStyle(.secondary)
                } else {
                    Text("\(totalHabitsForDay)개")
                        .foregroundStyle(.secondary)
                }
            }
            .font(.footnote)
        }
        .hSpacing(.center)
    }
    
    
    // MARK: - 연속 일에 대한 안내멘트를 보여주는 뷰 (이번 주 흐름 뷰에서 사용)
    private var streakStatusView: some View {
        
        // 현재 연속일을 넣어 StreakLevel 인스턴스 생성
        let level = StreakLevel(count: currentStreak)
        
        return HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.red)
                    
                    ColoredText(
                        originalText: "\(currentStreak) 일 연속",
                        coloredText: "\(currentStreak)",
                        originalFont: .caption,
                        coloredFont: .title3
                    )
                        .fontWeight(.bold)
                }
                
                // 연속 일수에 따른 메시지 출력
                Text(level.mainMessage)
                    .font(.footnote)
                    .foregroundStyle(.primary)
                
                Text(level.subMessage)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange.opacity(0.1))
                    )
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Text("🔥")
                    .font(.system(size: level.fontSize))
                    .phaseAnimator([0, 1]) { content, phase in
                            content
                                .scaleEffect(phase == 1 ? 1.05 : 0.95) // 살짝 커졌다 작아졌다
                                .offset(y: phase == 1 ? -3 : 0)        // 위아래로 일렁임
                        } animation: { phase in
                            .easeInOut(duration: 1.0).repeatForever(autoreverses: true)
                        }
                
                
                Text(level.name)
                    .font(.footnote)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.orange.opacity(0.2)))
                    .foregroundStyle(.orange)
            }
            
        }
        .hSpacing(.leading)
    }
    
    
    // MARK: - 전체 습관 리스트 뷰 (반복 습관, 일회성 습관 갯수 표시)
    private var habitInventoryView: some View {
        // 필요한 데이터 확인
        let activeHabits = habit.filter { !$0.isArchived }
        let archivedCount = habit.filter { $0.isArchived }.count
        let status = HabitStatus(
            activeCount: activeHabits.count,
            archivedCount: archivedCount
        )
        
        return VStack(alignment: .leading, spacing: 4) {
            Text("습관 인벤토리")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 12) {
                
                ColoredText(
                    originalText: "지금까지 총 \(habit.count) 개의 습관과 함께하고 있어요",
                    coloredText: "\(habit.count)",
                    originalFont: .subheadline,
                    coloredFont: .headline
                )
                
                // 전체 및 진행 중 습관
                VStack(alignment: .leading, spacing: 8) {
                    ColoredText(
                        originalText: "오늘도 함께 달리는 습관 🎯 \(activeHabits.count) 개",
                        coloredText: "\(activeHabits.count)",
                        originalFont: .caption,
                        coloredFont: .title3
                    )
                    
                    Text(status.activeMessage)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange.opacity(0.1))
                        )
                        //.fixedSize(horizontal: false, vertical: false)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    ColoredText(
                        originalText: "내 몸에 완벽히 배어 졸업한 습관 🎓 \(archivedCount) 개",
                        coloredText: "\(archivedCount) ",
                        originalFont: .caption,
                        coloredFont: .title3
                    )
                    
                    Text(status.archivedMessage)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange.opacity(0.1))
                        )
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
        
    }
    
    
    // MARK: - 습관 완료 버튼
    private func toggleCompletion(for habit: Habit) {
        // 시간 정보를 제외한 오늘 날짜의 시작점 (00:00:00)
        let targetDate = Calendar.current.startOfDay(for: currentDate)
        
        // 해당 날짜의 기존 습관 기록 검색
        if let existingLog = habit.logs.first(where: { Calendar.current.isDate($0.date, inSameDayAs: targetDate) }) {
            // 이미 기록이 있다면 상태만 반전
            existingLog.isDone.toggle()
        } else {
            // 기록이 없다면 새로 생성
            let newHabitLog = HabitLog(
                date: targetDate,
                isDone: true,
                completedCount: habit.logs.filter { $0.isDone }.count + 1
            )
            
            // 관계에 추가
            habit.logs.append(newHabitLog)
        }
    }
}

#Preview {
    TodayView()
        .sampleDataContainer()
}


#Preview("빈 데이터") {
    let repository = HabitRepository(isInMemoryOnly: false)
    
    NavigationStack {
        TodayView()
            .environment(repository)
            .modelContainer(repository.modelContainer)
    }
}
