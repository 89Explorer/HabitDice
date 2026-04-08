//
//  CreateHabitView.swift
//  HabitDice
//
//  Created by kwonjungguen on 3/29/26.
//

import SwiftUI
import SwiftData


enum Field {
    case habit, trigger
}

/*
struct CreateHabitView: View {
    
    @State private var inputHabit: String = ""
    @State private var selectedHabit: HabitData.RecommendedHabit? = nil
    @State private var habitCategory: HabitData.habitCategory = .mental
    
    @State private var inputTrigger: String = ""
    @State private var selectedTrigger: TriggerData.RecommendedTrigger? = nil
    @State private var triggerCategroy: TriggerData.TriggerCategory = .routine
    
    @State private var isShowingCancelConfirmation: Bool = false
    
    @FocusState private var isTextFieldFocused: Field?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(HabitRepository.self) var habitRepository
    
    
    var finalHabitTitle: String {
        if !inputHabit.trimmingCharacters(in: .whitespaces).isEmpty {
            return inputHabit
        }
        return selectedHabit?.title ?? ""
    }
    
    var finalTriggerTitle: String {
        if !inputTrigger.trimmingCharacters(in: .whitespaces).isEmpty {
            return inputTrigger
        }
        return selectedTrigger?.title ?? ""
    }
    
    var isCompleted: Bool {
        !finalHabitTitle.isEmpty || !finalTriggerTitle.isEmpty
    }
    
    private var filteredHabits: [HabitData.RecommendedHabit] {
        HabitData.options(for: habitCategory)
    }
    
    private var filteredTriggers: [TriggerData.RecommendedTrigger] {
        TriggerData.options(for: triggerCategroy)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    actionSection
                        .padding(.top, 20)
                    triggerSection
                        
                }
                
            }
            .navigationTitle("습관 만들기")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        if isCompleted {
                            isShowingCancelConfirmation = true
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .confirmationDialog("작성 취소", isPresented: $isShowingCancelConfirmation) {
                        Button("작성 취소", role: .destructive) {
                            dismiss()
                        }
                    } message: {
                        Text("작성 중인 습관을 취소하시겠습니까?")
                    }

                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {

                        let newHabit = Habit(title: finalHabitTitle, createdAt: .now, triggerAction: finalTriggerTitle, groupName: triggerCategroy.rawValue)
                        habitRepository.context.insert(newHabit)
                        
                        do {
                            try habitRepository.context.save()
                        } catch {
                            
                        }
                        
                    } label: {
                        Image(systemName: "checkmark")
                    }

                }
            }
            .background(Color(.secondarySystemBackground))
            .onTapGesture {
                isTextFieldFocused = nil
            }
            
        }
    }
    
    
    // 행동 선택 섹션
    private var actionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("습관 선택")
                .hSpacing(.leading)
                .padding(.horizontal, 24)
            
            TextField("습관을 입력하세요 😙 ", text: $inputHabit)
                .id("TOP")
                .focused($isTextFieldFocused, equals: .habit)
                .font(.system(size: 18))
                .lineLimit(1)
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            Color.init(uiColor: .systemBackground)
                        )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isTextFieldFocused == .habit ? Color.accentColor.opacity(0.6) : Color.clear, lineWidth: isTextFieldFocused == .habit ? 1.5 : 0
                        )
                        .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
                }
                .onSubmit {
                    isTextFieldFocused = .trigger
                }
                .onChange(of: inputHabit) { oldValue, newValue in
                    
                    // 직접 입력 시 추천 선택 해제
                    if !newValue.isEmpty { selectedHabit = nil }
                }
                .padding(.horizontal, 32)
            
            
            sectionLabel("추천 습관")
                .hSpacing(.leading)
                .padding(.horizontal, 24)
            
            // 카테고리 선택 섹션
            Picker("카테고리", selection: $habitCategory) {
                ForEach(HabitData.habitCategory.allCases, id: \.self) {
                    Text($0.rawValue)
                        .tag($0)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 24)
            
            VStack(spacing: 8) {
                ForEach(filteredHabits) { habit in
                    habitCard(habit)
                }
            }
            .padding(.horizontal, 32)
            
        }
    }
    
    
    private func habitCard(_ habit: HabitData.RecommendedHabit) -> some View {
        let isSelected = selectedHabit?.id == habit.id
        
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if isSelected {
                    selectedHabit = nil
                } else {
                    selectedHabit = habit
                    inputHabit = ""
                    isTextFieldFocused = .trigger
                }
            }
            
        } label: {
            HStack(spacing: 12) {
                Text(habit.emoji)
                    .font(.system(size: 20))
                
                Text(habit.title)
                    .font(.system(size: 18, weight: isSelected ? .bold : .semibold))
                    .foregroundStyle(isSelected ? Color.black : .secondary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    Color.accentColor
                                )
                        )
                } else {
                    Color.clear.frame(width: 32, height: 32)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal,24)
            
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isSelected ? Color.accentColor.opacity(0.08) : Color(.systemBackground)
                    )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? Color.accentColor.opacity(0.4) : Color.clear,
                        lineWidth: 1.5
                    )
            }
        }
        .buttonStyle(.plain)
        
    }
    
    private var triggerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("습관 트리거 선택")
                .hSpacing(.leading)
                .padding(.horizontal, 24)
        
            TextField("습관 트리거를 입력하세요 😙 ", text: $inputTrigger)
                .id("TRIGGER")
                .focused($isTextFieldFocused, equals: .trigger)
                .font(.system(size: 18))
                .lineLimit(1)
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            Color.init(uiColor: .systemBackground)
                        )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isTextFieldFocused == .trigger ? Color.accentColor.opacity(0.6) : Color.clear, lineWidth: isTextFieldFocused == .trigger ? 1.5 : 0
                        )
                        .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
                }
                .onSubmit {
                    isTextFieldFocused = nil
                }
                .onChange(of: inputTrigger) { oldValue, newValue in
                    
                    // 직접 입력 시 추천 선택 해제
                    if !newValue.isEmpty { selectedTrigger = nil }
                }
                .padding(.horizontal, 32)
            
            Picker("카테고리", selection: $triggerCategroy) {
                ForEach(TriggerData.TriggerCategory.allCases, id: \.self) {
                    Text($0.rawValue)
                        .tag($0)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 24)
            
            sectionLabel("추천 습관 트리거")
                .hSpacing(.leading)
                .padding(.horizontal, 24)
            

            VStack(spacing: 8) {
                ForEach(filteredTriggers) { trigger in
                    triggerCard(trigger)
                }
            }
            .padding(.horizontal, 32)
        }
    }
    
    private func triggerCard(_ trigger: TriggerData.RecommendedTrigger) -> some View {
        let isSelected = selectedTrigger?.id == trigger.id
        
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if isSelected {
                    selectedTrigger = nil
                } else {
                    selectedTrigger = trigger
                    inputTrigger = ""
                    isTextFieldFocused = nil
                }
            }
            
        } label: {
            HStack(spacing: 12) {
                
                Text(trigger.title)
                    .font(.system(size: 18, weight: isSelected ? .bold : .semibold))
                    .foregroundStyle(isSelected ? Color.black : .secondary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    Color.accentColor
                                )
                        )
                } else {
                    Color.clear.frame(width: 32, height: 32)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal,24)
            
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isSelected ? Color.accentColor.opacity(0.08) : Color(.systemBackground)
                    )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? Color.accentColor.opacity(0.4) : Color.clear,
                        lineWidth: 1.5
                    )
            }
        }
        .buttonStyle(.plain)
        
    }
    
    
    private func scrollToFocusedField(proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo("TRIGGER", anchor: .bottom)
        }
    }
    
    
    // MARK: - 섹션 헤더 사용 목적
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(.secondary)
    }
}


/*
struct CreateHabitView: View {
    
    @State private var inputHabit: String = ""
    @State private var selectedHabit: String? = nil
    
    @State private var selectedTrigger: String? = nil
    @State private var isShowingCancelConfirmation: Bool = false
    
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(HabitRepository.self) var habitRepository
    
    var isCompleted: Bool {
        !finalHabitTitle.isEmpty && selectedTrigger != nil
    }
    
    var finalHabitTitle: String {
        if !inputHabit.trimmingCharacters(in: .whitespaces).isEmpty {
            return inputHabit
        }
        return selectedHabit ?? ""
    }
    
    var body: some View {
        
            ZStack(alignment: .bottom) {
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        HeaderView(title: "습관 만들기", subTitle: "2026년 3월 30일")
                        Spacer()
                        Button {
                            
                            if isCompleted {
                                isShowingCancelConfirmation = true
                            } else {
                                dismiss()
                            }
                        
                        } label: {
                            Image(systemName: "xmark")
                                .frame(width: 40, height: 40)
                                .foregroundStyle(.red)
                                .font(.system(size: 20))
                                .background(
                                    Circle().foregroundStyle(Color.init(.systemBackground))
                                )
                    
                        }
                        .padding(.trailing, 0)
                        .padding(.top, -20)
                        .confirmationDialog("작성 취소", isPresented: $isShowingCancelConfirmation) {
                            Button("작성 그만하기", role: .destructive) {
                                dismiss()
                            }
                        } message: {
                            Text("작성 중이신 습관을 취소하시겠습니까?")
                        }

                    }
                    
                    //Divider()
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            actionSection
                            triggerSection
                            
                        }
                    }
                    
                    Color.init(uiColor: .secondarySystemBackground).frame(height: 54)
                        .padding(.top, 12)
                    
                    
                }
                .padding(.horizontal, 12)
                .background(
                    Color(uiColor: .secondarySystemBackground)
                )
                
                PrimaryButton(title: "저장하기", isEnabled: isCompleted) {
                    let newHabit = Habit(title: finalHabitTitle, triggerAction: selectedTrigger)
                    habitRepository.context.insert(newHabit)
                    do {
                        try habitRepository.context.save()
                    } catch {
                        
                    }
                }
            }
            .ignoresSafeArea(.keyboard)
            .onTapGesture {
                isTextFieldFocused = false
            }
    }
    
    private var actionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("행동 선택")
                .font(.system(size: 18, weight: .semibold))
            
            directInputArea
            recommendedArea
                .padding(.bottom, -20)
            
        }
        .hSpacing(.leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(uiColor: .systemBackground))
        )
    }
    
    private var triggerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("트리거 선택")
                .font(.system(size: 18, weight: .semibold))
            
            ForEach(TriggerData.recommendedTriggers) { trigger in
                recommendedTriggerArea(trigger: trigger)
            }
        }
        
        .hSpacing(.leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(uiColor: .systemBackground))
        )
    }
    
    private var directInputArea: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionLabel("ℹ️ 직접 습관을 입력하거나 추천을 선택해주세요")
            
            TextField("형성하고 싶은 습관을 입력해주세요 🤔", text: $inputHabit)
                .focused($isTextFieldFocused)
                .lineLimit(1)
                .font(.system(size: 14))
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .hSpacing(.leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isTextFieldFocused ? Color.accentColor.opacity(0.6) : Color.clear, lineWidth: isTextFieldFocused ? 1.5 : 0
                        )
                        .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
                }
                .onSubmit {
                    isTextFieldFocused = false
                }
                .onChange(of: inputHabit) { oldValue, newValue in
                    
                    // 직접 입력 시 추천 선택 해제
                    if !newValue.isEmpty { selectedHabit = nil }
                }
                .padding(.horizontal, 20)
        }
    }
    
    private var recommendedArea: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("ℹ️ 이런 습관을 어떠세요?")
            
            TabView {
                ForEach(HabitData.Category.allCases, id: \.self) { category in
                    VStack(spacing: 10) {
                        
                        let filteredHabits = HabitData.allHabits.filter { $0.category == category }
                        
                        ForEach(filteredHabits) { habit in
                            recommendedCard(habit)
                        }
                        
                    }
                    // 추후 카테고리 탭(Segmented Picker)를 추가할 떄 사용 예정 
                    //.tag(category)
                 
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 36)
                
            }
            .frame(height: CGFloat(3) * 60 + CGFloat(2) * 10 + 20)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .onAppear {
                setupPageControlAppearance()
            }
        }
    }
    
    // 추천 습관 하단에 보이는 인디케이터 설정 (recommendedArea에서 사용)
    private func setupPageControlAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .systemBlue
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemBlue.withAlphaComponent(0.3)
    }
    
    // 추천 습관
    private func recommendedCard(_ habit: HabitData.RecommendedHabit) -> some View {
        
        let isSelected = selectedHabit == habit.title
        
        return Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                if isSelected {
                    selectedHabit = nil
                } else {
                    selectedHabit = habit.title
                    inputHabit = ""
                    isTextFieldFocused = false
                }
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.accentColor : Color(.systemGray5))
                        .frame(width: 36, height: 36)
                    Image(systemName: habit.emoji)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(isSelected ? .white : .secondary)
                }
                
                Text(habit.title)
                    .font(.system(size: 15, weight: isSelected ? .bold : .regular))
                    .foregroundStyle(isSelected ? .primary : .secondary)
                
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.accentColor)
                        .font(.system(size: 18))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected ? Color.accentColor.opacity(0.08) : Color(.systemGray5)
                    )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.accentColor.opacity(0.4) : Color.clear,
                        lineWidth: 1.5
                    )
            }
        }
        .buttonStyle(.plain)
    }
    
    private func recommendedTriggerArea(trigger: RecommendedTrigger) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionLabel(trigger.title)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(trigger.items, id: \.self) { item in
                        recommendedTrigger(item)
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 20)
            }
        }
    }
    
    // 추천 트리거
    private func recommendedTrigger(_ title: String) -> some View {
        let isSelected = selectedTrigger == title
        
        return Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                if isSelected {
                    selectedTrigger = nil
                } else {
                    selectedTrigger = title
                    isTextFieldFocused = false     // 입력 텍스트필드 닫기
                }
            }
        } label: {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .primary : .secondary)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.accentColor)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.12) : Color(.systemGray5))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor.opacity(0.5) : Color.clear, lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Helper
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.secondary)
    }
    
}
 
 */

#Preview("CreateHabitView Only") {
    
    let habitRepository = HabitRepository(isInMemoryOnly: true)
    
    NavigationStack {
        CreateHabitView()
            .environment(habitRepository)
            .modelContainer(habitRepository.modelContainer)
    }
}
*/




