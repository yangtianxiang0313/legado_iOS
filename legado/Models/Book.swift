//
//  Book.swift
//  legado
//
//  Created by Legado on 2024/01/01.
//

import Foundation
import WCDBSwift

// MARK: - 书籍模型
final class Book: TableModel {
    static let tableName = "books"
    
    var id: String = UUID().uuidString
    var name: String = ""
    var author: String?
    var bookUrl: String?
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = Book
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        case id
        case name
        case author
        case bookUrl
        case createdAt
        case updatedAt
    }
    
    // 便利初始化器
    convenience init(name: String, author: String? = nil, bookUrl: String? = nil) {
        self.init()
        self.name = name
        self.author = author
        self.bookUrl = bookUrl
    }
}

// MARK: - 章节模型
final class Chapter: TableModel {
    static let tableName = "chapters"
    
    var id: String = UUID().uuidString
    var bookId: String = ""
    var title: String = ""
    var url: String?
    var index: Int = 0
    var createdAt: Date = Date()
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = Chapter
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        case id
        case bookId
        case title
        case url
        case index
        case createdAt
    }
    
    // 便利初始化器
    convenience init(bookId: String, title: String, url: String? = nil, index: Int = 0) {
        self.init()
        self.bookId = bookId
        self.title = title
        self.url = url
        self.index = index
    }
}
