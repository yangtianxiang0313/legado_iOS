//
//  BookshelfView.swift
//  legado
//
//  Created by Legado on 2024/01/01.
//

import SwiftUI
import SFSafeSymbols

struct BookshelfView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var showingAddBook = false
    
    var body: some View {
        NavigationView {
            VStack {
                if dataManager.books.isEmpty {
                    emptyView
                } else {
                    bookList
                }
            }
            .navigationTitle(.bookshelfTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddBook = true
                    }) {
                        Image(systemSymbol: .plus)
                    }
                }
            }
            .sheet(isPresented: $showingAddBook) {
                AddBookView()
            }
        }
        .onReceive(localizationManager.$currentLanguage) { _ in
            // 触发视图更新
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemSymbol: .booksVertical)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(.bookshelfEmpty)
                .font(.title2)
                .fontWeight(.medium)
            
            Text(.bookshelfEmptyDesc)
                .font(.body)
                .foregroundColor(.secondary)
            
            Button(.addSampleBooks) {
                dataManager.addSampleBooks()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private var bookList: some View {
        List {
            ForEach(dataManager.books) { book in
                BookRowView(book: book)
                    .swipeActions(edge: .trailing) {
                        Button(.delete) {
                            dataManager.removeBook(book)
                        }
                        .tint(.red)
                    }
            }
        }
    }
}

struct BookRowView: View {
    let book: Book
    
    var body: some View {
        HStack {
            Image(systemSymbol: .book)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                if let lastChapter = book.lastChapter {
                    Text(lastChapter)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                // 显示阅读进度
                let progress = Double(book.durChapterIndex) / Double(max(book.totalChapterNum, 1))
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                if let updateTime = book.latestChapterTime {
                    Text(updateTime, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddBookView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataManager = DataManager.shared
    
    @State private var bookName = ""
    @State private var bookAuthor = ""
    @State private var bookUrl = ""
    @State private var bookIntro = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(.addBook) {
                     TextField(.bookName, text: $bookName)
                     TextField(.bookAuthor, text: $bookAuthor)
                     TextField(.bookUrl, text: $bookUrl)
                         .keyboardType(.URL)
                     TextField(.bookIntro, text: $bookIntro, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(.addBook)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(.cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(.save) {
                        saveBook()
                    }
                    .disabled(bookName.isEmpty || bookAuthor.isEmpty)
                }
            }
        }
    }
    
    private func saveBook() {
        var book = Book()
        book.name = bookName
        book.author = bookAuthor
        book.bookUrl = bookUrl.isEmpty ? "" : bookUrl
        book.intro = bookIntro.isEmpty ? nil : bookIntro
        
        dataManager.addBook(book)
        dismiss()
    }
}

#Preview {
    BookshelfView()
}
