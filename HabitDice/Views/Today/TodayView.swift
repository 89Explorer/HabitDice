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
            
            ColoredText(originalText: titleMessage, coloredText: "\(todayHabitCount)", originalFont: .subheadline, coloredFont: .headline)
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
                        coloredFont: .caption
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
                ForEach(todayHabits) { item in
                    habitCardView(item)
                    
                    Divider()
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
                            coloredFont: .caption
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
