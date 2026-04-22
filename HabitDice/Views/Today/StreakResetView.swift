//
//  StreakResetView.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/22/26.
//

import SwiftUI

struct StreakResetView: View {
    
    let brokenStreak: Int
    @Environment(\.dismiss) var dismiss
    
    // 🔥 영구 저장: 이 리셋 알림을 완전히 확인했는지 여부
    @AppStorage("hasAcknowledgedReset") private var hasAcknowledgedReset: Bool = false
    
    
    var body: some View {
        ZStack {
            
            Color(.systemBackground).ignoresSafeArea(.all)
            
            VStack(spacing: 12) {
                Spacer()
                // 상단 인디게이터 느낌의 아이콘
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Text("🔥")
                        .font(.system(size: 40))
                    
                }
                .phaseAnimator([0, 1]) { content, phase in
                    content
                        .scaleEffect(phase == 1 ? 1.1 : 0.9)
                } animation: { phase in
                        .easeInOut(duration: 3.0).repeatForever(autoreverses: true)
                }
                
                
                HStack(spacing: 4) {
                    Text("\(brokenStreak)")
                        .font(.system(size: 16))
                        .foregroundStyle(.orange)
                        .fontWeight(.bold)
                    Text("일간의 불꽃")
                        .font(.system(size: 12))
                        .foregroundStyle(.primary)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            .orange.opacity(0.15)
                        )
                )
                
                VStack(spacing: 4) {
                    Text("대단해요!")
                        .font(.system(size: 20))
                        .foregroundStyle(.orange)
                        .fontWeight(.bold)
                    Text("정말 잘 해왔어요👏")
                        .font(.system(size: 20))
                        .foregroundStyle(.primary)
                        .fontWeight(.bold)
                }
                
                
                // 격려 문구 박스
                VStack(alignment: .center, spacing: 4) {
                    Text("연속 기록은 초기화됐지만")
                        .font(.system(size: 16))
                        .foregroundStyle(.primary)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 0) {
                        Text("습관을 만들어온 나")
                            .foregroundStyle(.orange)
                        Text("는 사라지지 않아요 🌱")
                            .foregroundStyle(.primary)
                    }
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            .orange.opacity(0.15)
                        )
                )

                VStack(spacing: 8) {
                    Button {
                        // 오늘 다시 지피기 -> 영구적으로 확인 완료 처리
                        hasAcknowledgedReset = true
                        dismiss()
                    } label: {
                        Text("오늘, 다시 🔥 지피기")
                            .font(.system(size: 16))
                            .fontWeight(.black)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        Color.orange
                                    )
                                    .shadow(color: .orange.opacity(0.30), radius: 8, x: 4, y: 4)
                            )
                    }
                    
                    Button {
                        // 나중에 볼게요 -> 그냥 닫기만 함 (영구저장 안함)
                        dismiss()
                    } label: {
                        Text("나중에 볼게요")
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                            .foregroundStyle(Color(.secondaryLabel))
                            .padding(12)
                    }
                }
                .padding(.top, 12)
                .padding(.horizontal, 24)
            }
        }
        
    }
}

#Preview {
    StreakResetView(brokenStreak: 7)
}
