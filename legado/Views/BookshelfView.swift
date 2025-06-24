//
//  BookshelfView.swift
//  legado
//
//  Created by Legado on 2024/01/01.
//

import SwiftUI
import SFSafeSymbols

struct BookshelfView: View {
    @StateObject private var bookManager = BookManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var showingAddBook = false
    
    var body: some View {
        NavigationView {
            VStack {
                if bookManager.items.isEmpty {
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
                bookManager.addSampleBooks()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private var bookList: some View {
        List {
            ForEach(bookManager.items) { book in
                BookRowView(book: book)
                    .swipeActions(edge: .trailing) {
                        Button(.delete) {
                            Task {
                                try? await bookManager.removeAsync(book)
                            }
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
                
                if let author = book.author {
                    Text(author)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddBookView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var bookManager = BookManager.shared
    
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
        let book = Book(name: bookName)
        book.author = bookAuthor
        book.bookUrl = bookUrl.isEmpty ? "" : bookUrl
        
        Task {
            try? await bookManager.addAsync(book)
            await MainActor.run {
                dismiss()
            }
        }
    }
}

#Preview {
    BookshelfView()
}
