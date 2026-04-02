//
//  MainView.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/2/26.
//

import SwiftUI

struct MainView: View {
    
    @State private var currentDate: Date = .init()
    @State private var progress = 0.75
    
    var body: some View {
        VStack(alignment: .leading) {
            HeaderView(
                title: "오늘의 습관",
                subTitle: currentDate.formatted(date: .abbreviated, time: .omitted)
            )
            
            todayProcessView()
                .shadow(
                    color: Color.gray.opacity(0.25), radius: 3, x: 0, y: 3
                )
            
            
        }
        .vSpacing(.top)
        .padding(.horizontal, 12)
    }
    
    
    @ViewBuilder
    func todayProcessView() -> some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Text("오늘 진행")
                    .font(.headline)
                Spacer()
                Text("2 / 3 완료")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: progress)
                .tint(.blue)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    Color(uiColor: .systemBackground)
                )
        )
    }
    
}

#Preview {
    ContentView()
}
