//
//  BookSourceManager.swift
//  legado
//
//  Created by Legado on 2024/01/01.
//

import Foundation
import Combine
import WCDBSwift

// MARK: - 书源错误类型
enum BookSourceError: Error, LocalizedError {
    case parseError(String)
    case networkError(String)
    case validationError(String)
    case duplicateSource(String)
    case sourceNotFound(String)
    
    var errorDescription: String? {
        switch self {
        case .parseError(let message):
            return "解析错误: \(message)"
        case .networkError(let message):
            return "网络错误: \(message)"
        case .validationError(let message):
            return "验证错误: \(message)"
        case .duplicateSource(let message):
            return "重复书源: \(message)"
        case .sourceNotFound(let message):
            return "书源未找到: \(message)"
        }
    }
}

// MARK: - 书源管理器
class BookSourceManager: DataManaging {
    typealias Item = BookSource
    
    @Published var items: [BookSource] = []
    
    init() {
        initialize()
    }
    
}
