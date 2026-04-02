//
//  CreateHabitView.swift
//  HabitDice
//
//  Created by kwonjungguen on 3/29/26.
//

import SwiftUI

struct CreateHabitView: View {
    
    
    @State private var customHabit: String = ""
    @State private var selectedHabit: String? = nil
    @State private var selectedTrigger: String? = nil
    @State private var isShowingCancelConfirmation: Bool = false
    
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    var isCompleted: Bool {
        
        let isHabitSet = !customHabit.trimmingCharacters(in: .whitespaces).isEmpty || selectedHabit != nil
        let isTriggerSet = selectedTrigger != nil
        
        return isHabitSet && isTriggerSet
    }
    
    // 추천 습관 데이터
    private let recommendedHabits: [(icon: String, title: String)] = [
        // 🧠 정신
        ("brain.head.profile", "명상 1분 하기"),
        ("pencil", "감사 1줄 쓰기"),
        ("target", "오늘 목표 1개 적기"),
        
        // 📚 자기계발
        ("book.fill", "1페이지 읽기"),
        ("note.text", "짧은 메모 1줄 남기기"),
        ("headphones", "유익한 콘텐츠 1분 듣기"),
        
        // 💪 신체
        ("figure.walk", "제자리 걸음 1분 하기"),
        ("figure.strengthtraining.traditional", "스쿼트 5개 하기"),
        ("figure.walk.treadmill", "달리기 30분 하기"),
        
        // 💧 건강
        ("drop.fill", "물 1잔 마시기"),
        ("applelogo", "과일 1종류 먹기"),
        ("moon.stars","야식 먹지 않기"),
        
        
        // 🌙 마무리
        ("sparkles", "책상 정리 1분 하기"),
        ("iphone", "SNS 10분만 하기"),
        ("moon.stars.fill", "오늘 한 일 1줄 기록하기")
    ]
    
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
            
            TextField("형성하고 싶은 습관을 입력해주세요 🤔", text: $customHabit, axis: .vertical)
                .focused($isTextFieldFocused)
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
                .onChange(of: customHabit) { oldValue, newValue in
                    
                    // 직접 입력 시 추천 선택 해제
                    if !newValue.isEmpty { selectedHabit = nil }
                }
                .padding(.horizontal, 10)
        }
    }
    
    
    private var recommendedArea: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("ℹ️ 이런 습관을 어떠세요?")
            
            // 3개씩 나누기
            let chunks = recommendedHabits.chunked(into: 3)
            
            TabView {
                ForEach(chunks.indices, id: \.self) { pageIndex in
                    VStack(spacing: 10) {
                        ForEach(chunks[pageIndex], id: \.title) { habit in
                            recommendedCard(habit)
                                .padding(.horizontal , 10)
                        }
                        
                        if chunks[pageIndex].count < 3 {
                            ForEach(0..<(3 - chunks[pageIndex].count), id: \.self) { _ in Color.clear.frame(height: 60) }
                        }
                    }
                }
                .padding(.horizontal, 0)
                .padding(.bottom, 36)
                
            }
            .frame(height: CGFloat(3) * 60 + CGFloat(2) * 10 + 20)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .onAppear {
                // 현재 페이지 점의 색상
                UIPageControl.appearance().currentPageIndicatorTintColor = .systemBlue
                // 나머지 페이지 점의 색상
                UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemBlue.withAlphaComponent(0.3)
            }
        }
    }
    
    
    // 추천 습관
    private func recommendedCard(_ habit: (icon: String, title: String)) -> some View {
        
        let isSelected = selectedHabit == habit.title
        
        return Button {
            withAnimation(.easeInOut(duration: 0.25)) {
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


