//
//  LegadoURLImportService.swift
//  legado
//
//  legado://import/{path}?src={url} 解析与导入
//  对应 api-and-import §1、Android OnLineImportActivity
//

import Foundation

/// legado:// URL 导入结果
enum LegadoImportResult {
    case success(count: Int, path: String)
    case unsupportedPath(path: String)
    case missingSrc
    case failed(Error)
}

struct LegadoURLImportService {

    private let httpClient: HttpClient
    private let bookSourceImport: BookSourceImportService

    init(
        httpClient: HttpClient = HttpClient(),
        bookSourceImport: BookSourceImportService = BookSourceImportService()
    ) {
        self.httpClient = httpClient
        self.bookSourceImport = bookSourceImport
    }

    /// 处理 legado:// URL，解析 path 与 src，下载并导入
    /// - Parameter url: 打开的 URL，如 legado://import/bookSource?src=https://...
    /// - Returns: 导入结果
    func handle(url: URL) async -> LegadoImportResult {
        guard url.scheme == "legado" else {
            return .unsupportedPath(path: url.absoluteString)
        }

        // path: /bookSource -> bookSource
        let path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")).lowercased()
        guard !path.isEmpty else {
            return .unsupportedPath(path: url.path)
        }

        guard let src = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first(where: { $0.name == "src" })?
            .value,
              let srcURL = URL(string: src) else {
            return .missingSrc
        }

        switch path {
        case "booksource":
            return await importBookSource(from: srcURL.absoluteString)
        case "rsssource":
            // 后续实现
            return .unsupportedPath(path: path)
        default:
            return .unsupportedPath(path: path)
        }
    }

    private func importBookSource(from srcURL: String) async -> LegadoImportResult {
        do {
            let json = try await httpClient.request(url: srcURL)
            let count = try bookSourceImport.importFromJSON(json)
            return .success(count: count, path: "bookSource")
        } catch {
            return .failed(error)
        }
    }
}
