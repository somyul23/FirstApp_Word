import SwiftUI

struct ObjectiveTestView: View {

    @ObservedObject var viewModel: AppStateViewModel

    var words: [Word]
    var questionType: String
    var answerType: String
    var totalCount: Int

    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var currentIndex = 0
    @State private var selectedAnswer: String? = nil
    @State private var correctCount = 0
    @State private var showResultView = false

    // ✅ 선택지 고정
    @State private var currentOptions: [Word] = []

    // ✅ 결과 저장
    @State private var resultItems: [TestResultItem] = []

    var currentWord: Word {
        words[currentIndex]
    }

    var allWords: [Word] {
        viewModel.wordStorage["ALL"] ?? []
    }

    var body: some View {

        VStack(spacing: 20) {

            // 상단바
            HStack {

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }

                Spacer()

                Text("\(currentIndex + 1) / \(totalCount)")
                    .font(.headline)

                Spacer()

                Spacer().frame(width: 24)
            }
            .padding()

            // 문제
            Text(getQuestion(from: currentWord))
                .font(.largeTitle)
                .padding()

            // 선택지
            VStack(spacing: 15) {

                ForEach(currentOptions, id: \.id) { option in

                    Button {

                        if selectedAnswer == nil {

                            let answer = getAnswer(from: option)
                            let correct = getAnswer(from: currentWord)

                            selectedAnswer = answer

                            let isCorrect = answer == correct

                            if isCorrect {
                                correctCount += 1
                            }

                            // ✅ 결과 저장 (word 포함!!)
                            let result = TestResultItem(
                                word: currentWord,
                                question: getQuestion(from: currentWord),
                                correctAnswer: correct,
                                userAnswer: answer,
                                isCorrect: isCorrect
                            )

                            resultItems.append(result)
                        }

                    } label: {

                        Text(getAnswer(from: option))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(buttonColor(for: option))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal)

            Spacer()

            // 다음 버튼
            if selectedAnswer != nil {

                Button {

                    nextQuestion()

                } label: {

                    Text(currentIndex == totalCount - 1 ? "결과 보기" : "다음")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }

        // ✅ 첫 진입 시 옵션 생성
        .onAppear {
            currentOptions = generateOptions(correct: currentWord)
        }

        // ✅ 결과 화면 이동
        .fullScreenCover(isPresented: $showResultView) {
            TestResultView(
                resultItems: resultItems,
                viewModel: viewModel,
                onClose: {
                    showResultView = false   // 👉 ResultView만 닫기
                    dismiss()                // 👉 그 다음 ObjectiveTestView 닫기
                }
            )
        }
    }

    // MARK: - 선택지 생성
    func generateOptions(correct: Word) -> [Word] {

        let wrongs = allWords
            .filter { $0.id != correct.id }
            .shuffled()
            .prefix(3)

        var result = [correct] + wrongs
        result.shuffle()

        return result
    }

    // MARK: - 문제 표시
    func getQuestion(from word: Word) -> String {

        switch questionType {
        case "뜻":
            return word.meaning

        case "발음":
            return word.pronunciation ?? ""

        default:
            return word.text
        }
    }

    // MARK: - 정답 표시
    func getAnswer(from word: Word) -> String {

        switch answerType {
        case "뜻":
            return word.meaning

        case "발음":
            return word.pronunciation ?? ""

        default:
            return word.text
        }
    }

    // MARK: - 버튼 색상
    func buttonColor(for option: Word) -> Color {

        guard let selected = selectedAnswer else {
            return Color.gray
        }

        let correctAnswer = getAnswer(from: currentWord)
        let optionText = getAnswer(from: option)

        if optionText == correctAnswer {
            return Color.green
        }

        if optionText == selected {
            return Color.red
        }

        return Color.gray
    }

    // MARK: - 다음 문제
    func nextQuestion() {

        if currentIndex < totalCount - 1 {

            currentIndex += 1
            selectedAnswer = nil

            // ✅ 다음 문제에서만 옵션 새로 생성
            currentOptions = generateOptions(correct: words[currentIndex])

        } else {

            showResultView = true
        }
    }
}
