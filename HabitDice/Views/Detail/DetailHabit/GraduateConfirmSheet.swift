//
//  GraduateConfirmSheet.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/14/26.
//

import SwiftUI


struct GraduateConfirmSheet: View {
    
    let habitTitle: String
    let onGraduate: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 0) {
                Text("🎓")
                    .font(.system(size: 48))
                    .padding(.bottom, 12)
                
                Text(habitTitle)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                Color(.systemBlue).opacity(0.15)
                            )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke (
                                 Color.accentColor.opacity(0.4),
                                lineWidth: 2
                            )
                    }
                    .padding(.bottom, 12)
                
                Text("이 습관을 졸업할까요?")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                
                Text("⚠️ 졸업한 습관은 더 이상 리스트에\n표시되지 않아요.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.bottom, 24)
                
                VStack(spacing: 8) {
                    Button {
                        onGraduate()
                    } label: {
                        Text("졸업하기")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.accentColor)
                            )
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        onCancel()
                    } label: {
                        Text("아직 더 할게요")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
            }
            //.padding(.bottom, 16)
        }
        
    }
}

#Preview {
    GraduateConfirmSheet(habitTitle: "물 2L 마시기", onGraduate: {}, onCancel: {})
}
