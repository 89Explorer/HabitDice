//
//  CreateHabitView.swift
//  HabitDice
//
//  Created by kwonjungguen on 3/29/26.
//

import SwiftUI

struct CreateHabitView: View {
    
    
    @State private var inputHabit: String = ""
    @State private var selectedHabit: String? = nil
    
    @State private var selectedTrigger: String? = nil
    @State private var isShowingCancelConfirmation: Bool = false
    
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
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
                    print("저장됨")
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
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
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
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
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
                .padding(.horizontal, 10)
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
                                .padding(.horizontal, 10)
                        }
                        
                        
                    }
                    //.tag(category)
                 
                }
                .padding(.horizontal, 0)
                .padding(.bottom, 36)
                
            }
            .frame(height: CGFloat(3) * 60 + CGFloat(2) * 10 + 20)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .onAppear {
                setupPageControlAppearance()
            }
        }
    }
    
    // 외부에 따로 빼두면 깔끔합니다.
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
                    Image(systemName: habit.icon)
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
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel(trigger.title)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(trigger.items, id: \.self) { item in
                        recommendedTrigger(item)
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
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

#Preview("CreateHabitView Only") {
    CreateHabitView()
}

#Preview("Flow - ContentView") {
    ContentView()
}

#Preview("Recommend Card Test") {
    
    struct PreviewWrapper: View {
        @State private var selectedHabit: String? = "물 마시기"
        @State private var customHabit: String = ""
        @FocusState private var isTextFieldFocused: Bool
        
        var body: some View {
            VStack(spacing: 20) {
                // 선택되지 않은 상태
                recommendedCardPreview(icon: "leaf.fill", title: "명상하기")
                
                // 선택된 상태
                recommendedCardPreview(icon: "drop.fill", title: "물 마시기")
            }
            .padding()
            .background(Color(.systemBackground))
        }
        
        private func recommendedCardPreview(icon: String, title: String) -> some View {
            
            let habit = (icon: icon, title: title)
            let isSelected = selectedHabit == habit.title
            
            return Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    if isSelected {
                        selectedHabit = nil
                    } else {
                        selectedHabit = habit.title
                        customHabit = ""
                        isTextFieldFocused = false
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isSelected ? Color.accentColor : Color(.systemGray5))
                            .frame(width: 36, height: 36)
                        Image(systemName: habit.icon)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(isSelected ? .white : .secondary)
                    }
                    
                    Text(habit.title)
                        .font(.system(size: 15, weight: isSelected ? .bold : .regular))
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.accentColor)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.accentColor.opacity(0.08) : Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.accentColor.opacity(0.4) : Color.clear, lineWidth: 1.5)
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    return PreviewWrapper()
    
}


