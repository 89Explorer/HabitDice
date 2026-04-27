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
    @Environment(\.scenePhase) var scenePhase    // 앱의 상태 감지 (연속일 체크 목적 - checkYesterdayStreak)
    
    @State private var isPresentingCreateView: Bool = false
    @State private var isPresentingStreakResetView: Bool = false    // 연속일이 깨졌을 떄 보여주는 안내 시트 제어하는 변수
    @State private var lastBrokenStreak: Int = 0    // 깨지기 전 스트릭 저장용
    @State private var isPresentingReflectionView: Bool = false     // 습관 회고 시트를 제어하는 변수
    
    @Namespace private var flame
    
    @AppStorage("currentStreak") private var currentStreak: Int = 0    // 현재 연속일을 저장하는 변수
    @AppStorage("bestStreak") private var bestStreak: Int = 0    // 연속일 중에 최장 연속일을 저장하는 변수
    @AppStorage("hasAcknowledgedReset") private var hasAcknowledgedReset: Bool = false    // 연속일이 깨졌을 경우에 대비한 안내뮤 보이기
    
    
    // MARK: - 필터링된 습관 리스트 (Computed Properties)
    // 오늘 요일에 해당하면서 반복 습관 + 일회성 습관 필터링하여 담는 변수
    private var todayHabits: [Habit] {
        // 데이터가 아예 없으면 즉시 반환하여 연산 낭비 방지
        guard !habit.isEmpty else { return [] }
        
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
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("힘내세요🔥")
            .overlay(alignment: .bottomTrailing) {
                Button {
                    isPresentingCreateView.toggle()
                } label: {
                    // 🔥 디자인 포인트 1: 아이콘과 그라데이션 배경
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold)) // 아이콘을 더 크고 굵게
                        .foregroundStyle(.white)
                        .padding(16) // 정사각형 형태를 위한 여백
                        .background(
                            // 🔥 디자인 포인트 2: 주사위 같은 그라데이션과 둥근 모서리
                            RoundedRectangle(cornerRadius: 16) // 더 둥글게 처리
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(
                                            colors: [Color.blue.opacity(0.2), Color.blue.opacity(0.6), Color.blue]
                                        ),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        // 🔥 디자인 포인트 3: 입체감을 주는 부드러운 그림자
                        //.shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 6)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 24) // 하단 여백 추가로 띄우기
                // 🔥 디자인 포인트 4: 버튼 자체에 호버/인터랙션 효과 추가 (iOS 17+)
                .buttonStyle(DiceButtonStyle())
            }
            .fullScreenCover(isPresented: $isPresentingCreateView) {
                HabitCreateContainerView()
            }
            // onAppear: 사용자가 앱을 완전히 종료 후 새로 킬 떄, 다른 탭에 갔다가 다시 돌아올 떄 실행 됩니다.
            .onAppear {
                checkYesterdayStreak()
            }
            // scenePhase: 백그라운드 복귀 체크, 홈 화면으로 나갔다가 다음 날 돌아오는 경우, onAppear 호출 안될 경우 대비
            .onChange(of: scenePhase) { oldValue, newValue in
                if newValue == .active {
                    // 앱이 백그라운드에 있다가 다시 전면으로 나올 떄 체크
                    checkYesterdayStreak()
                }
            }
            .sheet(isPresented: $isPresentingStreakResetView) {
                StreakResetView(brokenStreak: lastBrokenStreak)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
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
                            habitCardView(item)

                        }
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
                            .foregroundStyle(Color(.label))
                        
                        // 주간 달성 횟수 표시
                        ColoredText(
                            originalText: "\(habit.logs.filter { $0.isDone }.count) / \(habit.repeatDays.count) 이번 주",
                            coloredText: "\(habit.logs.filter { $0.isDone }.count)",
                            originalFont: .caption2,
                            coloredFont: .callout
                        )
                        .fontWeight(.bold)
                        .foregroundStyle(Color(.secondaryLabel))
                    }
                    
                    Spacer()
                    
                    // 체크 버튼
                    Button  {
                        withAnimation(.easeInOut) {
                            toggleCompletion(for: habit)
                            isPresentingReflectionView = true
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
        .sheet(isPresented: $isPresentingReflectionView) {
            HabitReflectionView(habit: habit, targetDate: currentDate)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
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
        
        return HStack(alignment: .center) {
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
                    .id("STREAK_FLAME_\(currentStreak)")    // 상태 유지 목적
                    .phaseAnimator([0, 1]) { content, phase in
                                content
                                    .scaleEffect(phase == 1 ? 1.15 : 1.0, anchor: .bottom)
                                    .offset(y: phase == 1 ? -2 : 0)
                            } animation: { phase in
                                    .easeInOut(duration: 3.0).repeatForever(autoreverses: true)
                            }
                            //.frame(width: level.fontSize * 1.5, height: level.fontSize * 1.5)
                            //.frame(maxHeight: 150) // 불꽃이 움직일 수 있는 충분한 '공간'을 미리 고정
                            .frame(maxWidth: level.fontSize * 1.5, maxHeight: level.fontSize * 1.5)
                            //.contentShape(Rectangle()) // 터치 영역 혹은 레이아웃 안정성 확보
                
                Text(level.name)
                    .font(.footnote)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.orange.opacity(0.2)))
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: true, vertical: false)

            }
            //.frame(minWidth: 80)
            .animation(.none, value: todayHabits.count) // 데이터가 바뀔 때 이 영역은 '튀는' 애니메이션을 하지 않음
            
        }
        //.hSpacing(.leading)
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
                    originalFont: .caption,
                    coloredFont: .title3
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
        
        // 토글 전 오늘 이미 완료된 습관이 하나라도 있는지 체크
        let wasAnytingDoneToday = todayHabits.contains { $0.isCompletedOnDay(on: targetDate) }
        
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
        
        // 토글 후 오늘 완료된 습관이 있는지 다시 체크
        let isAnytingDoneNew = todayHabits.contains { $0.isCompletedOnDay(on: targetDate) }
        
        // 연속일 업데이트
        updateStreakData(from: wasAnytingDoneToday, to: isAnytingDoneNew)
        
    }
    
    
    // MARK: - 연속일을 업데이트 하는 함수 (toggleCompletion함수에서 사용)
    private func updateStreakData(from before: Bool, to after: Bool) {
        if !before && after {
            // 오늘 처음으로 하나 완료 -> 연속일 + 1
            currentStreak += 1
            
            // 새로운 연속일이 시작되면, 나중에 연속일이 깨졌을 때의 알림 받기 위해 값을 리셋
            hasAcknowledgedReset = false
            
            // 최장 기록 갱신 체크
            if currentStreak > bestStreak {
                bestStreak = currentStreak
            }
        } else if before && !after {
            // 오늘 유일하게 완료했던 습관을 취소함 -> 연속일 - 1
            currentStreak = max(0, currentStreak - 1)
        }
    }
    
    
    // MARK: - 연속일을 어제 했는지 여부를 확인하는 함수
    private func checkYesterdayStreak() {
        
        // 이미 확인을 완료한 상태라면 다시 계산하거나 띄울 필요가 없음
        guard !hasAcknowledgedReset else { return }
        
        let calendar = Calendar.current
        
        // 어제의 시작 시점
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: currentDate)) else { return }
        
        // 어제 당시에 수행했어야 하는 모든 습관 필터링
        let yesterdayHabits = habit.filter { h in
            let weekday = calendar.component(.weekday, from: yesterday)
            let isRepeatDay = h.repeatDays.contains(weekday)
            
            // 어제 이전에 생성되었는지만 확인 (어제 이미 존재했던 습관인지)
            let wasExistedYesterday = calendar.startOfDay(for: h.createdAt) <= yesterday
            
            // 어제 졸업했더라도 어제는 "해야 했던 날"이기 때문
            return isRepeatDay && wasExistedYesterday
        }
        
        // 어제 해야 할 습관이 하나라도 있었는지 확인
        if !yesterdayHabits.isEmpty {
            // 그 습관들 중 하나라도 완료된 로그가 있는지 확인
            let wasDoneYesterday = yesterdayHabits.contains { h in
                h.logs.contains { log in
                    calendar.isDate(log.date, inSameDayAs: yesterday) && log.isDone
                }
            }
            
            // 어제 하나라도 안 했다면 오늘 스트릭을 0으로 리셋
            if !wasDoneYesterday {
                lastBrokenStreak = currentStreak
                currentStreak = 0
                isPresentingStreakResetView = true
            }
        } else {
            // 어제 원래 쉬는 날이었다면 연속일은 그대로 유지
        }
    }
}


// MARK: - 추가 버튼 효과
struct DiceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0) // 눌렀을 때 살짝 작아짐
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: configuration.isPressed)
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
