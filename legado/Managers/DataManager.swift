//
//  DataManager.swift
//  legado
//
//  Created by Legado on 2024/01/01.
//

import Foundation
import Combine

// MARK: - 数据管理器
class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var books: [Book] = []
    
    private let userDefaults = UserDefaults.standard
    private let booksKey = "SavedBooks"
    
    private init() {
        loadBooks()
    }
    
    // MARK: - 书籍管理
    
    func loadBooks() {
        if let data = userDefaults.data(forKey: booksKey),
           let savedBooks = try? JSONDecoder().decode([Book].self, from: data) {
            self.books = savedBooks
        }
    }
    
    func saveBooks() {
        if let data = try? JSONEncoder().encode(books) {
            userDefaults.set(data, forKey: booksKey)
        }
    }
    
    func addBook(_ book: Book) {
        books.append(book)
        saveBooks()
    }
    
    func removeBook(_ book: Book) {
        books.removeAll { $0.id == book.id }
        saveBooks()
    }
    
    func updateBook(_ book: Book) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index] = book
            saveBooks()
        }
    }
    
    // MARK: - 示例数据
    
    func addSampleBooks() {
        let sampleBooks = [
            Book(
                name: "示例小说1",
                author: "作者1",
                intro: "这是一本示例小说的简介...",
                coverUrl: "",
                bookUrl: "https://example.com/book1",
                tocUrl: "https://example.com/book1/toc",
                lastChapter: "第一章 开始",
                latestChapterTime: Date(),
                lastCheckTime: Date(),
                totalChapterNum: 100,
                durChapterIndex: 0,
                durChapterPos: 0,
                durChapterTime: Date(),
                durChapterTitle: "第一章 开始",
                canUpdate: true,
                order: 0,
                originName: "示例书源",
                origin: "https://example.com",
                wordCount: "100万字",
                kind: "玄幻",
                variable: ""
            ),
            Book(
                name: "示例小说2",
                author: "作者2",
                intro: "这是另一本示例小说的简介...",
                coverUrl: "",
                bookUrl: "https://example.com/book2",
                tocUrl: "https://example.com/book2/toc",
                lastChapter: "第一章 序幕",
                latestChapterTime: Date(),
                lastCheckTime: Date(),
                totalChapterNum: 80,
                durChapterIndex: 0,
                durChapterPos: 0,
                durChapterTime: Date(),
                durChapterTitle: "第一章 序幕",
                canUpdate: true,
                order: 1,
                originName: "示例书源",
                origin: "https://example.com",
                wordCount: "80万字",
                kind: "都市",
                variable: ""
            )
        ]
        
        for book in sampleBooks {
            addBook(book)
        }
    }
}

// MARK: - Book 扩展
extension Book {
    init(name: String, author: String, intro: String, coverUrl: String, bookUrl: String, tocUrl: String, lastChapter: String, latestChapterTime: Date, lastCheckTime: Date, totalChapterNum: Int, durChapterIndex: Int, durChapterPos: Int, durChapterTime: Date, durChapterTitle: String, canUpdate: Bool, order: Int, originName: String, origin: String, wordCount: String, kind: String, variable: String) {
        self.init()
        self.name = name
        self.author = author
        self.intro = intro
        self.coverUrl = coverUrl
        self.bookUrl = bookUrl
        self.tocUrl = tocUrl
        self.lastChapter = lastChapter
        self.latestChapterTime = latestChapterTime
        self.lastCheckTime = lastCheckTime
        self.totalChapterNum = totalChapterNum
        self.durChapterIndex = durChapterIndex
        self.durChapterPos = durChapterPos
        self.durChapterTime = durChapterTime
        self.durChapterTitle = durChapterTitle
        self.canUpdate = canUpdate
        self.order = order
        self.originName = originName
        self.origin = origin
        self.wordCount = wordCount
        self.kind = kind
        self.variable = variable
    }
}