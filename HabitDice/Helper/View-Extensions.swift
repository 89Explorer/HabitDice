//
//  View-Extensions.swift
//  HabitDice
//
//  Created by kwonjungguen on 3/30/26.
//

import Foundation
import SwiftUI


extension View {
    
    
    // 가로 공간을 꽉 채우고, 내용을 어느 쪽으로 붙일지 결정합니다.
    @ViewBuilder
    func hSpacing(_ alignment: Alignment) -> some View {
        self.frame(maxWidth: .infinity, alignment: alignment)
    }
    
    
    // 세로 공간을 꽉 채우고, 내용을 어느 쪽으로 붙일지 결정합니다.
    @ViewBuilder
    func vSpacing(_ alignment: Alignment) -> some View {
        self.frame(maxHeight: .infinity, alignment: alignment)
    }
    
    
}


extension View {
    
    func ColoredText(originalText: String, coloredText: String) -> Text {
        let text = originalText
        var attributedString = AttributedString(text)
        
        // coloredtext 부분 범위 찾기
        if let range = attributedString.range(of: coloredText) {
            // 해당 범위 색상, 폰트 변경
            attributedString[range].foregroundColor = .blue
            attributedString[range].font = .headline
        }
        
        return Text(attributedString).font(.subheadline)
    }
}
