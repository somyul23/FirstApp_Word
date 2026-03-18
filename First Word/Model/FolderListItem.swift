import SwiftUI

struct FolderListItem: View {
    let folder: FolderItem
    let isSelected: Bool
    let isEditing: Bool
    var onSelect: () -> Void
    var onDelete: () -> Void
    var onRename: (_ id: UUID, _ newName: String) -> Void

    @State private var isRenaming = false
    @State private var newName: String = ""

    var body: some View {
        Group {
            if isEditing && folder.name != "ALL" {
                HStack {
                    Spacer()
                    if isRenaming {
                        TextField("이름 변경", text: $newName, onCommit: {
                            onRename(folder.id, newName)
                            isRenaming = false
                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 200)
                    } else {
                        Text(folder.name)
                            .font(.body)
                            .onTapGesture {
                                newName = folder.name
                                isRenaming = true
                            }
                    }
                    Spacer()

                    Button(action: onDelete) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                .padding(.vertical, 4)
            } else {
                HStack {
                    Spacer()
                    Text(folder.name)
                        .font(isSelected ? .system(size: 18, weight: .bold) : .system(size: 16))
                        .foregroundColor(.primary)
                        .onTapGesture {
                            onSelect()
                        }
                    Spacer()
                }
            }
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}
