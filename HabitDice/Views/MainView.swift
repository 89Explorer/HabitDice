//
//  MainView.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/2/26.
//

import SwiftUI
import SwiftData


struct MainView: View {
    
    @State private var currentDate: Date = .init()
    @State private var progress = 0.75
    @State private var isPresentingCreateView: Bool = false
    
    @Query(sort: \Habit.createdAt) private var habit: [Habit]
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HeaderView(
                title: "오늘의 습관",
                subTitle: currentDate.formatted(date: .abbreviated, time: .omitted)
            )
            
            ScrollView(.vertical) {
                todayProcessView()
                    .shadow(
                        color: Color.gray.opacity(0.25), radius: 3, x: 0, y: 3
                    )
                
                availableTriggerView()
                    .shadow(
                        color: Color.gray.opacity(0.25), radius: 3, x: 0, y: 3
                    )
                
                weeklyHabitStatus()
                    .shadow(
                        color: Color.gray.opacity(0.25), radius: 3, x: 0, y: 3
                    )
            }
            .overlay(alignment: .bottomTrailing) {
                Button {
                    isPresentingCreateView.toggle()
                } label: {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(width: 55, height: 55)
                        .background(Color.blue.shadow(.drop(color: .gray.opacity(0.50), radius: 5, x: 5, y: 5)), in: .circle)
                        
                }
                .padding(15)
                
            }
            .fullScreenCover(isPresented: $isPresentingCreateView) {
                    //CreateHabitView()
                HabitCreateContainerView()
            }
            .onAppear {
//                print("\n📦 [MainView] 전체 습관 데이터 조회를 시작합니다 (총 \(habit.count)개)")
//                print("---------------------------------------------")
//                
//                for (index, item) in habit.enumerated() {
//                    print("[\(index + 1)] 습관명: \(item.emoji) \(item.title)")
//                    print("   - 생성일: \(item.createdAt.description)")
//                    print("   - 반복여부: \(item.isRepeatOn ? "YES" : "NO")")
//                    print("   - 반복요일: \(item.repeatDays) (1:일 ~ 7:토)")
//                    print("   - 알람설정: \(item.isAlarmOn ? "ON 🔔" : "OFF 🔕")")
//                    
//                    // 관계된 Notification 정보 확인
//                    if let noti = item.notification {
//                        print("   - ⏰ 알람시간: \(noti.time.formatted(date: .omitted, time: .shortened))")
//                        print("   - 🆔 알람ID: \(noti.id)")
//                    } else {
//                        print("   - ⏰ 알람 데이터 없음 (nil)")
//                    }
//                    print("---------------------------------------------")
//                }
                
            }
            
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
            triggerCardView(trigger: "현관문을 열고 들어왔을 때", habit: "스쿼트 5개 하기", tag: "📍 장소")
            triggerCardView(trigger: "양치질을 마쳤을 때", habit: "물 1잔 마시기", tag: "🔄 일상")
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
    
    @ViewBuilder
    func weeklyHabitStatus() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("3월 29일 - 4월 4일")
                .font(.headline)
            
            Grid(alignment: .center, horizontalSpacing: 4, verticalSpacing: 8) {
                
                GridRow {
                    Text("")
                        .gridCellColumns(1)
                    Spacer()
                    
                    ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 16)
                    }
                }
                
                Divider()
                
                habitStatusRow(name: "제자리 걸음 100분 하기", status: [false, false, true, false, true, false, false])
                
                Divider()
                
                habitStatusRow(name: "스쿼트 5개 하기", status: [true, true, false, true, false, false, false])
                
                Divider()
                
                habitStatusRow(name: "물 1잔 마시기", status: [false, true, false, true, false, false, false])
                
            }
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
    func habitStatusRow(name: String, status: [Bool]) -> some View {
        GridRow {
            
            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)
                .gridColumnAlignment(.leading)
            
            Spacer()
                .gridCellUnsizedAxes(.horizontal)
            
            ForEach(status.indices, id: \.self) { index in
                
                let done = status[index]
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(done ? Color.accentColor.opacity(0.5) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .frame(width: 16, height: 16)
            }
            
        }
    }
}

#Preview {
    ContentView()
}


