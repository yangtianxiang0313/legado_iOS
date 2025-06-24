//
//  SwiftUIExtensions.swift
//  legado
//
//  Created by Legado on 2024/01/01.
//

import SwiftUI
import SFSafeSymbols

// MARK: - Text Extensions
extension Text {
    /// 使用LocalizedKey初始化Text
    init(_ key: LocalizedKey) {
        self.init(key.localizedStringKey)
    }
}

// MARK: - String Extensions
extension String {
    /// 使用LocalizedKey初始化String
    init(_ key: LocalizedKey) {
        self = key.localized
    }
    
    /// 获取本地化字符串（保持向后兼容）
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
    
    /// 带参数的本地化字符串（保持向后兼容）
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}



// MARK: - Button Extensions
extension Button where Label == Text {
    /// 使用LocalizedKey创建按钮
    init(_ key: LocalizedKey, action: @escaping () -> Void) {
        self.init(action: action) {
            Text(key.localizedStringKey)
        }
    }
}

// MARK: - Label Extensions
extension Label where Title == Text, Icon == Image {
    /// 使用LocalizedKey和SFSymbol创建标签
    init(_ key: LocalizedKey, systemSymbol: SFSymbol) {
        self.init(key.localizedStringKey, systemImage: systemSymbol.rawValue)
    }
    
    /// 使用LocalizedKey和系统图标名称创建标签
    init(_ key: LocalizedKey, systemName: String) {
        self.init(key.localizedStringKey, systemImage: systemName)
    }
}

// MARK: - NavigationLink Extensions
extension NavigationLink where Label == Text {
    /// 使用LocalizedKey创建导航链接
    init(_ key: LocalizedKey, destination: @escaping () -> Destination) {
        self.init(destination: destination) {
            Text(key.localizedStringKey)
        }
    }
}

// MARK: - Section Extensions
extension Section where Parent == Text, Content : View, Footer == EmptyView {
    /// 使用LocalizedKey创建Section
    init(_ key: LocalizedKey, @ViewBuilder content: () -> Content) {
        self.init(key.localizedStringKey, content: content)
    }
}

// MARK: - Picker Extensions
extension Picker where Label == Text {
    /// 使用LocalizedKey创建Picker
    init(_ key: LocalizedKey, selection: Binding<SelectionValue>, @ViewBuilder content: () -> Content) {
        self.init(key.localizedStringKey, selection: selection, content: content)
    }
}

// MARK: - TextField Extensions
extension TextField where Label == Text {
    /// 使用LocalizedKey创建TextField
    init(_ key: LocalizedKey, text: Binding<String>) {
        self.init(key.localizedStringKey, text: text)
    }
    
    /// 使用LocalizedKey创建多行TextField
    init(_ key: LocalizedKey, text: Binding<String>, axis: Axis) {
        self.init(key.localizedStringKey, text: text, axis: axis)
    }
}

// MARK: - View Extensions
extension View {
    /// 使用LocalizedKey设置导航标题
    func navigationTitle(_ key: LocalizedKey) -> some View {
        self.navigationTitle(key.localizedStringKey)
    }
}
