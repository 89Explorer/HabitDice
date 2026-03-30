//
//  CreateHabitView.swift
//  HabitDice
//
//  Created by kwonjungguen on 3/29/26.
//

import SwiftUI

struct CreateHabitView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HeaderView()
        }
    }
    
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("오늘의 습관")
                .font(.title.bold())
            Text("2026년 3월 29일")
                .font(.callout)
                .fontWeight(.semibold)
                .textScale(.secondary)
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    ContentView()
}
