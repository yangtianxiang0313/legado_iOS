//
//  SettingsView.swift
//  legado
//
//  Created by Legado on 2024/01/01.
//

import SwiftUI
import SFSafeSymbols

struct SettingsView: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var selectedLanguage: String = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(.generalSettings) {
                    HStack {
                        Image(systemSymbol: .globe)
                        .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text(.language)
                        
                        Spacer()
                        
                        Picker(.language, selection: $selectedLanguage) {
                            ForEach(localizationManager.supportedLanguages, id: \.code) { language in
                                Text(language.name)
                                    .tag(language.code)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section(.about) {
                    HStack {
                        Image(systemSymbol: .infoCircle)
                        .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text(.version)
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(.settings)
        }
        .onAppear {
            selectedLanguage = localizationManager.currentLanguage
        }
        .onChange(of: selectedLanguage) { _, newLanguage in
            localizationManager.setLanguage(newLanguage)
        }
    }
}

#Preview {
    SettingsView()
}
