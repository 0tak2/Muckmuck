//
//  MugTagListView.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import SwiftUI

struct MuckTagListView: View {
    @StateObject var viewModel = MuckTagViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 4) {
                    if let myMuckTag = viewModel.myMuckTag {
                        MuckTagView(tag: myMuckTag, isMyTag: true, viewModel: viewModel, hadReactionBefore: false)
                    }
                    
                    if !viewModel.muckTags.isEmpty || viewModel.myMuckTag != nil {
                        ForEach(viewModel.muckTags, id: \.self) { tag in
                            MuckTagView(tag: tag, isMyTag: false, viewModel: viewModel, hadReactionBefore: viewModel.myReactionExists(among: tag.reactions))
                        }
                    } else {
                        Spacer()
                        
                        Text("아직 만들어진 먹태그가 없습니다. \n추가 버튼을 눌러 생성해보세요.")
                    }
                }
                .padding(8)
            }
            .refreshable {
                viewModel.refresh()
            }
            .navigationTitle("먹먹")
            .toolbar {
                if viewModel.myMuckTag == nil {
                    Button {
                        viewModel.addButtonTapped()
                    } label: {
                        Text("추가")
                    }
                }
            }
            .sheet(isPresented: $viewModel.editingSheetShow) {
                MuckTagEditView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}

#Preview {
    MuckTagListView()
}
