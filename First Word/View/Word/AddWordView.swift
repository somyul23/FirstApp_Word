import SwiftUI

struct AddWordView: View {
    var currentFolder: String
    var editingWord: Word? = nil
    var onAdd: ((Word) -> Void)? = nil
    var onClose: (() -> Void)? = nil

    @State private var text: String = ""
    @State private var meaning: String = ""
    @State private var pronunciation: String = ""
    @State private var exampleSentence: String = ""
    @State private var showToast = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("단어")) {
                    TextField("단어", text: $text)
                }

                Section(header: Text("뜻")) {
                    TextField("뜻", text: $meaning)
                }

                Section(header: Text("발음")) {
                    TextField("발음", text: $pronunciation)
                }

                Section(header: Text("예문")) {
                    TextField("예문", text: $exampleSentence)
                }
            }
            .navigationBarTitle(editingWord == nil ? "단어 추가" : "단어 편집", displayMode: .inline)
            .navigationBarItems(
                leading: Button("닫기") {
                    onClose?()
                },
                trailing: Button(editingWord == nil ? "추가" : "저장") {
                    let folder = editingWord?.folder ?? currentFolder
                    let word = Word(
                        id: editingWord?.id ?? UUID(),
                        text: text,
                        meaning: meaning,
                        folder: folder,
                        pronunciation: pronunciation.isEmpty ? nil : pronunciation,
                        exampleSentence: exampleSentence.isEmpty ? nil : exampleSentence
                    )
                    
                    
                    onAdd?(word)
                    
                    if editingWord == nil {
                        // 추가일 때는 입력 초기화하고 계속 남아 있음
                        text = ""
                        meaning = ""
                        pronunciation = ""
                        exampleSentence = ""
                        showToast = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showToast = false
                            }
                        }
                    } else {
                        // 편집일 때는 닫기
                        onClose?()
                    }
                }
                .disabled(text.isEmpty || meaning.isEmpty)
            )
        }
        .overlay(
            Group {
                if showToast {
                    Text("단어가 추가되었습니다")
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .transition(.opacity)
                        .padding(.bottom, 50)
                }
            },
            alignment: .bottom
        )
        .onAppear {
            if let word = editingWord {
                text = word.text
                meaning = word.meaning
                pronunciation = word.pronunciation ?? ""
                exampleSentence = word.exampleSentence ?? ""
            }
        }
    }
}
