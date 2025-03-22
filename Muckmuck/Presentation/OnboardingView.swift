//
//  OnboardingView.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import Foundation

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var userProfileModel: UserProfileModel
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Text("먹먹")
                .font(Fonts.big)
            
            Text("1. 밥, 술, 카페 - 원하는 종류의 먹태그를 간단하게 공유하세요")
            Text("2. 나의 먹태그에 반응한 사람과 모임을 만들고 네트워킹하세요")
            
            Spacer()
            
            Button {
                userProfileModel.onboardingComplete()
            } label: {
                Text("계속하기")
            }
            .buttonStyle(.bordered)
            
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(UserProfileModel())
}
