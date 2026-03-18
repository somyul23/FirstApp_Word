import SwiftUI

// 확장: 모든 String을 Identifiable로 취급 (alert(item:) 에러 해결)
extension String: Identifiable {
    public var id: String { self }
}

// 결과 데이터 모델
struct TestResultItem {
    let word: Word
    let question: String
    let correctAnswer: String
    let userAnswer: String
    let isCorrect: Bool
}

struct TestResultView: View {
    let resultItems: [TestResultItem]
    @ObservedObject var viewModel: AppStateViewModel
    var onClose: () -> Void

    @Environment(\.colorScheme) var colorScheme

    // 한 번만 실행되도록 상태값
    @State private var didCheckCorrect = false
    @State private var didMarkWrong = false
    
    // 확인 알림에 사용할 문자열 ("정답" 또는 "오답") – 이제 String이 Identifiable로 확장되어 있음
    @State private var showConfirmationAlert: String? = nil
    
    // 변경 완료 토스트 팝업 표시 여부
    @State private var showDonePopup = false

    var correctCount: Int {
        resultItems.filter { $0.isCorrect }.count
    }

    var accuracy: Int {
        guard !resultItems.isEmpty else { return 0 }
        return Int(Double(correctCount) / Double(resultItems.count) * 100)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // 상단: 점수 및 정답률 표시
                Text("맞힌 개수: \(correctCount) / \(resultItems.count)")
                    .font(.title2)
                Text("정답률: \(accuracy)%")
                    .font(.headline)
                    .foregroundColor(.gray)
                Divider().padding(.vertical, 10)
                
                // 중단: 각 문제의 결과 리스트
                ScrollView {
                    ForEach(resultItems.indices, id: \.self) { i in
                        let item = resultItems[i]
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: item.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(item.isCorrect ? .blue : .red)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("문제: \(item.question)")
                                Text("정답: \(item.correctAnswer)")
                                Text("입력: \(item.userAnswer)")
                            }
                            .font(.subheadline)
                        }
                        .padding(.bottom, 8)
                    }
                }
                Spacer()
                
                // 하단: 변경 버튼들
                HStack(spacing: 16) {
                    Button("정답 체크로 변경") {
                        showConfirmationAlert = "정답"
                    }
                    .disabled(didCheckCorrect)
                    .opacity(didCheckCorrect ? 0.5 : 1)
                    
                    Button("오답 빨간색으로 변경") {
                        showConfirmationAlert = "오답"
                    }
                    .disabled(didMarkWrong)
                    .opacity(didMarkWrong ? 0.5 : 1)
                }
                
                // 하단: 테스트 선택 화면으로 돌아가기 버튼
                Button("테스트 선택 화면으로 돌아가기") {
                    onClose()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 14)
                .background(Capsule().fill(Color.blue))
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
        // 확인 알림: 버튼 클릭 시 나타남
        .alert(item: $showConfirmationAlert) { type in
            Alert(
                title: Text("변경 확인"),
                message: Text("정말로 \(type) 단어 상태를 변경하시겠습니까?"),
                primaryButton: .default(Text("변경"), action: {
                    if type == "정답" {
                        didCheckCorrect = true
                        updateCorrectWords()
                    } else {
                        didMarkWrong = true
                        updateWrongWords()
                    }
                    showDonePopup = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showDonePopup = false
                    }
                }),
                secondaryButton: .cancel()
            )
        }
        // 변경 완료 토스트 팝업
        .overlay(
            Group {
                if showDonePopup {
                    Text("변경 완료되었습니다.")
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.bottom, 50)
                        .transition(.opacity)
                }
            },
            alignment: .bottom
        )
    }

    // 맞은 단어를 체크 상태로 변경하는 함수
    func updateCorrectWords() {
        for item in resultItems where item.isCorrect {
            var updated = item.word
            updated.isStrikethrough = true
            updated.isRed = false
            updated.isYellow = false
            viewModel.updateWord(updated)
        }
    }

    // 틀린 단어를 빨간색으로 변경하는 함수
    func updateWrongWords() {
        for item in resultItems where !item.isCorrect {
            var updated = item.word
            updated.isRed = true
            updated.isStrikethrough = false
            updated.isYellow = false
            viewModel.updateWord(updated)
        }
    }
}
