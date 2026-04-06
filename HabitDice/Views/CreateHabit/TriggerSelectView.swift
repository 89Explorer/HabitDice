//
//  TriggerSelectView.swift
//  HabitDice
//
//  Created by kwonjungguen on 4/6/26.
//

import SwiftUI
import SwiftData


struct TriggerSelectView: View {
    
    @Binding var currentStep: HabitCreateStep
    @Binding var selectedTrigger: String
    
    
    var body: some View {
        
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        Text("언제\n할까요? ⚡️")
                            .font(.system(size: 24, weight: .bold))
                            .lineSpacing(4)
                        
                        HStack(spacing: 12) {
                             
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    TriggerSelectView(currentStep: .constant(.option), selectedTrigger: .constant("양치질 마쳤을 때"))
}
