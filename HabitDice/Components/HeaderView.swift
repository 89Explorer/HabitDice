//
//  SwiftUIView.swift
//  HabitDice
//
//  Created by kwonjungguen on 3/30/26.
//

import SwiftUI

struct HeaderView: View {
    
    let title: String
    let subTitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title.bold())
            Text(subTitle)
                .font(.callout)
                .fontWeight(.semibold)
                .textScale(.secondary)
                .foregroundStyle(.gray)
        }
        .hSpacing(.leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

#Preview {
    HeaderView(title: "습관 만들기", subTitle: "2026년 3월 30일")
}
