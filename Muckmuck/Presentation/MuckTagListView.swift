//
//  MugTagListView.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import SwiftUI

struct MuckTagListView: View {
    @State private var tags: [MuckTag] = MuckTag.dummyData
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(tags, id: \.self) { tag in
                        MuckTagView(tag: tag, isMyTag: tag.createdBy.nickname == "Bob")
                    }
                }
                .padding(8)
            }
            .navigationTitle("먹먹")
        }
    }
}

#Preview {
    MuckTagListView()
}
