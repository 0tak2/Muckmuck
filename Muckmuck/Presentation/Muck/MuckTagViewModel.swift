//
//  MuckTagListViewModel.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import Foundation
import os.log

final class MuckTagViewModel: ObservableObject {
    private let muckService: MuckService
    private let userService: UserService
    private let log = Logger.of("MuckTagViewModel")
    
    @Published var muckTags: [MuckTag] = []
    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var errorMessage: String = "오류가 발생했습니다."
    @Published var currentUser: User?
    @Published var myMuckTag: MuckTag?
    
    @Published var editingSheetShow: Bool = false
    @Published var editingRegion: MuckRegion = .hoyja
    @Published var editingTagType: MuckType = .bob
    @Published var editingTagMeetAt = Date()
    @Published var otherRegionFieldShow = false
    
    init(
        muckService: MuckService = MuckService.shared,
        userService: UserService = UserService.shared
    ) {
        self.muckService = muckService
        self.userService = userService
    }
    
    func onAppear() {
        isLoading = true
        isError = false
        
        Task {
            await loadCurrentUser()
            await loadMuckTags()
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    func loadMuckTags() async {
        guard let currentUser = currentUser else {
            log.warning("currentUser must not be nil")
            return
        }
        
        do {
            let myTag = try await muckService.getMuckTag(of: currentUser.id).first
            let tags = try await muckService.getValidMuckTags()
                .filter { $0 != myTag }
            
            print(myTag)
            print(tags)
            
            await MainActor.run {
                myMuckTag = myTag
                muckTags = tags
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isError = true
                
                if let error = error as? MuckService.MuckServiceError {
                    errorMessage = error.getUserMessage()
                }
            }
        }
    }
    
    func loadCurrentUser() async {
        let currentUser = try? await userService.getCurrentUser()
        await MainActor.run {
            self.currentUser = currentUser
        }
    }
    
    func isMyMuckTag(_ muckTag: MuckTag) -> Bool {
        guard let currentUser = currentUser else { return false }
        return muckTag.createdBy == currentUser
    }
    
    func saveMuckTag() async {
        guard let currentUser = currentUser else { return }
        
        do {
            try await muckService.addNewMuckTag(MuckTag(id: UUID(), region: editingRegion, createdBy: currentUser, createdAt: Date(), availableUntil: editingTagMeetAt, type: editingTagType, reactions: []))
        } catch {
            await MainActor.run {
                isError = true
                if let error = error as? MuckService.MuckServiceError {
                    errorMessage = error.getUserMessage()
                }
            }
        }
    }
    
    func addButtonTapped() {
        editingSheetShow = true
    }
    
    func saveButtonTapped() {
        isError = false
        
        Task {
            await saveMuckTag()
            await loadMuckTags()
            
            if !isError {
                await MainActor.run {
                    editingRegion = .hoyja
                    editingTagType = .bob
                    editingTagMeetAt = Date()
                    editingSheetShow = false
                }
            }
        }
    }
}
