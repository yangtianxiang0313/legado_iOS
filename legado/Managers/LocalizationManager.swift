//
//  LocalizationManager.swift
//  legado
//
//  Created by Legado on 2024/01/01.
//

import SwiftUI
import Foundation

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String = "zh-Hans"
    
    private var bundle: Bundle = Bundle.main
    
    private init() {
        // 获取系统语言或用户设置的语言
        if let savedLanguage = UserDefaults.standard.string(forKey: "app_language") {
            currentLanguage = savedLanguage
        } else {
            // 使用系统语言
            currentLanguage = Locale.current.language.languageCode?.identifier ?? "zh-Hans"
        }
        setLanguage(currentLanguage)
    }
    
    func setLanguage(_ language: String) {
        currentLanguage = language
        UserDefaults.standard.set(language, forKey: "app_language")
        
        // 设置本地化bundle
        if let path = Bundle.main.path(forResource: language, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            self.bundle = bundle
        } else {
            self.bundle = Bundle.main
        }
        
        objectWillChange.send()
    }
    
    func localizedString(for key: String) -> String {
        return bundle.localizedString(forKey: key, value: key, table: nil)
    }
    
    // 支持的语言列表
    var supportedLanguages: [(code: String, name: String)] {
        return [
            ("zh-Hans", "简体中文"),
            ("zh-Hant", "繁體中文"),
            ("en", "English"),
            ("ja", "日本語"),
            ("ko", "한국어")
        ]
    }
}
