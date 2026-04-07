//
//  TriggerSelectView.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/6/26.
//

import SwiftUI
import SwiftData


struct TriggerSelectView: View {
    
    @Binding var currentStep: HabitCreateStep
    @Binding var selectedTrigger: String
    
    @Binding var currentHabitTitle: String
    @Binding var currentHabitEmoji: String
    
    @State private var inputTrigger: String = ""
    @State private var triggerCategroy: TriggerData.TriggerCategory = .routine
    @State private var recommendedTrigger: TriggerData.RecommendedTrigger? = nil
    
    private var filteredTriggers: [TriggerData.RecommendedTrigger] {
        TriggerData.options(for: triggerCategroy)
    }
    
    var currentDisplayTrigger: String {
        if !inputTrigger.trimmingCharacters(in: .whitespaces).isEmpty {
            return inputTrigger
        }
        return recommendedTrigger?.title ?? ""
    }
    
    var isCompleted: Bool {
        !currentDisplayTrigger.isEmpty
    }
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        Text("언제\n할까요? ⚡️")
                            .font(.system(size: 24, weight: .bold))
                            .lineSpacing(4)
                        habitContent
                        inputSection
                        recommendedTriggerSection
                        
                    }
                }
                
                PrimaryButton(title: "다음", isEnabled: isCompleted) {
                    print(currentDisplayTrigger)
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
    
    private var habitContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("트리거는 습관을 일으키는 자극, 동기가 됩니다. 🏃‍♀️")
                .font(.system(size: 14))
                .foregroundStyle(Color(.label))
            
            HStack(spacing: 12) {
                Text(currentHabitEmoji)
                Text(currentHabitTitle)
            }
            .hSpacing(.leading)
            .padding(24)
            .font(.system(size: 24, weight: .bold))
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        Color.init(uiColor: .systemBackground)
                    )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        Color.accentColor.opacity(0.4),
                        lineWidth: 2
                    )
            }
            .padding(4)
        }
    }
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("트리거를 직접 입력하거나 추천에서 골라요 📍")
                .font(.system(size: 14))
                .foregroundStyle(Color(.label))
            
            TextField("예: 설거지를 마쳤을 때", text: $inputTrigger)
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
                        .stroke(
                            isTextFieldFocused ? Color.accentColor.opacity(0.4) : Color.clear,
                            lineWidth: 2
                        )
                        .animation(.snappy, value: isTextFieldFocused)
                }
                .onChange(of: inputTrigger, { oldValue, newValue in
                    if !newValue.isEmpty {
                        recommendedTrigger = nil 
                    }
                })
                .onSubmit {
                    isTextFieldFocused = false
                }
                .padding(4)
        }
    }
    
    private var recommendedTriggerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("👍 추천 트리거")
                .font(.system(size: 14))
                .foregroundStyle(Color(.label))
            Picker("트리거 카테고리", selection: $triggerCategroy){
                ForEach(TriggerData.TriggerCategory.allCases, id: \.self) { Text($0.rawValue)
                        .tag($0)
                }
            }
            .pickerStyle(.segmented)
            
            VStack(spacing: 8) {
                ForEach(filteredTriggers) { trigger in
                    triggerCard(trigger)
                        .padding(4)
                }
            }
        }
    }
    
    private func triggerCard(_ trigger: TriggerData.RecommendedTrigger) -> some View {
        
        let isSelected = recommendedTrigger?.id == trigger.id
        
        return Button {
            withAnimation(.snappy(duration: 0.4)) {
                if isSelected {
                    recommendedTrigger = nil
                } else {
                    recommendedTrigger = trigger
                    inputTrigger = ""
                    isTextFieldFocused = false
                }
            }
        } label: {
            HStack(spacing: 12) {
                Text(trigger.title)
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
    }

    private func saveAndNext() {
        self.selectedTrigger = currentDisplayTrigger
        withAnimation {
            currentStep = .option
            isTextFieldFocused = false
        }
    }
}

#Preview {
    TriggerSelectView(
        currentStep: .constant(.option),
        selectedTrigger: .constant("양치질 마쳤을 때"),
        currentHabitTitle: .constant("스쿼트 5개"),
        currentHabitEmoji: .constant("🔫")
    )
}
