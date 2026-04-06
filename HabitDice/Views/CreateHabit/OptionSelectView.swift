//
//  OptionSelectView.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/6/26.
//

import SwiftUI

struct OptionSelectView: View {
    
    @Binding var currentStep: HabitCreateStep
    
    var body: some View {
        VStack {
            Text("OptionSelectView!")
            
    
            Button("저장하기") {
                print("저장")
                // Swift Data에 내용을 저장함과 동시에, 화면을 dismiss 호출한다
            }
        }
    }
}

#Preview {
    OptionSelectView(currentStep: .constant(.trigger))
}
