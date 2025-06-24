//
//  BookManager.swift
//  legado
//
//  Created by Legado on 2024/01/01.
//

import Foundation
import Combine
import WCDBSwift

// MARK: - 书籍管理器

class BookManager: DataManaging {
    typealias Item = Book
    
    static let shared = BookManager()
    
    @Published var items: [Book] = []
    
    private init() {
        initialize()
    }
    // MARK: - 示例数据
    
    func addSampleBooks() {
        Task {
            let sampleBooks = [
                Book(name: "三体", author: "刘慈欣", bookUrl: "https://example.com/threebody"),
                Book(name: "流浪地球", author: "刘慈欣", bookUrl: "https://example.com/wandering-earth"),
                Book(name: "球状闪电", author: "刘慈欣", bookUrl: "https://example.com/ball-lightning")
            ]
            
            for book in sampleBooks {
                try? await addAsync(book)
            }
        }
    }
}

// MARK: - 阅读状态枚举

enum ReadingStatus: Int, CaseIterable {
    case notStarted = 0
    case reading = 1
    case finished = 2
    case paused = 3
    
    var displayName: String {
        switch self {
        case .notStarted: return "未开始"
        case .reading: return "阅读中"
        case .finished: return "已完成"
        case .paused: return "暂停"
        }
    }
}
