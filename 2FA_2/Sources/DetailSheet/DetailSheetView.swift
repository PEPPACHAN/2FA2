//
//  DetailSheetView.swift
//  2FA_2
//
//  Created by PEPPA CHAN on 20.11.2025.
//


import SwiftUI
import CoreData

struct DetailSheetView: View {
    
    @EnvironmentObject private var page: PageManager
    var vc: NSManagedObjectContext
    @Binding var account: Accounts?
    @State private var isFavorite: Bool = false
    @State private var isEdit = false
    
    var body: some View {
        VStack(spacing: 18) {
            Text("File Options")
                .font(.system(size: 17, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .center)
            
            VStack(spacing: 12) {
                
                Button {
                    isEdit = true
                } label: {
                    HStack(spacing: 8) {
                        Image(.pen)
                        
                        Text("Edit")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.black)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.black.opacity(0.5))
                    }
                    .padding(12)
                    .background(Color.mainBG)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                }
                
                Button {
                    isFavorite.toggle()
                } label: {
                    HStack(spacing: 8) {
                        Image(!isFavorite ? .addFavorite: .removeFavorite)
                        
                        Text("\(!isFavorite ? "Add to": "Remove from") Favorites")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.black)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.black.opacity(0.5))
                    }
                    .padding(12)
                    .background(Color.mainBG)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                }
                
                Button {
                    if let account {
                        CoreDataManager(vc: vc).deleteAccount(account: account)
                        self.account = nil
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(.trash)
                        
                        Text("Delete")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.black)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.black.opacity(0.5))
                    }
                    .padding(12)
                    .background(Color.mainBG)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .fullScreenCover(isPresented: $isEdit, content: {
            AddMannuallyView(account: account, isEdit: $isEdit)
        })
        .onAppear {
            isFavorite = account?.isFavorite ?? false
        }
        .onChange(of: isFavorite) { _ in
            account?.isFavorite = isFavorite
            
            do {
                try vc.save()
            } catch {
                print("[DetailSheetView] Cant save context")
            }
            
        }
    }
}

//#Preview {
//    DetailSheetView()
//}
