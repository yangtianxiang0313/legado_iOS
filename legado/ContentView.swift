//
//  ContentView.swift
//  legado
//
//  Created by AI Assistant on 2024/12/19.
//

import SwiftUI
import SFSafeSymbols

struct ContentView: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        TabView {
            BookshelfView()
                .tabItem {
                    Image(systemSymbol: .booksVertical)
                    Text(.tabBookshelf)
                }
            
            RuleEngineTestView()
                .tabItem {
                    Image(systemSymbol: .testtube2)
                    Text("测试")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemSymbol: .gearshape)
                    Text(.tabSettings)
                }
        }
        .environmentObject(localizationManager)
    }
}

#Preview {
    ContentView()
}
