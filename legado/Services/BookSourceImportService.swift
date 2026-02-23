//
//  BookSourceImportService.swift
//  legado
//
//  BookSource JSON 导入，对应 Android ImportOldData.importOldSource、BookSourceController
//  支持 { ... } 单条与 [ { ... }, { ... } ] 数组
//

import Foundation

struct BookSourceImportService {

    private let repository: BookSourceRepository

    init(repository: BookSourceRepository = BookSourceRepository()) {
        self.repository = repository
    }

    /// 从 JSON 字符串解析 BookSource 并写入数据库
    /// - Parameter json: 单条 `{...}` 或数组 `[{...},{...}]`
    /// - Returns: 导入数量
    func importFromJSON(_ json: String) throws -> Int {
        let sources = try parseBookSources(from: json)
        guard !sources.isEmpty else { return 0 }
        try repository.insert(sources)
        return sources.count
    }

    private func parseBookSources(from json: String) throws -> [BookSource] {
        let data = json.data(using: .utf8) ?? Data()
        // 先尝试解析为数组
        if let array = try? JSONDecoder().decode([BookSource].self, from: data) {
            return array.filter { isValid($0) }
        }
        // 再尝试解析为单条
        if let single = try? JSONDecoder().decode(BookSource.self, from: data), isValid(single) {
            return [single]
        }
        return []
    }

    private func isValid(_ source: BookSource) -> Bool {
        !source.bookSourceUrl.trimmingCharacters(in: .whitespaces).isEmpty
            && !source.bookSourceName.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
