//
//  Book.swift
//  legado
//
//  Created by Legado on 2024/01/01.
//

import Foundation

// MARK: - 书籍模型
struct Book: Codable, Identifiable {
    let id = UUID()
    var name: String                    // 书名
    var author: String                  // 作者
    var intro: String?                  // 简介
    var coverUrl: String?               // 封面URL
    var bookUrl: String                // 书籍URL
    var tocUrl: String?                 // 目录URL
    var lastChapter: String?            // 最新章节
    var latestChapterTime: Date?        // 最新章节时间
    var lastCheckTime: Date?            // 最后检查时间
    var totalChapterNum: Int           // 总章节数
    var durChapterIndex: Int           // 当前章节索引
    var durChapterPos: Int             // 当前章节位置
    var durChapterTime: Date?           // 当前章节时间
    var durChapterTitle: String?        // 当前章节标题
    var canUpdate: Bool                // 是否可更新
    var order: Int                     // 排序
    var originName: String?             // 书源名称
    var origin: String?                 // 书源URL
    var wordCount: String?              // 字数
    var kind: String?                   // 分类
    var variable: String?               // 自定义变量
    
    init() {
        self.name = ""
        self.author = ""
        self.intro = nil
        self.coverUrl = nil
        self.bookUrl = ""
        self.tocUrl = nil
        self.lastChapter = nil
        self.latestChapterTime = nil
        self.lastCheckTime = nil
        self.totalChapterNum = 0
        self.durChapterIndex = 0
        self.durChapterPos = 0
        self.durChapterTime = nil
        self.durChapterTitle = nil
        self.canUpdate = true
        self.order = 0
        self.originName = nil
        self.origin = nil
        self.wordCount = nil
        self.kind = nil
        self.variable = nil
    }
}

// MARK: - 章节模型
struct Chapter: Codable, Identifiable {
    let id = UUID()
    var url: String                     // 章节URL
    var title: String                   // 章节标题
    var baseUrl: String?                // 基础URL
    var bookUrl: String                 // 书籍URL
    var index: Int                      // 章节索引
    var content: String?                // 章节内容
    
    init() {
        self.url = ""
        self.title = ""
        self.baseUrl = nil
        self.bookUrl = ""
        self.index = 0
        self.content = nil
    }
}