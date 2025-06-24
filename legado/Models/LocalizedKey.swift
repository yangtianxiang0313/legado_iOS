//
//  swift
//  legado
//
//  Created by Legado on 2024/01/01.
//

import Foundation
import SwiftUI

enum LocalizedKey: String, CaseIterable {
    // MARK: - General
    case ok = "ok"
    case cancel = "cancel"
    case delete = "delete"
    case edit = "edit"
    case save = "save"
    case add = "add"
    case search = "search"
    case settings = "settings"
    case back = "back"
    case done = "done"
    case loading = "loading"
    case error = "error"
    case success = "success"
    case warning = "warning"
    case info = "info"
    
    // MARK: - Tab Bar
    case tabBookshelf = "tab_bookshelf"
    case tabSearch = "tab_search"
    case tabExplore = "tab_explore"
    case tabSettings = "tab_settings"
    
    // MARK: - Bookshelf
    case bookshelfTitle = "bookshelf_title"
    case bookshelfEmpty = "bookshelf_empty"
    case bookshelfEmptyDesc = "bookshelf_empty_desc"
    case addSampleBooks = "add_sample_books"
    case addBook = "add_book"
    case bookInfo = "book_info"
    case bookName = "book_name"
    case bookAuthor = "book_author"
    case bookUrl = "book_url"
    case bookIntro = "book_intro"
    case lastChapter = "last_chapter"
    case readingProgress = "reading_progress"
    case updateTime = "update_time"
    
    // MARK: - Reading
    case readingTitle = "reading_title"
    case chapterList = "chapter_list"
    case readingSettings = "reading_settings"
    case fontSize = "font_size"
    case lineHeight = "line_height"
    case pageMargin = "page_margin"
    case backgroundColor = "background_color"
    case textColor = "text_color"
    case nightMode = "night_mode"
    case brightness = "brightness"
    case fullScreen = "full_screen"
    
    // MARK: - Search
    case searchTitle = "search_title"
    case searchPlaceholder = "search_placeholder"
    case searchResult = "search_result"
    case noResult = "no_result"
    
    // MARK: - Settings
    case settingsTitle = "settings_title"
    case generalSettings = "general_settings"
    case readingSettingsTitle = "reading_settings_title"
    case backupSettings = "backup_settings"
    case about = "about"
    case language = "language"
    case theme = "theme"
    case autoBackup = "auto_backup"
    case exportData = "export_data"
    case importData = "import_data"
    case clearCache = "clear_cache"
    case version = "version"
    
    // MARK: - Language Options
    case languageSystem = "language_system"
    case languageZhHans = "language_zh_hans"
    case languageZhHant = "language_zh_hant"
    case languageEn = "language_en"
    case languageJa = "language_ja"
    case languageKo = "language_ko"
    
    // MARK: - Theme Options
    case themeLight = "theme_light"
    case themeDark = "theme_dark"
    case themeAuto = "theme_auto"
    
    // MARK: - Error Messages
    case errorNetwork = "error_network"
    case errorParse = "error_parse"
    case errorFileNotFound = "error_file_not_found"
    case errorInvalidUrl = "error_invalid_url"
    case errorUnknown = "error_unknown"
    
    // MARK: - Success Messages
    case successBookAdded = "success_book_added"
    case successBookDeleted = "success_book_deleted"
    case successSettingsSaved = "success_settings_saved"
    case successDataExported = "success_data_exported"
    case successDataImported = "success_data_imported"
    
    /// 获取本地化字符串键
    var localizedStringKey: LocalizedStringKey {
        return LocalizedStringKey(self.rawValue)
    }
    
    /// 获取本地化字符串（保持向后兼容）
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self.rawValue)
    }
    
    /// 带参数的本地化字符串
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}
