//
//  LogConfig.swift
//  legado
//
//  App 启动时配置 CocoaLumberjack，统一日志输出
//  对应 Android AppConfig、App.kt 中日志初始化
//

import CocoaLumberjackSwift
import Foundation

enum LogConfig {

    /// App 启动时调用，配置控制台 + 文件日志
    static func setup() {
        #if DEBUG
        dynamicLogLevel = .debug
        #else
        dynamicLogLevel = .info
        #endif

        let console = DDOSLogger.sharedInstance
        DDLog.add(console)

        let fileLogger = DDFileLogger()
        fileLogger.rollingFrequency = 60 * 60 * 24  // 24 小时滚动
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)

        DDLogInfo("LogConfig 已初始化")
    }

    /// 验证用：调用日志 API，测试可验证无崩溃
    static func logTestMessage() {
        DDLogInfo("Step 0.4 验证：日志 API 可调用")
    }
}
