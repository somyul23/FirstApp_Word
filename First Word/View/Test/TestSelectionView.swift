import SwiftUI

struct TestSelectionView: View {

    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @ObservedObject var viewModel: AppStateViewModel

    // 테스트 타입 선택 UI용 (0: 주관식, 1: 객관식)
    @State private var selectedTestType = 0

    // ✅ 실제 실행용 상태 (핵심)
    @State private var activeTest: TestType? = nil

    // 옵션
    @State private var questionType = "단어"
    @State private var answerType = "뜻"
    @State private var selectedFolder = "ALL"
    @State private var wordFilter = "all"
    @State private var testCount = 10

    let testTypes = ["주관식 테스트", "객관식 테스트"]
    let typeOptions = ["단어","뜻","발음"]
    let countOptions = [10,30,50,100]

    // 폴더 단어
    var folderWords: [Word] {

        if selectedFolder == "ALL" {
            return viewModel.wordStorage["ALL"] ?? []
        }

        return viewModel.wordStorage[selectedFolder] ?? []
    }

    // 필터 적용
    var filteredWords: [Word] {

        switch wordFilter {

        case "bookmark":
            return folderWords.filter { $0.isBookmarked }

        case "yellow":
            return folderWords.filter { $0.isYellow }

        case "red":
            return folderWords.filter { $0.isRed }

        case "default":
            return folderWords.filter {
                !$0.isBookmarked &&
                !$0.isYellow &&
                !$0.isRed &&
                !$0.isStrikethrough
            }

        default:
            return folderWords
        }
    }

    // 테스트 단어
    var testWords: [Word] {
        let shuffled = filteredWords.shuffled()
        return Array(shuffled.prefix(min(testCount, shuffled.count)))
    }

    var body: some View {

        VStack(spacing: 20) {

            // 상단바
            HStack {

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }

                Spacer()

                Text("테스트 설정")
                    .font(.headline)

                Spacer()

                Spacer().frame(width: 24)
            }
            .padding(.horizontal)

            // 테스트 타입 선택 (스와이프)
            TabView(selection: $selectedTestType) {

                ForEach(0..<testTypes.count, id: \.self) { i in

                    VStack(spacing: 12) {

                        Text(i == 0 ? "✏️" : "🧠")
                            .font(.largeTitle)

                        Text(testTypes[i])
                            .font(.headline)
                    }
                    .frame(width: 250, height: 150)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6))
                    )
                    .tag(i)
                }
            }
            .frame(height: 170)
            .tabViewStyle(.page)

            // 문제 타입
            VStack(alignment: .leading, spacing: 6) {

                Text("문제")

                Picker("", selection: $questionType) {
                    ForEach(typeOptions, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)

            }
            .padding(.horizontal)

            // 정답 타입
            VStack(alignment: .leading, spacing: 6) {

                Text("정답")

                Picker("", selection: $answerType) {
                    ForEach(typeOptions, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)

            }
            .padding(.horizontal)

            // 단어장 선택
            VStack(alignment: .leading, spacing: 6) {

                Text("단어장")

                Picker("", selection: $selectedFolder) {
                    ForEach(viewModel.folders, id: \.name) { folder in
                        Text(folder.name).tag(folder.name)
                    }
                }
                .pickerStyle(.menu)

            }
            .padding(.horizontal)

            // 단어 필터
            VStack(spacing: 8) {

                Text("단어 필터")
                    .frame(maxWidth: .infinity)

                Picker("", selection: $wordFilter) {
                    Text("전체").tag("all")
                    Text("기본").tag("default")
                    Text("북마크").tag("bookmark")
                    Text("노란색").tag("yellow")
                    Text("빨간색").tag("red")
                }
                .pickerStyle(.segmented)

                Text("사용 가능한 단어 \(filteredWords.count)개")
                    .font(.caption)
                    .foregroundColor(.gray)

            }
            .padding(.horizontal)

            // 테스트 개수
            VStack(alignment: .leading, spacing: 6) {

                Text("테스트 개수")

                Picker("", selection: $testCount) {
                    ForEach(countOptions, id: \.self) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(.segmented)

            }
            .padding(.horizontal)

            Spacer()

            // 테스트 시작 버튼
            Button {

                // ✅ enum으로 정확하게 분기
                if selectedTestType == 0 {
                    activeTest = .subjective
                } else {
                    activeTest = .objective
                }

            } label: {

                Text("테스트 시작")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        Capsule()
                            .fill(filteredWords.isEmpty ? Color.gray : Color.blue)
                    )
            }
            .disabled(filteredWords.isEmpty)
            .padding(.horizontal)
        }

        // ✅ 핵심: item 기반 fullScreenCover
        .fullScreenCover(item: $activeTest) { testType in

            switch testType {

            case .subjective:
                SubjectiveTestView(
                    viewModel: viewModel,
                    words: testWords,
                    questionType: questionType,
                    answerType: answerType,
                    totalCount: testWords.count
                )

            case .objective:
                ObjectiveTestView(
                    viewModel: viewModel,
                    words: testWords,
                    questionType: questionType,
                    answerType: answerType,
                    totalCount: testWords.count
                )
            }
        }
    }
}

// ✅ enum 정의 (핵심)
enum TestType: Identifiable {
    case subjective
    case objective

    var id: Int {
        switch self {
        case .subjective: return 0
        case .objective: return 1
        }
    }
}
