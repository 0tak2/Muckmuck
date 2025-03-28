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
    private let hadReactionBefore: Bool // 내가 이전에 좋아요 눌렀던 태그인지
    
    @ObservedObject private var viewModel: MuckTagViewModel
    
    init(tag: MuckTag, isMyTag: Bool = false, viewModel: MuckTagViewModel, hadReactionBefore: Bool) {
        self.tag = tag
        self.isMyTag = isMyTag
        self.viewModel = viewModel
        self.hadReactionBefore = hadReactionBefore
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
                            guard !isMyTag else { return }
                            viewModel.reactButtonTapped(muckTagId: tag.id)
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
    MuckTagView(tag: .dummyData.first!, viewModel: MuckTagViewModel(), hadReactionBefore: false)
}

fileprivate extension User {
    static let dummyUserBob: User = .init(
        id: "52a64585-445f-4fae-87fe-4d6e58524e91",
        nickname: "Bob",
        contactInfo: "팀즈로 연락주세요"
    )
    
    static let dummyUserJoid: User = .init(
        id: "3589003f-497a-40b9-86dc-19556c7ac3b1",
        nickname: "Joid",
        contactInfo: "팀즈로 연락주세요"
    )
    
    static let dummyUserLuke: User = .init(
        id: "34e074cf-6a09-42c4-b581-9ab2dec3c162",
        nickname: "Luke",
        contactInfo: "팀즈로 연락주세요"
    )
}

fileprivate extension MuckTag {
    static let dummyData: [MuckTag] = [
        .init(
            id: UUID(),
            region: .hyoja,
            createdBy: User.dummyUserBob,
            createdAt: Date(),
            availableUntil: Date(),
            type: .bob,
            reactions: [
                .init(id: UUID(), createdBy: User.dummyUserJoid, createdAt: Date()),
                .init(id: UUID(), createdBy: User.dummyUserLuke, createdAt: Date())
            ]
        ),
        .init(
            id: UUID(),
            region: .daeii,
            createdBy: User.dummyUserJoid,
            createdAt: Date(),
            availableUntil: Date(),
            type: .drink,
            reactions: [
                .init(id: UUID(), createdBy: User.dummyUserBob, createdAt: Date())
            ]
        ),
        .init(
            id: UUID(),
            region: .ugang,
            createdBy: User.dummyUserLuke,
            createdAt: Date(),
            availableUntil: Date(),
            type: .cafe,
            reactions: [
                .init(id: UUID(), createdBy: User.dummyUserJoid, createdAt: Date()),
                .init(id: UUID(), createdBy: User.dummyUserBob, createdAt: Date())
            ]
        )
    ]
}
