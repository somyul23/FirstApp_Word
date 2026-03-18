import SwiftUI

struct EditableFolderRow: View {
    let folder: FolderItem
    let isEditing: Bool
    var onDeleteRequest: () -> Void
    var onRename: (String) -> Void

    @State private var isRenaming = false
    @State private var newName: String = ""

    var body: some View {
        HStack {
            Spacer()
            if isRenaming {
                TextField("이름 변경", text: $newName, onCommit: {
                    if !newName.isEmpty {
                        onRename(newName)
                    }
                    isRenaming = false
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: 200)
            } else {
                Text(folder.name)
                    .onTapGesture {
                        newName = folder.name
                        isRenaming = true
                    }
            }

            Spacer()

            Button(action: onDeleteRequest) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}
