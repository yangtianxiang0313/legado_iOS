//
//  RuleEngineTestView.swift
//  legado
//
//  规则引擎测试视图
//

import SwiftUI

struct RuleEngineTestView: View {
    @State private var testResults: [TestResult] = []
    @State private var isRunning = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                // 标签页选择
                Picker("测试类型", selection: $selectedTab) {
                    Text("基础测试").tag(0)
                    Text("实际解析").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if selectedTab == 0 {
                    basicTestView
                } else {
                    realParsingTestView
                }
                
                Spacer()
            }
            .navigationTitle("规则引擎测试")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // 基础测试视图
    private var basicTestView: some View {
        VStack {
            Button(action: runBasicTests) {
                HStack {
                    if isRunning {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text(isRunning ? "测试中..." : "运行基础测试")
                }
            }
            .disabled(isRunning)
            .buttonStyle(.borderedProminent)
            .padding()
            
            List(testResults, id: \.name) { result in
                TestResultRow(result: result)
            }
        }
    }
    
    // 实际解析测试视图
    private var realParsingTestView: some View {
        VStack {
            Button(action: runRealParsingTests) {
                HStack {
                    if isRunning {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text(isRunning ? "解析中..." : "运行解析测试")
                }
            }
            .disabled(isRunning)
            .buttonStyle(.borderedProminent)
            .padding()
            
            List(testResults, id: \.name) { result in
                TestResultRow(result: result)
            }
        }
    }
    
    // 运行基础测试
    private func runBasicTests() {
        isRunning = true
        testResults.removeAll()
        
        DispatchQueue.global(qos: .userInitiated).async {
            let analyzer = UnifiedRuleAnalyzer()
            var results: [TestResult] = []
            
            // 测试规则类型检测
            let ruleTests = [
                ("h1.title", RuleType.jsoup),
                ("//h1[@class='title']", RuleType.xpath),
                ("##标题：(.+)", RuleType.regex),
                ("$.book.title", RuleType.jsonPath),
                ("@js:document.title", RuleType.javascript)
            ]
            
            for (rule, expectedType) in ruleTests {
                let detectedType = analyzer.detectRuleType(rule)
                let success = detectedType == expectedType
                results.append(TestResult(
                    name: "规则检测: \(rule)",
                    success: success,
                    details: "预期: \(expectedType.description), 检测: \(detectedType.description)"
                ))
            }
            
            // 测试规则验证
            let validationTests = [
                ("h1", true),
                (".class", true),
                ("#id", true),
                ("", false),
                ("//valid/xpath", true),
                ("//invalid[xpath", false)
            ]
            
            for (rule, shouldBeValid) in validationTests {
                let ruleType = analyzer.detectRuleType(rule)
                let isValid = analyzer.isValidRule(rule, type: ruleType)
                let success = isValid == shouldBeValid
                results.append(TestResult(
                    name: "规则验证: \(rule.isEmpty ? "空规则" : rule)",
                    success: success,
                    details: "预期: \(shouldBeValid ? "有效" : "无效"), 结果: \(isValid ? "有效" : "无效")"
                ))
            }
            
            DispatchQueue.main.async {
                self.testResults = results
                self.isRunning = false
            }
        }
    }
    
    // 运行实际解析测试
    private func runRealParsingTests() {
        isRunning = true
        testResults.removeAll()
        
        DispatchQueue.global(qos: .userInitiated).async {
            let analyzer = UnifiedRuleAnalyzer()
            var results: [TestResult] = []
            
            let testHTML = """
            <html>
            <head><title>测试页面</title></head>
            <body>
                <div class="container">
                    <h1 id="title">小说标题</h1>
                    <div class="author">作者：张三</div>
                    <p class="chapter">第一章</p>
                    <p class="chapter">第二章</p>
                    <a href="/book/123">阅读链接</a>
                </div>
            </body>
            </html>
            """
            
            // CSS选择器测试
            let cssTests = [
                ("h1#title", "小说标题"),
                (".author", "作者：张三"),
                ("title", "测试页面")
            ]
            
            for (rule, expected) in cssTests {
                do {
                    let result = try analyzer.analyzeFirst(content: testHTML, rule: rule)
                    let success = result?.contains(expected) == true
                    results.append(TestResult(
                        name: "CSS: \(rule)",
                        success: success,
                        details: "预期包含: \(expected), 结果: \(result ?? "nil")"
                    ))
                } catch {
                    results.append(TestResult(
                        name: "CSS: \(rule)",
                        success: false,
                        details: "错误: \(error.localizedDescription)"
                    ))
                }
            }
            
            // XPath测试
            let xpathTests = [
                ("//h1[@id='title']", "小说标题"),
                ("//div[@class='author']", "作者：张三")
            ]
            
            for (rule, expected) in xpathTests {
                do {
                    let result = try analyzer.analyzeFirst(content: testHTML, rule: rule)
                    let success = result?.contains(expected) == true
                    results.append(TestResult(
                        name: "XPath: \(rule)",
                        success: success,
                        details: "预期包含: \(expected), 结果: \(result ?? "nil")"
                    ))
                } catch {
                    results.append(TestResult(
                        name: "XPath: \(rule)",
                        success: false,
                        details: "错误: \(error.localizedDescription)"
                    ))
                }
            }
            
            // 正则表达式测试
            let regexTests = [
                ("##作者：(.+)", "张三"),
                ("##第(.+)章", "一")
            ]
            
            for (rule, expected) in regexTests {
                do {
                    let result = try analyzer.analyzeFirst(content: testHTML, rule: rule)
                    let success = result?.contains(expected) == true
                    results.append(TestResult(
                        name: "Regex: \(rule)",
                        success: success,
                        details: "预期包含: \(expected), 结果: \(result ?? "nil")"
                    ))
                } catch {
                    results.append(TestResult(
                        name: "Regex: \(rule)",
                        success: false,
                        details: "错误: \(error.localizedDescription)"
                    ))
                }
            }
            
            DispatchQueue.main.async {
                self.testResults = results
                self.isRunning = false
            }
        }
    }
}

// 测试结果数据模型
struct TestResult {
    let name: String
    let success: Bool
    let details: String
}

// 测试结果行视图
struct TestResultRow: View {
    let result: TestResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(result.success ? .green : .red)
                Text(result.name)
                    .font(.headline)
                Spacer()
            }
            
            Text(result.details)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    RuleEngineTestView()
}
