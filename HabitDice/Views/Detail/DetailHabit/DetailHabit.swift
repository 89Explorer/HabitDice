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
    
    @State private var currentDate: Date = .init()
    
    @State private var showGraduateSheet: Bool = false     // 습관 졸업(완료) 여부를 제어하는 변수
    @State private var isEditing: Bool = false    // 수정 여부를 제어하는 변수
    @State private var showExitAlert: Bool = false    // 수정 중일 경우에 뒤로가기 전 안내창을 제어하는 변수
    @State private var showValidationAlert: Bool = false    // 요일 미선택 경고용 변수
    @State private var isInvalidRepeatSelection: Bool = false    // 빨간 테두리 전용 변수
    @State private var showAuthAlert: Bool = false // 알람 권한 설정 Alert 제어용 변수
    
    @FocusState private var isFocused: Bool    // 포커스 상태 정의 (키보드 내리기)
    
    @Environment(\.dismiss) var dismiss
    @Environment(HabitRepository.self) var container
    
    // 수정용 임시 값 (취소 시 원상복구)
    @State private var draftTrigger: String = ""
    @State private var draftRepeatDays: Set<Int> = []
    @State private var draftIsRepeatOn: Bool = false
    @State private var draftIsAlarmOn: Bool = false
    @State private var draftAlarmData: Date = Date()
    
    // MARK: - 계산 프로퍼티
    
    // 습관 생성일로부터 오늘까지 며칠 쨰인지 제어하는 변수
//    private var daysSinceCreation: Int {
//        Calendar.current.dateComponents([.day], from: habit.createdAt, to: Date()).day ?? 0
//    }
    
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(Color(.secondarySystemBackground)).ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    
                    // 배너가 내려왔을 때 콘텐츠가 가렺지지ㅣ 않게 하기 위한 여백 조절
                    if isEditing {
                        Spacer().frame(height: 40)
                    }
                    
                    heroSection
                        .blur(radius: isEditing ? 5 : 0)
                    
                    infoSection
                        .scaleEffect(isEditing ? 1.02 : 1.0)
                        //.shadow(color: .black.opacity(isEditing ? 0.15 : 0), radius: 10, x: 0, y: 10) // 띄워진 느낌 추가
                    
                    statSection
                        .blur(radius: isEditing ? 5 : 0)
                    
                    graduateCard
                        .blur(radius: isEditing ? 5 : 0)
                        .disabled(isEditing ? true : false)
                    
                }
                .padding(.top, 10)
            }
            
            if isEditing {
                editBanner
                    .padding(.top, 72)
                    .background(Material.ultraThin)
                    .ignoresSafeArea(edges: .top)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
            
        }
        .animation(.spring(), value: isEditing) // 배너 등장 애니메이션
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(isEditing ? .hidden : .visible, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    if isEditing {
                        // 수정 중 일 경우에는 알람 띄움
                        showExitAlert = true
                    } else {
                        dismiss()
                    }
                } label: {
                    Image(systemName: isEditing ? "xmark" : "chevron.left")
                        .fontWeight(.bold)
                }
                
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                if isEditing {
                    Button("완료", systemImage: "checkmark") {
                        withAnimation(.easeInOut) {
                            updateHabit()
                            //isEditing = false
                        }
                    }
                    .fontWeight(.bold)
                } else {
                    Menu {
                        Button {
                            withAnimation(.easeInOut) {
                                startEdit()
                            }
                        } label: {
                            Label("수정하기", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            // 삭제 로직
                        } label: {
                            Label("삭제하기", systemImage: "trash")
                        }
                        
                        Divider()
                        
                        Button(role: .cancel) {
                            // 취소 로직
                        } label: {
                            Label("취소하기", systemImage: "xmark")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                    }
                }
            }
        }
        .overlay {
            
        }
        // 🔥 저장하지 않고 나갈 때의 확인 창
        .confirmationDialog(
            "변경사항을 저장할까요? 🛠️",
            isPresented: $showExitAlert,
            titleVisibility: .visible
        ) {
            Button("아쉽지만 폐기하기", role: .destructive) {
                withAnimation(.spring()) {
                    isEditing = false
                }
            }
            Button("조금 더 다듬기 👍") { }
            
        } message: {
            Text("편집 중인 내용이 있습니다. 지금 나가시면 모든 변경사항이 취소됩니다.")
        }
        .sheet(isPresented: $showGraduateSheet) {
            GraduateConfirmSheet(
                habitTitle: habit.title,
                onGraduate: {
                    
                } , onCancel: {
                    showGraduateSheet = false
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .alert("요일을 선택해주세요", isPresented: $showValidationAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("⚠️ 반복 습관으로 설정하려면, 최소 하나 이상의 요일을 선택해야 합니다.")
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
                
                Text("D+\(habit.daysSinceCreation)일")
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
                isEditing: isEditing,
                mainContent: {
                    // [일반 모드] 기존 텍스트 표시
                    Text(habit.selectedTriggerAction ?? "선택 안함")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.trailing)
                },
                // editTopContent: 생략 (기본값 EmptyView()가 자동으로 들어감)
                editBottomContent: {
                    // [수정 모드] 아래로 확장되는 입력 영역
                    VStack(alignment: .leading, spacing: 8) {
                        TextField(habit.selectedTriggerAction ?? "선택 안함", text: $draftTrigger)
                            .textFieldStyle(.plain)
                            .font(.title3)
                            .fontWeight(.bold)
                            .focused($isFocused)    // 포커스 바인딩
                            .submitLabel(.send)     // 키보드 엔터 버튼을 "보내기(완료)"로 변경
                            .onSubmit {
                                isFocused = false   // 엔터 누르면 키보드 내림
                            }
                            .overlay(alignment: .trailing) {
                                if !draftTrigger.isEmpty {
                                    Button { draftTrigger = "" } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            if isEditing {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(TriggerData.TriggerCategory.allCases, id: \.self) { category in
                                            // 카테고리 레이블
                                            Text(category.rawValue)
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundStyle(.secondary)
                                                .padding(.horizontal, 4)
                                            
                                            // 카테고리별 추천 버튼
                                            ForEach(TriggerData.options(for: category)) { item in
                                                Button {
                                                    withAnimation(.spring()) {
                                                        draftTrigger = item.title
                                                    }
                                                } label: {
                                                    Text(item.title)
                                                        .font(.subheadline)
                                                        .foregroundStyle(Color(.label))
                                                        .padding(.horizontal, 8)
                                                        .padding(.vertical, 4)
                                                }
                                                .buttonStyle(.borderedProminent)
                                                .tint(Color(.systemBlue).opacity(0.15))
                                                .clipShape(Capsule())
                                            }
                                            
                                            if category != TriggerData.TriggerCategory.allCases.last {
                                                Divider().frame(height: 20)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }
                        }
                    }
                }
            )
            .padding(.top, 12)
            
            Divider().padding(.horizontal, 24)
            
            // 반복
            infoRow(
                label: "🔄 반복",
                isEditing: isEditing,
                mainContent: {
                    if habit.isRepeatOn {
                        HStack(spacing: 4) {
                            ForEach(DayOfWeek.allCases) { day in
                                let isOn = habit.repeatDays.contains(day.rawValue)
                                
                                Text(day.label)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .padding(4)
                                    .background(
                                        Circle()
                                            .fill(
                                                isOn ? Color(.systemBlue).opacity(0.25) : Color(.systemGray5)
                                            )
                                    )
                                    .foregroundStyle(isOn ? .primary: .secondary)
                            }
                        }
                    } else {
                        Text("설정 안함")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                },
                editTopContent: {
                    // 레이블 옆에 바로 붙는 토글!
                    Toggle("", isOn: $draftIsRepeatOn.animation(.spring()))
                        .labelsHidden() // 레이블은 이미 "반복"이 있으므로 숨김
                        .tint(.accentColor)
                        .onChange(of: draftIsRepeatOn) { oldValue, newValue in
                            if newValue {
                                draftRepeatDays = []
                            } else {
                                // 반복을 끄면 유효성 에러도 사라짐
                                isInvalidRepeatSelection = false
                                draftRepeatDays = []
                            }
                        }
                },
                editBottomContent: {
                    if draftIsRepeatOn {
                        HStack(spacing: 8) {
                            
                            ForEach(DayOfWeek.allCases) { day in
                                
                                Button {
                                    withAnimation(.easeInOut) {
                                        if draftRepeatDays.contains(day.rawValue) {
                                            draftRepeatDays.remove(day.rawValue)
                                        } else {
                                            draftRepeatDays.insert(day.rawValue)
                                            //isInvalidSelection = false
                                        }
                                        
                                        if !draftRepeatDays.isEmpty {
                                            isInvalidRepeatSelection = false
                                        }
                                    }
                                    
                                } label: {
                                    Text(day.label)
                                        .font(.title3)
                                        .padding(4)
                                        .fontWeight(draftRepeatDays.contains(day.rawValue) ? .bold : .semibold)
                                        .foregroundStyle(draftRepeatDays.contains(day.rawValue) ? Color.white : Color.secondary)
                                        .background {
                                            Circle()
                                                .fill(draftRepeatDays.contains(day.rawValue) ? Color.accentColor : Color(.systemGray6))
                                        }
                                        //.padding(4)
                                    
                                }
                                .buttonStyle(.plain)
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.systemRed), lineWidth: isInvalidRepeatSelection ? 2 : 0)
            )
            .animation(.easeInOut, value: isInvalidRepeatSelection)
           
            Divider().padding(.horizontal, 24)
            
            // 알람
            infoRow(
                label: "🔔 알람",
                isEditing: isEditing,
                mainContent: {
                    if habit.isAlarmOn {
                        let time = draftAlarmData
                        Text(formattedTime(time))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(.label))
                    } else {
                        Text("설정 안함")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                   
                },
                editTopContent: {
                    // 레이블 옆에 바로 붙는 토글!
                    Toggle("", isOn: $draftIsAlarmOn.animation(.spring()))
                        .labelsHidden() // 레이블은 이미 "반복"이 있으므로 숨김
                        .tint(.accentColor)
                        .onChange(of: draftIsAlarmOn) { oldValue, newValue in
                            if newValue {
                                Task {
                                    // 권한 체크 및 요청
                                    let isAllowed = await container.notificationRepository.checkAndRequestNotificationAuth()
                                    
                                    if !isAllowed {
                                        // 권한이 없다면 토글을 다시 끄고 알림창 표시
                                        await MainActor.run {
                                            draftIsAlarmOn = false
                                            showAuthAlert = true
                                        }
                                    }
                                }
                            }
                        }
                },
                editBottomContent: {
                    if draftIsAlarmOn {
                        DatePicker("", selection: $draftAlarmData, displayedComponents: [.hourAndMinute])
                            .labelsHidden()
                            .datePickerStyle(.compact)
                    }
                        
                }
            )
            .padding(.bottom, 12)
        }
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    Color(.systemBackground)
                )
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    isEditing ? Color(.systemBlue) : Color.clear,
                    lineWidth: 3.0
                )
        }
        .alert("알림 권한 필요", isPresented: $showAuthAlert) {
            Button("설정으로 이동") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("알람을 받으려면 설정에서 알림 권한을 허용해주세요.")
        }
        .padding(.horizontal, 24)
    }
    
    
    // MARK: - 인포 섹션 공통 행 레이아웃
    @ViewBuilder
    private func infoRow<MainContent: View, EditTopView: View, EditBottomView: View>(
        label: String,
        isEditing: Bool,
        @ViewBuilder mainContent: () -> MainContent,
        @ViewBuilder editTopContent: () -> EditTopView = { EmptyView() } ,
        @ViewBuilder editBottomContent: () -> EditBottomView
    ) -> some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if isEditing {
                    editTopContent()
                } else {
                    mainContent()
                }
                
            }
            
            if isEditing {
                editBottomContent()
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .contentShape(Rectangle())    // 터치 영역 확보
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
    
    
    private var graduateCard: some View {
        Button {
            showGraduateSheet = true
        } label: {
            HStack(spacing: 12) {
                Text("🏆")
                    .font(.system(size: 28))
                VStack(alignment: .leading, spacing: 4) {
                    Text("이 습관 마스터하기")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentColor)
                    Text("습관이 자연스러워졌나요?")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.accentColor)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        Color(.systemBackground)
                    )
            )
            .padding(.horizontal, 24)
        }
        .buttonStyle(.plain)
    }
    
    private var bottomArea: some View {
        VStack(spacing: 8) {
            Button {
                print("저장하기")
            } label: {
                Text("수정하기")
                    .padding(20)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(.label))
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                Color(.systemBlue)
                            )
                    )
                    .padding(.horizontal, 24)
                
            }
        }
    }
    
    private var editBanner: some View {
        Text("트리거, 반복, 알람을 수정할 수 있어요 👍")
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.primary)
            .hSpacing(.center)
            .padding(.vertical, 12)
            .background(Color(.systemBlue).opacity(0.15))
            .overlay(alignment: .bottom) {
                Divider()
            }
    }
    
    
    // MARK: - 로직
    
    private func loadDraft() {
        self.draftTrigger = habit.selectedTriggerAction ?? "설정 안함"
        self.draftIsRepeatOn = habit.isRepeatOn
        
        if habit.isRepeatOn {
            self.draftRepeatDays = Set(habit.repeatDays)
        } else {
            self.draftRepeatDays = []
        }
        //self.draftIsRepeatOn = habit.isRepeatOn
        // [수정] [Int] 배열을 Set<Int>로 변환하여 할당
        //self.draftRepeatDays = Set(habit.repeatDays)
        
        self.draftIsAlarmOn = habit.isAlarmOn
        self.draftAlarmData = habit.notification?.time ?? Date()
    }
    
    private func startEdit() {
        loadDraft()
        isEditing = true
    }
    
    private func doGraduate() {
        habit.habitArchive()
    }
    
    func updateHabit() {
        // 반복 요일 유효성 검사
        if draftIsRepeatOn && draftRepeatDays.isEmpty {
            showValidationAlert = true    // 알람 띄우기
            isInvalidRepeatSelection = true    // 테두리 켜기
            return  // 함수 종료 - 저장은 안함
        }
        
        // 기존 알림 상태 백업
        let oldNotification = habit.notification
        
        // 데이터 업데이트 (Draft -> habit)
        habit.selectedTriggerAction = draftTrigger
        habit.isRepeatOn = draftIsRepeatOn
        
        if draftIsRepeatOn {
            // 반복습관으로 전환 또는 유지 => 사용자가 선택한 새로운 요일들로 교체
            habit.repeatDays = Array(draftRepeatDays).sorted()
        } else {
            // 1회성습관으로 전환 또는 유지 => 기존 요일 무시하고 오늘 요일로 고정
            let today = Calendar.current.component(.weekday, from: Date())
            habit.repeatDays = [today]
        }
        
        // 알림 데이터 처리
        habit.isAlarmOn = draftIsAlarmOn
        if draftIsAlarmOn {
            if let existing = habit.notification {
                existing.time = draftAlarmData
            } else {
                // 알림 객체가 없다면, 새로 생성
                let newNotification = Notification(time: draftAlarmData)
                habit.notification = newNotification
            }
        } else {
            habit.notification = nil    // 관계 끊기
        }
        
        // 비동기 알림 스케줄링
        Task {
            if draftIsAlarmOn {
                // 알림 등록
                await container.notificationRepository.registerNotification(habit: habit)
            } else {
                if let toCancel = oldNotification {
                    container.notificationRepository.cancelNotification(notification: toCancel)
                }
            }
            
            // 디버깅용 예약 목록 확인
            container.notificationRepository.checkPendingNotifications()
            
            await MainActor.run {
                withAnimation {
                    isInvalidRepeatSelection = false
                    isEditing = false
                }
            }
        }

    }
    
    // 인포 섹션 (시간 포맷)
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
