import SwiftUI
import Foundation

// MARK: - 단어 모델
struct Word: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var text: String
    var meaning: String
    var folder: String
    var pronunciation: String?
    var exampleSentence: String?

    var isBookmarked: Bool = false
    var isRed: Bool = false
    var isYellow: Bool = false
    var isStrikethrough: Bool = false

    init(
        id: UUID = UUID(),
        text: String,
        meaning: String,
        folder: String,
        pronunciation: String? = nil,
        exampleSentence: String? = nil
    ) {
        self.id = id
        self.text = text
        self.meaning = meaning
        self.folder = folder
        self.pronunciation = pronunciation
        self.exampleSentence = exampleSentence
    }
}

// MARK: - 폴더 모델
struct FolderItem: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

// MARK: - 앱 상태 ViewModel
class AppStateViewModel: ObservableObject {
    @Published var folders: [FolderItem] = []
    @Published var currentFolder: String = "ALL"
    @Published var wordStorage: [String: [Word]] = [:]
    @Published var detailedWordIDs: Set<UUID> = []

    init() {
        loadState()

        if !folders.contains(where: { $0.name == "ALL" }) {
            folders.insert(FolderItem(name: "ALL"), at: 0)
        }

        if folders.filter({ $0.name != "ALL" }).isEmpty {
            folders.append(FolderItem(name: "첫 단어장"))
        }

        if !folders.contains(where: { $0.name == currentFolder }) {
            currentFolder = "ALL"
        }
    }

    // MARK: - 폴더 관련
    func addFolder(name: String) -> Bool {
        guard !folders.contains(where: { $0.name == name }) else { return false }
        folders.append(FolderItem(name: name))
        saveState()
        return true
    }

    func renameFolder(id: UUID, newName: String) {
        guard let index = folders.firstIndex(where: { $0.id == id }) else { return }
        let oldName = folders[index].name
        guard !folders.contains(where: { $0.name == newName }) else { return }

        folders[index].name = newName

        if let words = wordStorage[oldName] {
            wordStorage[newName] = words.map {
                var updated = $0
                updated.folder = newName
                return updated
            }
            wordStorage.removeValue(forKey: oldName)
        }

        if var allWords = wordStorage["ALL"] {
            for i in allWords.indices {
                if allWords[i].folder == oldName {
                    allWords[i].folder = newName
                }
            }
            wordStorage["ALL"] = allWords
        }

        if currentFolder == oldName {
            currentFolder = newName
        }

        saveState()
    }

    func deleteFolder(id: UUID) {
        guard let folder = folders.first(where: { $0.id == id }) else { return }

        folders.removeAll { $0.id == id }
        wordStorage.removeValue(forKey: folder.name)

        if currentFolder == folder.name {
            currentFolder = "ALL"
        }

        if var allWords = wordStorage["ALL"] {
            allWords.removeAll { $0.folder == folder.name }
            wordStorage["ALL"] = allWords
        }

        saveState()
    }

    func selectFolder(_ folder: String) {
        currentFolder = folder
        saveState()
    }

    // MARK: - 단어 관련
    func addWord(_ word: Word) {
        wordStorage[word.folder, default: []].append(word)
        if !wordStorage["ALL", default: []].contains(where: { $0.id == word.id }) {
            wordStorage["ALL", default: []].append(word)
        }
        saveState()
    }

    func updateWord(_ updatedWord: Word) {
        if let index = wordStorage[updatedWord.folder]?.firstIndex(where: { $0.id == updatedWord.id }) {
            wordStorage[updatedWord.folder]?[index] = updatedWord
        }
        if let index = wordStorage["ALL"]?.firstIndex(where: { $0.id == updatedWord.id }) {
            wordStorage["ALL"]?[index] = updatedWord
        }
        saveState()
    }

    func deleteWord(_ word: Word) {
        wordStorage[word.folder]?.removeAll { $0.id == word.id }
        wordStorage["ALL"]?.removeAll { $0.id == word.id }
        saveState()
    }

    // MARK: - 정렬
    var displayedWords: [Word] {
        wordStorage[currentFolder] ?? []
    }

    // MARK: - 저장
    func saveState() {
        UserDefaults.standard.set(currentFolder, forKey: "lastFolder")
        do {
            let encodedFolders = try JSONEncoder().encode(folders)
            let encodedWords = try JSONEncoder().encode(wordStorage)
            UserDefaults.standard.set(encodedFolders, forKey: "folders")
            UserDefaults.standard.set(encodedWords, forKey: "wordStorage")
        } catch {
            print("저장 실패: \(error.localizedDescription)")
        }
    }

    // MARK: - 불러오기
    func loadState() {
        currentFolder = UserDefaults.standard.string(forKey: "lastFolder") ?? "ALL"

        if let folderData = UserDefaults.standard.data(forKey: "folders"),
           let decodedFolders = try? JSONDecoder().decode([FolderItem].self, from: folderData) {
            folders = decodedFolders
        }

        if let wordData = UserDefaults.standard.data(forKey: "wordStorage"),
           let decodedWords = try? JSONDecoder().decode([String: [Word]].self, from: wordData) {
            wordStorage = decodedWords
        }
    }
}
