//
//  ChapterManager.swift
//  legado
//
//  Created by Legado on 2024/01/01.
//

import Foundation
import Combine
import WCDBSwift

// MARK: - 章节管理器

class ChapterManager: DataManaging {
    typealias Item = Chapter
    
    static let shared = ChapterManager()
    
    @Published var items: [Chapter] = []
    
    // 兼容性属性
    var chapters: [Chapter] {
        get { items }
        set { items = newValue }
    }
    
    private init() {
        initialize()
    }
}
