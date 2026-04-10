//
//  OptionSelectView.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/6/26.
//

import SwiftUI
import SwiftData


enum DayOfWeek: Int, CaseIterable, Identifiable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, satureday
    
    var id: Int { self.rawValue }
    
    var label: String {
        switch self {
        case .sunday: return "일"
        case .monday: return "월"
        case .tuesday: return "화"
        case .wednesday: return "수"
        case .thursday: return "목"
        case .friday: return "금"
        case .satureday: return "토"
        }
    }
}


struct OptionSelectView: View {
    
    @Bindable var habit: Habit
    
    @State private var isRepeatOn: Bool = false
    @State private var repeatDays: Set<Int> = []
    
    @State private var isAlarmOn: Bool = false // 토글 버튼 용 변수
    
    @State private var isPickerVisible: Bool = false   // 실제 시간을 선택하는 뷰를 보여줄지 제어하는 변수
    @State private var alarmData = Date()
    
    @State private var showAuthAlert: Bool = false // Alert 제어용 변수
    
    
    @Environment(\.dismiss) private var dismiss
    @Environment(HabitRepository.self) var container
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Text("거의 다 됐어요! 🎉")
                            .font(.system(size: 24, weight: .bold))
                        
                        Text("옵션은 나중에도 바꿀 수 있어요!")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(.label))
                        
                        VStack(alignment: .leading, spacing: 12) {
                            summaryRow(
                                category: "습관",
                                title: habit.title,
                                emoji: habit.emoji
                            )
                            
                            Color.accentColor.opacity(0.2)
                                .frame(height: 3)
                            
                            summaryRow(
                                category: "트리거",
                                title: habit.selectedTriggerAction ?? "",
                                emoji: "🔫"
                            )
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    Color.init(uiColor: .systemBackground)
                                )
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke (
                                    Color.accentColor.opacity(0.4),
                                    lineWidth: 2
                                )
                        }
                        .padding(4)
                        
                        repeatDaysView
                        
                        timePickerSection
                        
                    }
                }
                
                PrimaryButton(title: "저장", isEnabled: true){
                    saveAction()
                    print("--- 최종 설정 데이터 ---")
                    print("타이틀: \(habit.title)")
                    print("이모지: \(habit.emoji)")
                    print("반복 여부: \(habit.isRepeatOn)") // [0, 1, 2] 형식
                    print("반복 요일: \(habit.repeatDays)") // [0, 1, 2] 형식
                    print("알람 여부: \(habit.isAlarmOn)")
                    print("알람 시간: \(habit.notification?.time.description ?? "없음")")
                    print("트리거: \(habit.selectedTriggerAction ?? "없음")")
                    print("----------------------")
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
    }
    
    
    private func summaryRow(category: String, title: String, emoji: String = "") -> some View {
        
        HStack(spacing: 24) {
            Text(emoji)
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.system(size: 18))
                    .foregroundStyle(Color(.label))
            }
        }
    }
    
    private var repeatDaysView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("반복")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(Color(.label))
                
                Spacer()
                
                Toggle("", isOn: $isRepeatOn.animation(.easeInOut(duration: 0.25)))
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .tint(.accentColor)
                    .onChange(of: isRepeatOn) { oldValue, newValue in
                        if !newValue {
                            repeatDays = []
                        }
                    }
            }
            
            if isRepeatOn {
                
                HStack{
                    ForEach(DayOfWeek.allCases) { day in
                        
                        Button {
                            withAnimation(.easeInOut) {
                                if repeatDays.contains(day.rawValue) {
                                    repeatDays.remove(day.rawValue)
                                } else {
                                    repeatDays.insert(day.rawValue)
                                }
                            }
                        } label: {
                            Text(day.label)
                                .font(.system(size: 14))
                                .padding(12)
                                .fontWeight(repeatDays.contains(day.rawValue) ? .bold : .semibold)
                                .foregroundStyle(repeatDays.contains(day.rawValue) ? Color.white : Color.secondary)
                                .background {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(repeatDays.contains(day.rawValue) ? Color.accentColor : Color(.systemGray6))
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
                //.animation(.easeInOut.delay(0.25), value: isRepeatOn)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    Color.init(uiColor: .systemBackground)
                )
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke (
                    Color.accentColor.opacity(0.4),
                    lineWidth: 2
                )
        }
        // opacity: 투명도 (뷰가 나타날 떄는 0 -> 100, 뷰가 사라질 떄는 100 -> 0)
        // move(edge: .top): 위치 이동 (뷰가 나타날 때는 위쪽에서 원래 자리로 내려오면서 등장, 뷰가 사라질때는 반대)
        // combined(with: ): 위의 2가지를 동시에 적용
        //.transition(.opacity.combined(with: .move(edge: .top)))
        //.animation(.easeInOut, value: isRepeatOn)
        .padding(4)
        
    }
    
    private var timePickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("알람")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(Color(.label))
                
                Spacer()
                
                Toggle("", isOn: $isAlarmOn.animation(.easeInOut))
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .tint(.accentColor)
                    .onChange(of: isAlarmOn) { oldValue, newValue in
                        if newValue {
                            
                            Task {
                                let isAllowed = await container.notificationRepository.checkAndRequestNotificationAuth()
                                if isAllowed {
                                    // 권한이 승인 되었다?
                                    withAnimation(.easeInOut) {
                                        isPickerVisible = true
                                        
                                    }
                                } else {
                                    // 권한 승인이 불허 되었다?
                                    showAuthAlert = true
                                    withAnimation(.easeInOut) {
                                        isAlarmOn = false
                                        isPickerVisible = false
                                    }
                                }
                            }
                            
                        } else {
                            
                            // 알람 끄면 시간 선택 뷰도 숨김
                            withAnimation(.easeInOut) {
                                isPickerVisible = false
                            }
                            alarmData = .now
                        }
                    }
                   
            }
            
            if isPickerVisible {
                HStack {
                    Spacer()
                    DatePicker("", selection: $alarmData, displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        .frame(maxWidth: 280)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    
                    Spacer()
                }
                .padding(.top, 8)
            }
            
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    Color.init(uiColor: .systemBackground)
                )
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke (
                    Color.accentColor.opacity(0.4),
                    lineWidth: 2
                )
        }
        .padding(4)
        .alert("알림 권한 필요", isPresented: $showAuthAlert) {
            Button("설정으로 이동") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("습관 알림을 받으려면\n설정에서 알림 권한을 허용해주세요.")
        }
        .onAppear {
            // 화면이 나타날 때 초기값 세팅
            isPickerVisible = isAlarmOn
        }
    }
    
    private func saveAction() {
        
        // 1. 모델 데이터 업데이트
        self.habit.isRepeatOn = isRepeatOn
        self.habit.repeatDays = repeatDays.sorted()
        self.habit.isAlarmOn = isAlarmOn
        
        let pendingNotification = self.habit.notification
        
        if isAlarmOn {
            if let existingNotification = self.habit.notification {
                existingNotification.time = alarmData
            } else {
                let newNotification = Notification(time: alarmData)
                self.habit.notification = newNotification
            }
            
        } else {
            // 알람을 껐다면 기존 알림 데이터 삭제 (선택 사항)
            self.habit.notification = nil
        }
        
        // 2. Swift Data DB에 반영
        container.context.insert(self.habit)
        
        do {
            try container.context.save()
            print("💾 [OptionSelectView] DB 저장 완료")
        } catch {
            print("⚠️ [OptionSelectView] 저장 실패: \(error)")
        }
        
        // 3. 비동기 작업 및 화면 종료
        Task {
            if isAlarmOn {
                await container.notificationRepository.registerNotification(habit: habit)
            } else {
                if let isToCancel = pendingNotification {
                    container.notificationRepository.cancelNotification(notification: isToCancel)
                }
            }
            
            container.notificationRepository.checkPendingNotifications()
            
            // 모든 비동기 작업이 끝난 후 메인 스레드에서 화면 닫기
            await MainActor.run {
                dismiss()
            }
        }

    }
}



#Preview {
    
    let container = HabitRepository(isInMemoryOnly: true)
    return  OptionSelectView(
        habit: Habit(title: "양치질", emoji: "👍", createdAt: .now, isArchived: false, isRepeatOn: false, repeatDays: [], isAlarmOn: false, logs: [])
        
    )
    .environment(container)
    .modelContainer(container.modelContainer)
}
