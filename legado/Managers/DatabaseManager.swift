//
//  DatabaseManager.swift
//  legado
//
//  Created by Legado on 2024/01/01.
//

import Foundation
import WCDBSwift

// MARK: - 数据库管理单例
class DatabaseManager {
    static let shared = DatabaseManager()
    let database: Database
    
    private init() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let dbPath = "\(documentsPath)/legado.db"
        self.database = Database(at: dbPath)
        setupTables()
    }
    
    private func setupTables() {
        do {
            try database.create(table: Book.tableName, of: Book.self)
            try database.create(table: BookSource.tableName, of: BookSource.self)
            try database.create(table: Chapter.tableName, of: Chapter.self)
            print("数据库表创建成功")
        } catch {
            print("创建数据库表失败: \(error)")
        }
    }
}

// MARK: - 核心数据管理协议
protocol DataManaging: ObservableObject {
    associatedtype Item: TableModel
    
    var items: [Item] { get set }
    
    // 主要接口（同步）
    func add(_ item: Item)
    func remove(_ item: Item)
    func update(_ item: Item)
    
    // 异步接口
    func addAsync(_ item: Item) async throws
    func removeAsync(_ item: Item) async throws
    func updateAsync(_ item: Item) async throws
    
    // 初始化
    func initialize()
}

// MARK: - 协议扩展提供默认实现
extension DataManaging {
    var database: Database { DatabaseManager.shared.database }
    
    // 同步接口的默认实现（主要接口）
    func add(_ item: Item) {
        Task {
            do {
                try await addAsync(item)
            } catch {
                print("添加失败: \(error)")
            }
        }
    }
    
    func remove(_ item: Item) {
        Task {
            do {
                try await removeAsync(item)
            } catch {
                print("删除失败: \(error)")
            }
        }
    }
    
    func update(_ item: Item) {
        Task {
            do {
                try await updateAsync(item)
            } catch {
                print("更新失败: \(error)")
            }
        }
    }
    
    // 异步接口的默认实现
    func addAsync(_ item: Item) async throws {
        try database.insertOrReplace(item, intoTable: Item.tableName)
        
        await MainActor.run {
            if !self.items.contains(where: { $0.id == item.id }) {
                self.items.append(item)
            }
        }
    }
    
    func removeAsync(_ item: Item) async throws {
        try database.delete(fromTable: Item.tableName, where: Column(named: "id") as! Self.Item.ID == item.id)
        await MainActor.run {
            self.items.removeAll(where: { $0.id == item.id })
        }
    }
    
    func updateAsync(_ item: Item) async throws {
        try database.insertOrReplace(item, intoTable: Item.tableName)
        
        await MainActor.run {
            if let index = self.items.firstIndex(where: { $0.id == item.id }) {
                self.items[index] = item
            }
        }
    }
    
    func initialize() {
        
    }
}
