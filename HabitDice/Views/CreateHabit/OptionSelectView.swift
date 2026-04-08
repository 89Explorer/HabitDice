//
//  OptionSelectView.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/6/26.
//

import SwiftUI
import SwiftData


enum DayOfWeek: Int, CaseIterable, Identifiable {
    case sunday = 0, monday, tuesday, wednesday, thursday, friday, satureday
    
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
    
    @Binding var currentStep: HabitCreateStep
    @Binding var selectedHabit: String
    @Binding var habitEmoji: String
    @Binding var selectedTrigger: String
    @Binding var selectedRepeatDays: [Int]
    
    @State private var isRepeatOn: Bool = false
    @State private var repeatDays: Set<Int> = []
    @State private var currentRepeatDays: Set<Int> = []
    
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        Text("거의 다 됐어요! 🎉")
                            .font(.system(size: 24, weight: .bold))
                        
                        Text("옵션은 나중에도 바꿀 수 있어요!")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(.label))
                        
                        VStack(alignment: .leading, spacing: 12) {
                            summaryRow(category: "습관", title: selectedHabit, emoji: habitEmoji)
                            Color.accentColor.opacity(0.2)
                                .frame(height: 3)
                            summaryRow(category: "트리거", title: selectedTrigger, emoji: "🔫")
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

                    }
                }
                
                PrimaryButton(title: "저장", isEnabled: true) {
                    let sortedRepeatDays = repeatDays.sorted()
                    print(sortedRepeatDays)
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
                
                Toggle("", isOn: $isRepeatOn)
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .tint(.accentColor)
            }
            
            if isRepeatOn {
                
                HStack{
                    ForEach(DayOfWeek.allCases) { day in
                        
                        Button {
                            withAnimation(.snappy) {
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
                //.transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.easeInOut.delay(0.25), value: isRepeatOn) 
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
        .animation(.easeInOut, value: isRepeatOn)
        .padding(4)
        
    }
    
    private func saveAction() {
        self.selectedRepeatDays = repeatDays.sorted()
    }
}



#Preview {
    OptionSelectView(
        currentStep: .constant(.trigger),
        selectedHabit: .constant("제자리 걷기"),
        habitEmoji: .constant("👍"),
        selectedTrigger: .constant("설거지를 마쳤을 떄"),
        selectedRepeatDays: .constant([1,2])
    )
}
