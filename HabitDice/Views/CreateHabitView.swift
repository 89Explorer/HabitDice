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
    
    // 추천 습관 데이터
    private let recommendedHabits: [(icon: String, title: String)] = [
        // 🧠 정신
        ("brain.head.profile", "명상 1분"),
        ("pencil", "감사 1줄 쓰기"),
        ("target", "오늘 목표 1개 적기"),
        
        // 📚 자기계발
        ("book.fill", "1페이지 읽기"),
        ("note.text", "짧은 메모 1줄 남기기"),
        ("headphones", "유익한 콘텐츠 1분 듣기"),
        
        // 💪 신체
        ("figure.walk", "제자리 걸음 1분"),
        ("figure.strengthtraining.traditional", "스쿼트 5개"),
        ("figure.walk.treadmill", "달리기 30분"),
        
        // 💧 건강
        ("drop.fill", "물 1잔"),
        ("applelogo", "과일 1종류 먹기"),
        ("moon.stars","야식 먹지 않기"),
        
        
        // 🌙 마무리
        ("sparkles", "책상 정리 1분"),
        ("iphone", "SNS 10분만"),
        ("moon.stars.fill", "오늘 한 일 1줄 기록")
    ]
    
    
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
            recommendedArea
            
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
                            isTextFieldFocused ? Color.accentColor.opacity(0.6) : Color.clear, lineWidth: isTextFieldFocused ? 1.5 : 0
                        )
                        .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
                }
                .onChange(of: customHabit) { oldValue, newValue in
                    
                    // 직접 입력 시 추천 선택 해제
                    if !newValue.isEmpty { selectedHabit = nil }
                }
            
        }
    }
    
    private var recommendedArea: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("ℹ️ 이런 습관을 어떠세요?")
            
            ForEach(recommendedHabits, id: \.title) { habit in
                recommendedCard(habit)
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
            .padding(.vertical, 12)
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
