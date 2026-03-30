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
    @FocusState private var isTextFieldFocused: Bool
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HeaderView(title: "습관 만들기", subTitle: "2026년 3월 30일")
            
            Divider()
            
            ScrollView(.vertical) {
                actionSection
            }
        }
        .hSpacing(.center)
        .padding(.horizontal, 4)
        
    }
    
//    @ViewBuilder
//    func HeaderView() -> some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text("습관 만들기")
//                .font(.title.bold())
//            Text("2026년 3월 29일")
//                .font(.callout)
//                .fontWeight(.semibold)
//                .textScale(.secondary)
//                .foregroundStyle(.gray)
//        }
//        .hSpacing(.leading)
//        .padding(16)
//    }
    
    
    private var actionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("행동 선택")
                .font(.system(size: 18, weight: .semibold))
            
            directInputArea
            
        }
        .hSpacing(.leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    
    private var directInputArea: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionLabel("ℹ️ 직접 습관을 입력하거나 추천을 선택해주세요")
            
            TextField("형성하고 싶은 습관을 입력해주세요 🤔", text: $customHabit, axis: .vertical)
                .focused($isTextFieldFocused)
                .font(.system(size: 14))
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isTextFieldFocused ? Color.accentColor.opacity(0.6) : Color.clear, lineWidth: 1.5
                        )
                }
                .onChange(of: customHabit) { oldValue, newValue in
                    
                    // 직접 입력 시 추천 선택 해제
                    if !newValue.isEmpty { selectedHabit = nil }
                }
            
        }
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
