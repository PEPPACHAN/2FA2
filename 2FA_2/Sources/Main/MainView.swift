//
//  MainView.swift
//  2FA_2
//
//  Created by PEPPA CHAN on 20.11.2025.
//


import SwiftUI

struct MainView: View {
    @StateObject private var vm: MainVM = MainVM()
    
    var body: some View {
        VStack {
            
            vm.tabs.view
            
            HStack {
                ForEach(MainPages.allCases, id: \.self) { tab in
                    VStack(spacing: 5.15) {
                        tab.image
                            .font(.system(size: 22, weight: .medium))
                        tab.title
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(tab == vm.tabs ? .accent: .black.opacity(0.3))
                    .onTapGesture {
                        vm.tabs = tab
                    }
                    
                    if MainPages.allCases.first == tab {
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 34)
            .frame(height: 90)
            .background(Color.white)
            .overlay(alignment: .top) {
                Image(.plus)
                    .offset(y: -10)
                    .onTapGesture {
                        vm.plusTapped.toggle()
                    }
                
            }
            
        }
        .sheet(isPresented: $vm.plusTapped, content: {
            AddAccountSheetView(showError: $vm.showError)
                .presentationDetents([.height(207)])
                .presentationDragIndicator(.visible)
        })
        .animation(.linear(duration: 0.1), value: vm.tabs)
        .animation(.linear(duration: 0.1), value: vm.plusTapped)
        .background(Color.mainBG)
        .onChange(of: vm.showError, perform: { _ in
            if vm.showError != "" {
                vm.plusTapped = false
                
                Task {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    vm.showError = ""
                }
            }
        })
        .overlay {
            if vm.showError != "" {
                Color.black.opacity(0.3).ignoresSafeArea()
            }
        }
        .overlay(alignment: .top) {
            if vm.showError != "" {
                Text(vm.showError)
                    .font(.system(size: 17, weight: .semibold))
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

#Preview {
    MainView()
}
