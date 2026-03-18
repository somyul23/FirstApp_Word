import SwiftUI

struct MenuView: View {

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @ObservedObject var viewModel: AppStateViewModel

    // ✅ 기존 2개 제거 → 통합
    enum ActiveSheet: Identifiable {
        case test
        case search

        var id: Int { hashValue }
    }

    @State private var activeSheet: ActiveSheet?

    @State private var isEditing = false
    @State private var showDeleteConfirmation = false
    @State private var folderToDelete: FolderItem?
    @State private var showDuplicateAlert = false
    @State private var newFolderName: String = ""
    @State private var showAddFolderPopup = false

    var body: some View {

        NavigationView {

            HStack(spacing: 0) {

                // 좌측 메뉴
                VStack {

                    Spacer()

                    VStack(spacing: 30) {

                        SideMenuButton(label: "📝 테스트") {
                            activeSheet = .test
                        }

                        SideMenuButton(label: "🔍 검색") {
                            activeSheet = .search
                        }

                    }

                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width * 0.4)
                .background(colorScheme == .dark ? Color.purple.opacity(0.9) : Color.purple.opacity(0.4))


                // 우측 단어장 리스트
                VStack {

                    Spacer()

                    List {

                        // ALL 고정
                        if let allFolder = viewModel.folders.first(where: { $0.name == "ALL" }) {

                            FolderListItem(
                                folder: allFolder,
                                isSelected: viewModel.currentFolder == allFolder.name,
                                isEditing: false,
                                onSelect: {
                                    viewModel.selectFolder(allFolder.name)
                                    dismiss()
                                },
                                onDelete: {},
                                onRename: { _, _ in }
                            )
                        }

                        ForEach(viewModel.folders.filter { $0.name != "ALL" }) { folder in

                            FolderListItem(
                                folder: folder,
                                isSelected: viewModel.currentFolder == folder.name,
                                isEditing: isEditing,
                                onSelect: {
                                    viewModel.selectFolder(folder.name)
                                    dismiss()
                                },
                                onDelete: {
                                    folderToDelete = folder
                                    showDeleteConfirmation = true
                                },
                                onRename: { id, newName in
                                    viewModel.renameFolder(id: id, newName: newName)
                                }
                            )
                        }
                        .onMove(perform: moveFolder)

                    }
                    .environment(\.editMode, .constant(isEditing ? .active : .inactive))
                    .scrollContentBackground(.hidden)
                    .frame(height: CGFloat((viewModel.folders.count + 1) * 60))
                    .frame(maxHeight: .infinity, alignment: .center)

                    Spacer()

                }
                .frame(width: UIScreen.main.bounds.width * 0.6)
                .background(Color(.systemBackground))

            }
            .navigationBarTitle("메뉴", displayMode: .inline)

            .navigationBarItems(

                leading:
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    },

                trailing:
                    HStack {

                        if isEditing {
                            Button(action: {
                                newFolderName = ""
                                showAddFolderPopup = true
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                        }

                        Button(action: {
                            isEditing.toggle()
                        }) {
                            Text(isEditing ? "완료" : "편집")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
            )

            // ✅ 통합된 fullScreenCover
            .fullScreenCover(item: $activeSheet) { sheet in
                switch sheet {

                case .test:
                    TestSelectionView(viewModel: viewModel)

                case .search:
                    SearchView(
                        viewModel: viewModel,
                        currentFolder: viewModel.currentFolder
                    )
                }
            }

            .alert(isPresented: $showDeleteConfirmation) {

                Alert(
                    title: Text("삭제 확인"),
                    message: Text("'\(folderToDelete?.name ?? "")' 파일을 삭제하시겠습니까?"),
                    primaryButton: .destructive(Text("삭제")) {

                        if let folder = folderToDelete {
                            viewModel.deleteFolder(id: folder.id)
                        }

                    },
                    secondaryButton: .cancel()
                )
            }

        }
        .navigationViewStyle(StackNavigationViewStyle())

        .overlay(

            Group {

                if showAddFolderPopup {

                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture { showAddFolderPopup = false }

                    VStack(spacing: 20) {

                        Text("단어장의 이름을 입력해주세요")
                            .font(.headline)

                        TextField("단어장 이름", text: $newFolderName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)

                        HStack {

                            Button("취소") {
                                showAddFolderPopup = false
                            }

                            Spacer()

                            Button("추가") {

                                let success = viewModel.addFolder(name: newFolderName)

                                if !success {
                                    showDuplicateAlert = true
                                }

                                showAddFolderPopup = false
                            }

                        }
                        .padding(.horizontal)

                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                    )
                    .frame(maxWidth: 300)
                    .shadow(radius: 10)
                }

            }
        )

        .alert(isPresented: $showDuplicateAlert) {

            Alert(
                title: Text("중복된 이름"),
                message: Text("중복되는 이름의 단어장이 이미 존재합니다"),
                dismissButton: .default(Text("확인"))
            )
        }

        .edgesIgnoringSafeArea(.all)
    }


    private func moveFolder(from source: IndexSet, to destination: Int) {

        var editableFolders = viewModel.folders.filter { $0.name != "ALL" }

        editableFolders.move(fromOffsets: source, toOffset: destination)

        if let allFolder = viewModel.folders.first(where: { $0.name == "ALL" }) {
            viewModel.folders = [allFolder] + editableFolders
        } else {
            viewModel.folders = editableFolders
        }

        viewModel.saveState()
    }
}


// 좌측 메뉴 버튼
struct SideMenuButton: View {

    let label: String
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            Text(label)
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}
