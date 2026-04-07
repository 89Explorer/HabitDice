//
//  HabitCreateContainerView.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/6/26.
//

import SwiftUI
import SwiftData


struct HabitCreateContainerView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    
    // MARK: - Property
    @State private var currentStep: HabitCreateStep = .habit
    
    
    // 하위 뷰에서 공유할 데이터
    @State private var selectedHabit: String = ""
    @State private var selectedEmoji: String = ""
    
    
    @State private var selectedTrigger: String = ""
    
    
    @State private var showExitDialog: Bool = false
    

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerAera
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                    
                    TabView(selection: $currentStep) {
                        HabitSelectView(currentStep: $currentStep, selectedHabit: $selectedHabit, habitEmoji: $selectedEmoji)
                            .tag(HabitCreateStep.habit)
                        
                        TriggerSelectView(
                            currentStep: $currentStep,
                            selectedTrigger: $selectedTrigger,
                            currentHabitTitle: $selectedHabit,
                            currentHabitEmoji: $selectedEmoji
                        )
                            .tag(HabitCreateStep.trigger)
                        
                        OptionSelectView(currentStep: $currentStep)
                            .tag(HabitCreateStep.option)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.2), value: currentStep)
                }
                .navigationTitle("습관 만들기")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        backButton
                    }
                }
            }
        }
    }
    
    
    
    // MARK: - Header (프로그래스 바 + 단계 표시)
    private var headerAera: some View {
        HStack(alignment: .center, spacing: 12) {
            
            // 프로그래스 바
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(.systemGray5))
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.accentColor)
                        .frame(width: geo.size.width * currentStep.progress, height: 4)
                        .animation(.easeInOut(duration: 0.2), value: currentStep)
                }
            }
            .frame(height: 4)
            
            Text(currentStep.label)
                .font(.system(size: 14).bold())
                .foregroundStyle(.secondary)
                .frame(width: 32, alignment: .trailing)
            
        }
    }

    private var backButton: some View {
        Button {
            if currentStep == .habit {
                showExitDialog = true
            } else {
                withAnimation(.easeInOut(duration: 0.4)) {
                    currentStep = currentStep.previous
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
//                Text(currentStep == .habit ? "닫기" : "이전")
//                    .font(.system(size: 16))
            }
            .foregroundStyle(.primary)
        }
        .confirmationDialog(
            "작성을 취소할까요?",
            isPresented: $showExitDialog,
            titleVisibility: .visible
        ) {
            Button("취소하기", role: .destructive) { dismiss() }
            Button("계속 작성하기", role: .cancel) { }
        }
    }
}


enum HabitCreateStep: Int, CaseIterable {
    case habit = 0
    case trigger = 1
    case option = 2
    
    var progress: Double {
        switch self {
        case .habit:   return 1/3.0
        case .trigger: return 2/3.0
        case .option:  return 1.0
        }
    }
    
    var label: String {
        switch self {
        case .habit:   return "1 / 3"
        case .trigger: return "2 / 3"
        case .option:  return "3 / 3"
        }
    }
    
    var previous: HabitCreateStep {
        switch self {
        case .habit:   return .habit
        case .trigger: return .habit
        case .option:  return .trigger
        }
    }
}


#Preview {
    NavigationStack {
        HabitCreateContainerView()
    }
}
