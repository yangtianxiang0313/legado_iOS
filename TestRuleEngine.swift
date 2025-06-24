#!/usr/bin/env swift

import Foundation

// 简单的测试脚本来验证规则引擎功能
// 由于这是一个独立的Swift脚本，我们需要模拟一些基本功能

print("=== 规则引擎测试 ===")

// 测试HTML内容
let testHTML = """
<!DOCTYPE html>
<html>
<head>
    <title>测试页面</title>
</head>
<body>
    <div class="container">
        <h1 id="title">小说标题</h1>
        <div class="author">作者：张三</div>
        <div class="content">
            <p class="chapter">第一章 开始</p>
            <p class="chapter">第二章 发展</p>
            <p class="chapter">第三章 高潮</p>
        </div>
        <a href="/book/123" class="link">阅读全文</a>
    </div>
</body>
</html>
"""

// 测试JSON内容
let testJSON = """
{
    "book": {
        "title": "测试小说",
        "author": "李四",
        "chapters": [
            {"name": "第一章", "url": "/chapter/1"},
            {"name": "第二章", "url": "/chapter/2"}
        ]
    }
}
"""

// 模拟规则类型检测
func detectRuleType(_ rule: String) -> String {
    if rule.hasPrefix("@js:") {
        return "JavaScript"
    } else if rule.hasPrefix("$..") || rule.contains("$.") {
        return "JSONPath"
    } else if rule.contains("//") || rule.contains("@") {
        return "XPath"
    } else if rule.hasPrefix("##") {
        return "Regex"
    } else if rule.contains("&&") || rule.contains("||") {
        return "Mixed"
    } else {
        return "JSoup CSS"
    }
}

// 测试用例
let testRules = [
    ("h1#title", "JSoup CSS选择器"),
    (".author", "JSoup CSS选择器"),
    (".chapter", "JSoup CSS选择器"),
    ("//h1[@id='title']", "XPath表达式"),
    ("//div[@class='author']", "XPath表达式"),
    ("##作者：(.+)", "正则表达式"),
    ("$.book.title", "JSONPath表达式"),
    ("$.book.chapters[*].name", "JSONPath表达式"),
    ("@js:document.title", "JavaScript表达式")
]

print("\n=== 规则类型检测测试 ===")
for (rule, expected) in testRules {
    let detected = detectRuleType(rule)
    let status = detected.contains(expected.split(separator: " ")[0]) ? "✅" : "❌"
    print("\(status) 规则: \(rule)")
    print("   预期: \(expected), 检测: \(detected)")
}

print("\n=== 解析器功能验证 ===")
print("📝 HTML内容长度: \(testHTML.count) 字符")
print("📝 JSON内容长度: \(testJSON.count) 字符")

print("\n🔍 CSS选择器规则测试:")
print("   h1#title -> 应该提取: '小说标题'")
print("   .author -> 应该提取: '作者：张三'")
print("   .chapter -> 应该提取: 3个章节标题")

print("\n🔍 XPath规则测试:")
print("   //h1[@id='title'] -> 应该提取: '小说标题'")
print("   //div[@class='author'] -> 应该提取: '作者：张三'")
print("   //p[@class='chapter'] -> 应该提取: 3个章节")

print("\n🔍 正则表达式测试:")
print("   ##作者：(.+) -> 应该提取: '张三'")
print("   ##第(.+)章 -> 应该提取: 章节编号")

print("\n🔍 JSONPath测试:")
print("   $.book.title -> 应该提取: '测试小说'")
print("   $.book.author -> 应该提取: '李四'")
print("   $.book.chapters[*].name -> 应该提取: 2个章节名")

print("\n=== 测试完成 ===")
print("💡 提示: 要进行实际功能测试，请在Xcode中运行RuleEngineTests")
print("💡 或者创建一个简单的iOS应用来测试UnifiedRuleAnalyzer")