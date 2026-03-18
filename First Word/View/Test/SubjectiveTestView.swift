import SwiftUI

struct SubjectiveTestView: View {
    @ObservedObject var viewModel: AppStateViewModel

    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme   // ✅ 추가

    let words: [Word]
    let questionType: String
    let answerType: String
    let totalCount: Int

    @State private var resultItems: [TestResultItem] = []
    @State private var showResultView = false
    @State private var currentIndex = 0
    @State private var userInput: String = ""
    @State private var score: Int = 0
    @State private var isCorrect: Bool? = nil

    var currentWord: Word {
        words[currentIndex]
    }

    var correctAnswer: String {
        switch answerType {
        case "뜻": return currentWord.meaning
        case "발음": return currentWord.pronunciation ?? ""
        default: return currentWord.text
        }
    }

    var displayedQuestion: String {
        switch questionType {
        case "뜻": return currentWord.meaning
        case "발음": return currentWord.pronunciation ?? ""
        default: return currentWord.text
        }
    }

    var body: some View {

        if words.isEmpty {

            VStack(spacing: 20) {

                Text("테스트할 단어가 없습니다")
                    .font(.title2)

                Button("테스트 선택 화면으로 돌아가기") {
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 14)
                .background(Capsule().fill(Color.blue))
            }

        } else {

            VStack(spacing: 24) {

                // ✅ 커스텀 상단바 (핵심)
                HStack {

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }

                    Spacer()

                    Text("주관식 테스트")
                        .font(.headline)

                    Spacer()

                    Spacer().frame(width: 24)
                }
                .padding(.horizontal)

                Text("문제 \(currentIndex + 1) / \(words.count)")
                    .font(.headline)

                Text(displayedQuestion)
                    .font(.title)
                    .padding()

                TextField("정답 입력", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                if let result = isCorrect {
                    Text(result ? "정답입니다! 🎉" : "오답입니다 😢")
                        .foregroundColor(result ? .green : .red)
                        .font(.subheadline)
                }

                Button("제출") {
                    checkAnswer()
                }
                .disabled(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer()
            }
            .padding()
            .fullScreenCover(isPresented: $showResultView) {
                TestResultView(
                    resultItems: resultItems,
                    viewModel: viewModel,
                    onClose: {
                        showResultView = false
                        dismiss()
                    }
                )
            }
        }
    }

    func checkAnswer() {
        let trimmed = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let correct = (trimmed == correctAnswer)

        isCorrect = correct

        let item = TestResultItem(
            word: currentWord,
            question: displayedQuestion,
            correctAnswer: correctAnswer,
            userAnswer: trimmed,
            isCorrect: correct
        )

        resultItems.append(item)

        if correct { score += 1 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {

            userInput = ""
            isCorrect = nil

            if currentIndex + 1 < words.count {
                currentIndex += 1
            } else {
                showResultView = true
            }
        }
    }
}
