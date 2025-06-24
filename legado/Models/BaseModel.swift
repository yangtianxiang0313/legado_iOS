//
//  BaseModel.swift
//  legado
//
//  Created by 杨天翔 on 24/6/25.
//
import WCDBSwift
import SwiftUI

protocol TableName {
    static var tableName: String { get }
}

typealias TableModel = TableCodable & ObservableObject & TableName & Identifiable
