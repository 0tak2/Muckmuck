//
//  MuckTagView.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import SwiftUI

struct MuckTagView: View {
    private let tag: MuckTag
    private let isMyTag: Bool
    @State private var hadReactionBefore: Bool = false
    
    @ObservedObject private var viewModel: MuckTagViewModel
    
    init(tag: MuckTag, isMyTag: Bool = false, viewModel: MuckTagViewModel) {
        self.tag = tag
        self.isMyTag = isMyTag
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            divider(opacity: 0.8)
            
            HStack(alignment: .top, spacing: 16) {
                Text(tag.type.getEmoji())
                    .font(Fonts.big)
                
                VStack(alignment: .leading) {
                    HStack {
                        if isMyTag {
                            Image(systemName: "pin.fill")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(Colors.secondary)
                                .frame(height: 16)
                        }
                        
                        let displayNickName = isMyTag
                        ? "\(tag.createdBy.nickname) (나)"
                        : tag.createdBy.nickname
                        
                        Text(displayNickName)
                            .font(Fonts.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if isMyTag {
                            Spacer()
                            
                            Menu {
                                Button {
                                    viewModel.editButtonTapped(muckTagId: tag.id)
                                } label: {
                                    Text("수정")
                                }

                                Button {
                                    viewModel.removeButtonTapped(muckTagId: tag.id)
                                } label: {
                                    Text("삭제")
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .foregroundStyle(Colors.black)
                                    .frame(width: 32, height: 32)
                            }
                            .padding(.trailing, 8)
                        }
                    }
                    .padding(.bottom, 4)
                    
                    muckTagContent
                        .padding(.bottom, 16)
                    
                    HStack(alignment: .lastTextBaseline) {
                        Button {
                            hadReactionBefore.toggle()
                        } label: {
                            !hadReactionBefore
                            ? Image(systemName: "heart")
                                .renderingMode(.template)
                                .foregroundStyle(.red)
                            : Image(systemName: "heart.fill")
                                .renderingMode(.template)
                                .foregroundStyle(.red)
                        }
                        
                        Text(String(tag.reactions.count))
                            .font(Fonts.small)
                    }
                    
                    if isMyTag {
                        VStack(alignment: .leading) {
                            divider(opacity: 0.3)
                            
                            Text("리액션한 러너들")
                                .font(Fonts.smallBold)
                            
                            ForEach(tag.reactions, id: \.self) { reaction in
                                Text("- \(reaction.createdBy.nickname) (\(reaction.createdBy.contactInfo))")
                            }
                            .font(Fonts.small)
                            
                            if tag.reactions.isEmpty {
                                Text("- 아직 리액션을 남긴 러너들이 없습니다.")
                                    .font(Fonts.small)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Colors.white)
    }
    
    var muckTagContent: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(tag.region.getLocalizedString())
                Text(tag.type.getLocalizedString())
                Text(tag.availableUntil.localizedString)
            }
            .font(Fonts.medium)
        }
    }
    
    func divider(opacity: CGFloat) -> some View {
        VStack(alignment: .leading) {
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.gray.opacity(opacity))
                .padding(.vertical, 8)
        }
    }
}

#Preview {
    MuckTagView(tag: .dummyData.first!, viewModel: MuckTagViewModel())
}
