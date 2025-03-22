//
//  MuckTagEditView.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import SwiftUI

struct MuckTagEditView: View {
    @ObservedObject var viewModel: MuckTagViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Picker(selection: $viewModel.editingRegion, label: Text("동네")) {
                    ForEach(MuckRegion.allCases, id: \.self) { region in
                        Text(region.getLocalizedString()).tag(region)
                    }
                }
                Picker(selection: $viewModel.editingTagType, label: Text("먹종류")) {
                    Text(MuckType.bob.getEmoji()).tag(MuckType.bob)
                    Text(MuckType.cafe.getEmoji()).tag(MuckType.cafe)
                    Text(MuckType.drink.getEmoji()).tag(MuckType.drink)
                }
                DatePicker("만날 시간", selection: $viewModel.editingTagMeetAt)
            }
            .toolbar {
                Button {
                    viewModel.saveButtonTapped()
                } label: {
                    Text("저장")
                }
            }
            .alert(viewModel.errorMessage, isPresented: $viewModel.isError) {
                Button("확인", role: .cancel) { }
            }
        }
    }
}

#Preview {
    MuckTagEditView(viewModel: MuckTagViewModel())
}
