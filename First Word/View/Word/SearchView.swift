import SwiftUI

struct SearchView: View {

    @ObservedObject var viewModel: AppStateViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var searchType = "단어"
    let searchOptions = ["단어", "뜻", "발음"]
    let currentFolder: String

    @State private var searchText = ""
    @State private var results: [Word] = []

    var body: some View {

        VStack(spacing: 16) {

            // 상단바
            HStack {

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }

                Spacer()

                Text("검색")
                    .font(.headline)

                Spacer()

                Spacer().frame(width: 24)
            }
            .padding(.horizontal)

            // 🔍 검색 바
            HStack(spacing: 10) {

                Menu {
                    ForEach(searchOptions, id: \.self) { option in
                        Button(option) {
                            searchType = option
                            performSearch()
                        }
                    }
                } label: {
                    Text(searchType)
                        .foregroundColor(.black)
                        .padding(8)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }

                TextField("검색어 입력", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: searchText) { _ in
                        performSearch()
                    }
            }
            .padding(.horizontal)

            // 결과
            if results.isEmpty {

                Spacer()

                Text(searchText.isEmpty ? "검색어를 입력해주세요" : "검색 결과가 없습니다")
                    .foregroundColor(.gray)

                Spacer()

            } else {

                List(results) { word in

                    VStack(alignment: .leading, spacing: 4) {

                        Text(word.text)
                            .font(.headline)

                        Text(word.meaning)
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        if let pronunciation = word.pronunciation {
                            Text(pronunciation)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(PlainListStyle())
            }
        }
    }

    func performSearch() {

        let words = viewModel.wordStorage[currentFolder] ?? []
        let keyword = searchText.lowercased()

        if keyword.isEmpty {
            results = []
            return
        }

        results = words.filter { word in

            switch searchType {

            case "뜻":
                return word.meaning.lowercased().contains(keyword)

            case "발음":
                return (word.pronunciation ?? "").lowercased().contains(keyword)

            default:
                return word.text.lowercased().contains(keyword)
            }
        }
    }
}
