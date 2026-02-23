//
//  HttpClient.swift
//  legado
//
//  基于 Alamofire 的网络请求封装，用于书源规则请求
//  支持 header（BookSource 的 JSON 格式：{"User-Agent":"..."}）
//

import Alamofire
import Foundation

struct HttpClient {

    /// 按 URL 发起 GET 请求，返回 body 字符串
    /// - Parameters:
    ///   - url: 请求 URL
    ///   - headers: 可选，JSON 字符串如 `{"User-Agent":"..."}` 解析为 HTTP 头
    /// - Returns: 响应 body 字符串
    func request(url: String, headers: String? = nil) async throws -> String {
        let headerDict = parseHeaders(headers)
        let dataResponse = await AF.request(
            url,
            method: .get,
            parameters: nil,
            headers: HTTPHeaders(headerDict)
        )
        .validate()
        .serializingString()
        .response

        switch dataResponse.result {
        case .success(let body):
            return body
        case .failure(let error):
            throw error
        }
    }

    /// 解析 header JSON 为 [String: String]
    /// 格式：`{"User-Agent":"...", "Cookie":"..."}` 或 nil
    private func parseHeaders(_ json: String?) -> [String: String] {
        guard let json = json?.trimmingCharacters(in: .whitespaces),
              !json.isEmpty,
              let data = json.data(using: .utf8),
              let dict = try? JSONDecoder().decode([String: String].self, from: data) else {
            return [:]
        }
        return dict
    }
}
