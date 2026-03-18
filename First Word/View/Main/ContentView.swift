import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = AppStateViewModel()
    @State private var showAddWordView = false
    @State private var showMenu = false
    @State private var showSearchView = false   // ✅ 추가
    @State private var editingWord: Word?

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.displayedWords, id: \.id) { word in
                    if let binding = binding(for: word) {
                        WordRow(
                            word: binding,
                            onEdit: {
                                editingWord = word
                            },
                            onDelete: {
                                viewModel.deleteWord(word)
                            },
                            colorScheme: colorScheme,
                            isDetailed: viewModel.detailedWordIDs.contains(word.id),
                            onToggleDetail: {
                                if viewModel.detailedWordIDs.contains(word.id) {
                                    viewModel.detailedWordIDs.remove(word.id)
                                } else {
                                    viewModel.detailedWordIDs.insert(word.id)
                                }
                            }
                        )
                        .listRowSeparator(.visible)
                        .listRowBackground(Color(.systemBackground))
                    }
                }
            }
            .listStyle(PlainListStyle())
            .background(Color(.systemBackground))
            .navigationBarTitle(viewModel.currentFolder, displayMode: .inline)

            .navigationBarItems(
                leading: Button(action: {
                    showMenu = true
                }) {
                    Image(systemName: "line.horizontal.3")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                },

                trailing: HStack(spacing: 20) {

                    // 🔍 검색 버튼 (기존 설정 버튼 대체)
                    Button(action: {
                        showSearchView = true
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }

                    // ➕ 단어 추가 버튼 (기존 유지)
                    Button(action: {
                        showAddWordView = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                }
            )

            // 메뉴
            .fullScreenCover(isPresented: $showMenu, onDismiss: {
                viewModel.detailedWordIDs.removeAll()
            }) {
                MenuView(viewModel: viewModel)
            }

            // 단어 추가
            .fullScreenCover(isPresented: $showAddWordView) {
                AddWordView(
                    currentFolder: viewModel.currentFolder,
                    onAdd: { newWord in
                        viewModel.addWord(newWord)
                    },
                    onClose: {
                        showAddWordView = false
                    }
                )
            }

            // 🔍 검색 화면 (추가)
            .fullScreenCover(isPresented: $showSearchView) {
                SearchView(
                    viewModel: viewModel,
                    currentFolder: viewModel.currentFolder
                )
            }

            // 단어 수정
            .sheet(item: $editingWord) { word in
                AddWordView(
                    currentFolder: viewModel.currentFolder,
                    editingWord: word
                ) { updatedWord in
                    viewModel.updateWord(updatedWord)
                    editingWord = nil
                } onClose: {
                    editingWord = nil
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - 단어 바인딩
    private func binding(for word: Word) -> Binding<Word>? {
        guard let index = viewModel.displayedWords.firstIndex(where: { $0.id == word.id }) else {
            return nil
        }
        let folder = viewModel.currentFolder
        return Binding(
            get: { viewModel.wordStorage[folder]?[index] ?? word },
            set: { updated in
                viewModel.updateWord(updated)
            }
        )
    }
}
