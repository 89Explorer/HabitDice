//
//  ContentView.swift
//  HabitDice
//
//  Created by kwonjungguen on 3/29/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CreateHabitView()
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity)
            .background(Color(uiColor: .secondarySystemBackground))
    }
}

#Preview {
    ContentView()
}
