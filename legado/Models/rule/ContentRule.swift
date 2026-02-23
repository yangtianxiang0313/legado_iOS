//
//  ContentRule.swift
//  legado
//
//  正文处理规则，对应 Android ContentRule
//

import Foundation

struct ContentRule: Codable, Equatable {
    var content: String?
    var title: String?
    var nextContentUrl: String?
    var webJs: String?
    var sourceRegex: String?
    var replaceRegex: String?
    var imageStyle: String?
    var imageDecode: String?
    var payAction: String?
}
