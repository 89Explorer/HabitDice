//
//  HabitReflectionArchiveView.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/29/26.
//

import SwiftUI


struct HabitReflectionArchiveView: View {
    
    let habit: Habit
    
    // 현재 보고 있는 월 (기본 값: 이번 달)
    @State private var currentMonth: Date = Date()
    
    // 선택한 날짜 State (calendarGridView 에서 사용)
    // sheet(item:) 에서 Habit이 아니라, IdentifiableDate 사용
    // habit은 고정값, 바뀌는 건 "선택된 날짜" -> 날짜가 nil이면 sheet 닫힘 / 날짜가 있으면 회고 sheet 열림
    @State private var selectedDate: IdentifiableDate? = nil
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 12) {
                
                calendarHeaderSection
                
                ArchiveSectionCard(title: "감정 분포") {
                    Text("곧 막대 그래프가 들어올 자리")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                ArchiveSectionCard {
                    Text("곧 수치 통계가 들어올 자리")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
        .navigationTitle("회고")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    // MARK: 달력 섹션
    private var calendarHeaderSection: some View {
        // 반복 요일 반환
        let weekDay = habit.repeatDays
            .compactMap { DayOfWeek(rawValue: $0)?.label }
            .joined(separator: ", ")
        
        return ArchiveSectionCard(title: "반복 요일", subTitle: weekDay) {
            VStack(spacing: 8) {
                HStack {
                    // 이전 달 이동 버튼
                    Button {
                        withAnimation(.easeInOut) {
                            currentMonth = Calendar.current.date(
                                byAdding: .month,
                                value: -1,
                                to: currentMonth
                            ) ?? currentMonth
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(Color(.blue).opacity(0.2))
                            )
                    }
                    
                    // 연도 + 월 텍스트
                    Text(currentMonth, format: .dateTime.year().month())
                        .font(.subheadline)
                        .fontWeight(.black)
                        .foregroundStyle(.primary)
                    
                    // 다음 달 버튼 (이번 달이면 비활성화)
                    Button {
                        withAnimation(.easeInOut) {
                            currentMonth = Calendar.current.date(
                                byAdding: .month,
                                value: 1,
                                to: currentMonth
                            ) ?? currentMonth
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(isCurrentMonth ? .tertiary : .secondary)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(Color(.blue).opacity(0.2))
                            )
                    }
                    .disabled(isCurrentMonth)    // 이번 달 이후로는 못 넘어가게
                }
                .hSpacing(.center)
                
                WeekdayHeaderRow()
                calendarGridView
                Divider().padding(.top, 8)
                calendarLegendView
            }
        }
    }
    
    
    // MARK: 달력 날짜 그리드 섹션
    private var calendarGridView: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
        let dayDataList = calendarDayDataList
        let firstWeekday = dayDataList.first.map {
            Calendar.current.component(.weekday, from: $0.date)
        } ?? 1
        
        return LazyVGrid(columns: columns, spacing: 8) {
            // 빈 칸 오프셋
            ForEach(0..<firstWeekday - 1, id: \.self) { _ in Color.clear.frame(height: 32) }
            
            // 날짜 셀
            ForEach(dayDataList, id: \.date) { data in
                CalendarDayCell(
                    day: data.day,
                    isToday: data.isToday,
                    isRepeatDay: data.isRepeatDay,
                    isFuture: data.isFuture,
                    isBeforeCreateAt: data.isBeforeCreateAt,
                    isCreateDay: data.isCreateDay,
                    mood: data.mood,
                    isDone: data.isDone
                )
                .frame(height: 32)
                // 날짜 탭 제스처
                // 아래 3가지 조건을 만족한 날만 탭 가능
                .onTapGesture {
                    // 반복 요일이고, 생성일 이후이고, 미래가 아닌 날만 탭 가능
                    guard data.isRepeatDay,
                          !data.isBeforeCreateAt,
                          !data.isFuture else { return }
                    selectedDate = IdentifiableDate(date: data.date)
                }
            }
            // 회고 Sheet
            .sheet(item: $selectedDate) { identifiableDate in
                HabitReflectionView(habit: habit, targetDate: identifiableDate.date)
            }
        }
    }

    /*
    // 개선 전 달력 내 일(day)를 뿌려주는 View
    private var calendarGridView: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
        let dates = extractDates()    // 현재 월의 날짜들
        
        // 첫 번째 날의 요일을 계산하여 앞에 빈 공간 (Offset)을 만듭니다.
        let firstWeekday = Calendar.current.component(.weekday, from: dates.first ?? Date())
        
        return LazyVGrid(columns: columns, spacing: 8) {
            // 1일 시작 전 빈 칸 채우기
            ForEach(0..<firstWeekday - 1, id: \.self) { _ in Color.clear.frame(height: 32)}
            
            ForEach(dates, id: \.self) { date in
                let day = Calendar.current.component(.day, from: date)
                let weekday = Calendar.current.component(.weekday, from: date)
                
                // 데이터 로직 판단
                let isToday = Calendar.current.isDateInToday(date)
                let isFuture = date > Date()
                let isRepeatDay = habit.repeatDays.contains(weekday)
                
                // 날짜만 비교
                let isCreateDay = Calendar.current.isDate(date, inSameDayAs: habit.createdAt)
                let isBeforeCreateAt = !isCreateDay && date < habit.createdAt
                
                let log = habit.logs.first { log in
                    Calendar.current.isDate(log.date, inSameDayAs: date)
                }
                let mood = log?.reflect?.mood
                let isDone = log?.isDone ?? false
                
                CalendarDayCell(
                    day: day,
                    isToday: isToday,
                    isRepeatDay: isRepeatDay,
                    isFuture: isFuture,
                    isBeforeCreateAt: isBeforeCreateAt,
                    isCreateDay: isCreateDay,
                    mood: mood,
                    isDone: isDone
                )
                .frame(height: 32)
            }
        }
    }
    */
    
     
    // MARK: 달력 범례 뷰
    private var calendarLegendView: some View {
        HStack(spacing: 8) {
            legendItem(title: "시작일", color: .orange, isFill: false, hasBorder: true)
            legendItem(title: "할 일", color: .blue, isFill: false, hasBorder: true)
            legendItem(title: "완료", color: .blue, isFill: true, hasBorder: false)
            legendItem(title: "회고", emoji: "😊")
        }
        .padding(.top, 12)
        .hSpacing(.leading)
    }
    
    
    // MARK: 달력 내에 사용되는 범례의 공용뷰
    @ViewBuilder
    private func legendItem(
        title: String,
        color: Color = .clear,
        isFill: Bool = false,
        hasBorder: Bool = false,
        emoji: String? = nil
    ) -> some View {
        HStack(spacing: 4) {
            if let emoji = emoji {
                Text(emoji)
                    .font(.system(size: 12))
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(isFill ? color.opacity(0.6) : color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(color, lineWidth: hasBorder ? 1 : 0)
                    )
                    .frame(width: 12, height: 12)
            }
            Text(title)
                .font(.system(size: 8))
                .foregroundStyle(.secondary)
        }
    }
    
    
    // MARK: 현재 보고 있는 달이 이번 달인지 체크
    private var isCurrentMonth: Bool {
        Calendar.current.isDate(currentMonth, equalTo: Date(), toGranularity: .month)
    }
    
    // MARK: 날짜 계산 로직 (현재 선택된 월의 날짜들을 가져오는 함수)
    /*
    private func extractDates() -> [Date] {
        let calendar = Calendar.current
        
        // 해당 월의 시작일 구하기
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)),
              let range = calendar.range(of: .day, in: .month, for: monthStart) else {
            return []
        }
        
        // 1일부터 마지막 날까지 Date 객체 생성
        return range.compactMap { day -> Date in
            calendar.date(byAdding: .day, value: day - 1, to: monthStart) ?? Date()
        }
    }
    */
    
    // MARK: 날짜 계산 로직 + 일 별 데이터 (각 일(day)을 뿌려줌과 동시에, 해당 일에 데이터 포함), extractDates 개선
    private var calendarDayDataList: [CalendarDayData] {
        let calendar = Calendar.current
        
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)),
              let range = calendar.range(of: .day, in: .month, for: monthStart) else { return [] }
        
        // dayOffSet -> CalendarDayData?: 타입 변환을 선언 (range에서 꺼낸 Int 타입의 값을 CalendarDayData로 변환)
        return range.compactMap { dayOffset -> CalendarDayData? in
            
            // value: dayOffset - 1한 이유는 range가 1부터 시작하는데, byAdding은 0 부터 시작하기 때문에 맞추기 위해
            guard let date = calendar.date(byAdding: .day, value: dayOffset - 1, to: monthStart) else { return nil }
            
            let weekday = calendar.component(.weekday, from: date)
            let log = habit.logs.first{ calendar.isDate($0.date, inSameDayAs: date) }
            
            return CalendarDayData(
                date: date,
                day: calendar.component(.day, from: date),
                isToday: calendar.isDateInToday(date),
                isFuture: date > Date(),
                isRepeatDay: habit.repeatDays.contains(weekday),
                isCreateDay: calendar.isDate(date, inSameDayAs: habit.createdAt),
                isBeforeCreateAt: !calendar.isDate(date, inSameDayAs: habit.createdAt) && date < habit.createdAt,
                mood: log?.reflect?.mood,
                isDone: log?.isDone ?? false
            )
        }
    }
}


// MARK: 달력에 보이는 요일 뷰 (calendarHeaderSection에서 사용)
struct WeekdayHeaderRow: View {
    
    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(DayOfWeek.allCases) { day in
                Text(day.label)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(day.rawValue == 1 ? .red.opacity(0.8) : Color(.label))
                    .hSpacing(.center)
                    .padding(.bottom, 6)
            }
        }
    }
}


// MARK: 달력에 보이는 일(day) 뷰 (calendarHeaderSection에서 사용)
struct CalendarDayCell: View {
    let day: Int            // 날짜 숫자 ex) 1 ~ 31
    let isToday: Bool       // 오늘인지
    let isRepeatDay: Bool   // 반복 요일인지
    let isFuture: Bool      // 미래 날짜인지
    let isBeforeCreateAt: Bool    // 습관 생성일 이전인지
    let isCreateDay: Bool    // 습관 생성일 당일인지
    let mood: Mood?         // 회고가 있으면 Mood, 없으면 nil
    let isDone: Bool        // 완료 여부
    
    var body: some View {
        ZStack {
            // 배경 및 테두리 로직
            Group {
                if isCreateDay {
                    // 시작일: 오렌지 배경
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.orange, lineWidth: 2)
                        )
                } else if isRepeatDay && !isFuture && !isBeforeCreateAt {
                    if isDone {
                        // 습관 완료: 꽉 찬 블루
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.2))
                    } else {
                        // 미완료: 블루 테두리
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                    }
                }
            }
            .frame(width: 32, height: 32)
            
            // 오늘 날짜 표시
            if isToday {
                Circle()
                    .fill(Color.primary.opacity(0.1))
                    .frame(width: 24, height: 24)
            }
            
            // 콘텐츠 (이모지 또는 날짜)
            if let mood, isDone, isRepeatDay {
                Text(mood.rawValue)
                    .font(.system(size: 24))
            } else {
                Text("\(day)")
                    .font(.system(size: 12))
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundStyle(isDone && isRepeatDay ? .white : textColor)
            }
        }
    }
    
    // 날짜별 색상
    private var textColor: Color {
        if isFuture || !isRepeatDay || isBeforeCreateAt {
            return Color(.tertiaryLabel)   // 흐리게
        } else {
            return Color(.label)           // 기본
        }
    }

}


// MARK: 날짜별 데이터를 담는 구조체 (달력 내에 일 (Day)에 담을 데이터모델) -> calendarDayDataList에서 사용
private struct CalendarDayData {
    let date: Date
    let day: Int
    let isToday: Bool
    let isFuture: Bool
    let isRepeatDay: Bool
    let isCreateDay: Bool
    let isBeforeCreateAt: Bool
    let mood: Mood?
    let isDone: Bool
}


// MARK: 섹션 카드 공용 (title/subTitle 옵셔널)
struct ArchiveSectionCard<Content: View>: View {
    
    // 프로퍼티
    var title: String? = nil    // 선택적 제목 ex) "반복 요일"
    var subTitle: String? = nil    // 선택적 부제목 ex) "월, 수, 금"
    @ViewBuilder let content: () -> Content    // 안에 들어올 내용
    
    // Body
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // 제목이 있을 때만 표시
            if let title {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    
                    // 부제목이 있을 때만 표시
                    if let subTitle {
                        Text("- \(subTitle)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // 실제 내용
            content()
        }
        .padding(16)
        .hSpacing(.leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}


// MARK: 날짜 선택을 위한 Identifiable
// Date는 기본적으로 Identifiable를 채택하지 않아서, sheet(item:)에 바로 사용 불가
// UUID를 id로 갖는 래퍼 구조체로 감싸, Identifiable을 충족
struct IdentifiableDate: Identifiable {
    var id = UUID()
    var date: Date
}


// MARK: 미리보기

#Preview {
    let habit = Habit.previewHabitWithReflections
    
    return NavigationStack {
        HabitReflectionArchiveView(habit: habit)
    }
}


#Preview("ArchiveSectionCard") {
    VStack(spacing: 12) {
        ArchiveSectionCard(title: "반복 사이클 기록", subTitle: "월 수 금") {
            Text("여기에 그리드가 들어옴")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        
        ArchiveSectionCard(title: "감정 분포") {
            Text("여기에 막대그래프가 들어옴")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        
        ArchiveSectionCard {
            Text("여기에 숫자 통계가 들어옴")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

