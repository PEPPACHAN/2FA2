//
//  FaqView.swift
//  2FA_2
//
//  Created by PEPPA CHAN on 20.11.2025.
//


import SwiftUI

struct FaqView: View {
    @EnvironmentObject private var pageManager: PageManager
    private var faqData = FaqData()
    
    var body: some View {
        VStack {
            HStack {
                Text("FAQ")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .overlay(alignment: .leading) {
                        Button {
                            pageManager.page = .main
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(.accent)
                                .padding(.leading)
                        }
                    }
            }
            .padding(.bottom)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("🔐 What is an Authenticator App?")
                        .font(.system(size: 20, weight: .semibold))
                    Text(faqData.firstDescr)
                        .opacity(0.7)
                        .padding(.bottom, 24)
                    
                    Text("⚙️ How It Works")
                        .font(.system(size: 20, weight: .semibold))
                    
                    ForEach(0..<faqData.firstListTitle.count) { index in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(faqData.firstListTitle[index])
                                .fontWeight(.medium)
                            
                            Text(faqData.firstListDescr[index])
                                .opacity(0.7)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Text("🧱 Why It Matters")
                        .font(.system(size: 20, weight: .semibold))
                        .padding(.top, 24)
                    
                    ForEach(faqData.secondListDescr, id: \.self) { text in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(text)
                                .opacity(0.7)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Text("🌐 Enabling 2FA")
                        .font(.system(size: 20, weight: .semibold))
                        .padding(.top, 24)
                    
                    Text(faqData.endingDescr)
                        .opacity(0.7)
                    
                }
                .font(.system(size: 15))
                .foregroundStyle(.black)
                .padding(.horizontal)
            }
        }
        .background(Color.mainBG)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    FaqView()
}
