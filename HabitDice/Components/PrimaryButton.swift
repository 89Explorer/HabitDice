//
//  PrimaryButton.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/1/26.
//

import SwiftUI

struct PrimaryButton: View {
    
    let title: String
    let isEnabled: Bool
    let action: () -> Void
    
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .hSpacing(.center)
                .frame(height: 60) // 조금 더 터치하기 편한 높이
                .foregroundStyle(isEnabled ? .white : .secondary)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isEnabled ? Color.accentColor : Color.gray.opacity(0.15))
                )
        }
        .background(
            Color(uiColor: .secondarySystemBackground)
        )
        //.padding(.horizontal, 12)
        //.padding(.bottom, 8)
        .disabled(!isEnabled)
        //.animation(.easeInOut, value: isEnabled)
    }
}

#Preview {
    PrimaryButton(title: "양치질을 마쳤을 때", isEnabled: true){ print("저장됨") }
}
