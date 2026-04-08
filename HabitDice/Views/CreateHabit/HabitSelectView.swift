//
//  HabitSelectView.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/6/26.
//

import SwiftUI
import MCEmojiPicker

struct HabitSelectView: View {
    
    
    // MARK: - Property
    @Binding var currentStep: HabitCreateStep
    @Binding var selectedHabit: String         // 상위 뷰와 연결하는 데이터
    @Binding var habitEmoji: String
    
    @State private var inputHabit: String = ""
    @State private var inputHabitEmoji: String = "🎯"
    
    @State private var recommendedHabit: HabitData.RecommendedHabit? = nil
    @State private var habitCategory: HabitData.habitCategory = .mental
    
    @State private var isEmojiPickerPresented: Bool = false
    
    
    // 사용자가 선택한 최종 습관 타이틀을 담는 데이터
    var currentDisplayTitle: String {
        if !inputHabit.trimmingCharacters(in: .whitespaces).isEmpty {
            return inputHabit
        }
        return recommendedHabit?.title ?? ""
    }
    
    var currentDisplayEmoji: String {
        if !inputHabitEmoji.trimmingCharacters(in: .whitespaces).isEmpty {
            return inputHabitEmoji
        }
        return recommendedHabit?.emoji ?? "🎯"
    }
    
    var isCompleted: Bool {
        !currentDisplayTitle.isEmpty
    }
    
    private var filteredHabits: [HabitData.RecommendedHabit] {
        HabitData.options(for: habitCategory)
    }
    
    // 텍스트 필드 확인
    @FocusState private var isTextFieldFocused: Bool
    
    
    // MARK: - Body
    var body: some View {
        
        ZStack {
            
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        Text("오늘 뭘\n해볼까요? 🎲")
                            .font(.system(size: 24, weight: .bold))
                            .lineSpacing(4)
                        
                        inputSection
                        recommendHabitSection
                        
                    }
                }
                
                PrimaryButton(title: "다음", isEnabled: isCompleted) {
                    print(currentDisplayTitle)
                    print(currentDisplayEmoji)
                    saveAndNext()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
        
    }
    
    
    // MARK: - 텍스트 필드: 습관 직접 입력 뷰
    private var inputSection: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            Text("습관을 직접 입력하거나 추천에서 골라요")
                .font(.system(size: 14))
                .foregroundStyle(Color(.label))
            
            HStack(spacing: 12) {
               
                Button {
                    isEmojiPickerPresented.toggle()
                    
                } label: {
                    Text(inputHabitEmoji)
                        .font(.system(size: 24))
                        .frame(width: 30, height: 30)
                        .padding(20)
                        .background(Color.init(uiColor: .systemBackground))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                }
                .emojiPicker(
                    isPresented: $isEmojiPickerPresented,
                    selectedEmoji: $inputHabitEmoji,
                    customHeight: 650.0,
                    isDismissAfterChoosing: true,
                    selectedEmojiCategoryTintColor: .black,
                    feedBackGeneratorStyle: .heavy
                )

                TextField("예: 아침 뉴스 보기 😙", text: $inputHabit )
                    .focused($isTextFieldFocused)
                    .font(.system(size: 18, weight: .bold))
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
                            .stroke (
                                isTextFieldFocused ? Color.accentColor.opacity(0.4) : Color.clear,
                                lineWidth: 2
                            )
                            .animation(.easeInOut(duration: 0.4), value: isTextFieldFocused)
                    }
                    .onChange(of: inputHabit, { oldValue, newValue in
                        if !newValue.isEmpty { recommendedHabit = nil }
                    })
                    .onSubmit {
                        isTextFieldFocused = false
                    }
            }
        }
        .padding(4)
    }
    
    
    // MARK: - 픽업 뷰: 추천 습관을 선택하는 뷰
    @ViewBuilder
    private var recommendHabitSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("추천 습관")
                .font(.system(size: 14))
                .foregroundStyle(Color(.label))
            
            Picker("습관 카테고리", selection: $habitCategory) {
                ForEach(HabitData.habitCategory.allCases, id: \.self) {
                    Text($0.rawValue)
                        .tag($0)
                }
            }
            .pickerStyle(.segmented)
            
            VStack(spacing: 8) {
                ForEach(filteredHabits) { habit in
                    habitCard(habit)
                        .padding(4)
                }
            }
        }
    }
    
    
    // MARK: - 추천 습관을 보여주는 카드 뷰
    private func habitCard(_ habit: HabitData.RecommendedHabit) -> some View {
        
        let isSelected = recommendedHabit?.id == habit.id
        
        return Button {
            withAnimation(.snappy(duration: 0.4)) {
                if isSelected {
                    recommendedHabit = nil
                } else {
                    recommendedHabit = habit
                    inputHabitEmoji = ""
                    inputHabit = ""
                    isTextFieldFocused = false
                }
            }
            
        } label: {
            HStack(spacing: 12) {
                Text(habit.emoji)
                    .font(.system(size: 20))
                
                Text(habit.title)
                    .font(.system(size: 18))
                    .fontWeight(isSelected ? .bold : .semibold)
                    .foregroundStyle(isSelected ? Color(.label) : Color(.secondaryLabel))
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .animation(.snappy(duration: 0.4))
                        .font(.system(size: 18))
                        .foregroundStyle(Color(.white))
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    Color.accentColor
                                )
                        )
                } else {
                    Color.clear
                        .frame(width: 32, height: 32)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isSelected ? Color.accentColor.opacity(0.05) : Color(.systemBackground)
                    )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? Color.accentColor.opacity(0.4) : Color.clear,
                        lineWidth: 2
                    )
            }
        }
        .buttonStyle(.plain)
    }
    
    
    private func saveAndNext() {
        self.selectedHabit = currentDisplayTitle
        self.habitEmoji = currentDisplayEmoji
        
        withAnimation {
            currentStep = .trigger
            isTextFieldFocused = false
        }
    }

}


#Preview {
    HabitSelectView(currentStep: .constant(.habit), selectedHabit: .constant("물1잔마시기"), habitEmoji: .constant("✅"))
}
