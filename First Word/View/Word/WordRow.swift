import SwiftUI

struct WordRow: View {
    @Binding var word: Word
    var onEdit: () -> Void
    var onDelete: () -> Void
    let colorScheme: ColorScheme
    var isDetailed: Bool
    var onToggleDetail: () -> Void


    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            HStack {
                Text(word.text)
                    .font(.headline)
                    .foregroundColor(colorForState())
                    .strikethrough(word.isStrikethrough, color: .gray)
                Spacer()
            }

            if isDetailed {
                if let pronunciation = word.pronunciation, !pronunciation.isEmpty {
                    HStack {
                        Text("[\(pronunciation)]")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }

                HStack {
                    Text(word.meaning)
                        .font(.subheadline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Spacer()
                }

                if let example = word.exampleSentence, !example.isEmpty {
                    HStack {
                        Text("예문: \(example)")
                            .font(.subheadline)
                            .foregroundColor(Color(red: 0.7, green: 0.85, blue: 1.0)) // 더 연한 하늘색
                        Spacer()
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .center)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                onToggleDetail()
            }
        }

        // ✅ 꾹 눌렀을 때 편집 실행
        .onLongPressGesture {
            onEdit()
        }
        // ✅ 우측 스와이프: 북마크, 외움, 애매, 못외움
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                word.isBookmarked.toggle()
            } label: {
                Label("북마크", systemImage: word.isBookmarked ? "bookmark.fill" : "bookmark")
            }
            .tint(.blue)

            Button {
                word.isStrikethrough.toggle()
                word.isRed = false
                word.isYellow = false
            } label: {
                Label("외움", systemImage: "checkmark")
            }
            .tint(.gray)

            Button {
                word.isYellow.toggle()
                word.isStrikethrough = false
                word.isRed = false
            } label: {
                Label("애매", systemImage: "questionmark")
            }
            .tint(.yellow)

            Button {
                word.isRed.toggle()
                word.isYellow = false
                word.isStrikethrough = false
            } label: {
                Label("못외움", systemImage: "xmark")
            }
            .tint(.red)
        }
        // ✅ 좌측 스와이프: 삭제
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("삭제", systemImage: "trash")
            }
        }
    }

    private func colorForState() -> Color {
        if word.isRed { return .red }
        if word.isYellow { return .yellow }
        if word.isStrikethrough { return .gray }
        return colorScheme == .dark ? .white : .black
    }
}
