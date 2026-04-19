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
    
    
    // MARK: - 화면 헤더뷰 (오늘 날짜 + 오늘 습관 갯수 안내 멘트 + 진행바)
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
            
            ColoredText(originalText: titleMessage, coloredText: "\(todayHabitCount)")
                .fontWeight(.bold)
            
            // 진행 바 영역 분기 처리
            if !todayHabits.isEmpty {
                HStack {
                    ProgressView(value: progress)
                        .tint(.blue)
                    
                    ColoredText(originalText: "\(todayCompletedCount) / \(todayHabitCount) 완료", coloredText: "\(todayCompletedCount)")
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
