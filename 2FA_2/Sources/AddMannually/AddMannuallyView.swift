//
//  AddMannuallyView.swift
//  2FA_2
//
//  Created by PEPPA CHAN on 20.11.2025.
//


import SwiftUI
import SwiftOTP
import CoreData
import Foundation

struct AddMannuallyView: View {
    @EnvironmentObject private var page: PageManager
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var pm: PurchaseManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Accounts.name, ascending: true)],
        animation: .default)
    private var accounts: FetchedResults<Accounts>
    
    @StateObject private var vm: AddMannuallyVM = AddMannuallyVM()
    var account: Accounts?
    @FocusState private var isKey
    @FocusState private var isName
    @FocusState private var isService
    @Binding var isEdit: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(account == nil ? "Add manually": "Edit")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .overlay(alignment: .leading) {
                            Button {
                                if isEdit {
                                    isEdit = false
                                } else {
                                    page.page = .main
                                }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundStyle(.accent)
                                    .padding(.leading)
                            }
                    }
                    .padding(.horizontal)
                
            }
            .padding(.bottom, 12)
            
            ForEach(MannualTextFields.allCases, id: \.self) { field in
                HStack {
                    Text(field.rawValue)
                    TextField(
                        field.placeholder,
                        text:
                            MannualTextFields.key == field ? $vm.key:
                            MannualTextFields.secret == field ? $vm.name: $vm.service,
                        
                    )
                    .multilineTextAlignment(.trailing)
                    .focused(field == MannualTextFields.key ? $isKey : field == MannualTextFields.secret ? $isName : $isService)
                    
                }
                .padding(14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                
            }
            
            Spacer()
            
            Button {
                
                if vm.key.count >= 16, !vm.name.isEmpty, !vm.service.isEmpty {
                    
                    if let data = base32DecodeToData(vm.key.replacingOccurrences(of: " ", with: "")) {
                        let totp = TOTP(secret: data, digits: 6, timeInterval: 30, algorithm: .sha1)
                        let time = Date()
                        print(time)
                        let code = totp?.generate(time: time)
                        
                        if account == nil {
                            if pm.hasActiveSubscription || accounts.count == 0 {
                                CoreDataManager(vc: viewContext).addAccount(code: code ?? "No code", key: vm.key, name: vm.name, service: vm.service, timestamp: time, digit: 6, interval: 30)
                                
                                page.page = .main
                                
                            } else {
                                page.page = .paywall
                            }
                        } else {
                            account?.secret = vm.key
                            account?.name = vm.name
                            account?.service = vm.service
                            
                            do {
                                try viewContext.save()
                                isEdit = false
                            } catch {
                                print("[AddMannually] Cant save context")
                                vm.showError = true
                            }
                            
                            page.page = .main
                            
                        }
                        
                    } else {
                        print("Some error while creating key")
                        vm.showError = true
                    }
                    
                } else {
                    vm.showError = true
                }
            } label: {
                Text(account == nil ? "Create": "Save")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .background(Color.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.vertical, 20)
                    .padding(.horizontal)
            }

            
        }
        .onChange(of: vm.key, perform: { newValue in
            vm.key = fourDigitFormatted(of: newValue)
        })
        .background(
            Color.mainBG
                .ignoresSafeArea()
                .onTapGesture(perform: {
                    isKey = false
                    isName = false
                    isService = false
                })
        )
        .onAppear {
            if let account = account {
                vm.key = account.secret ?? "No secret"
                vm.name = account.name ?? "No name"
                vm.service = account.service ?? "No service"
            }
        }
        .overlay {
            if vm.showError {
                Color.black.opacity(0.3).ignoresSafeArea()
            }
        }
        .overlay(alignment: .top) {
            if vm.showError {
                Text("Invalid input data")
                    .font(.system(size: 17, weight: .semibold))
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .onChange(of: vm.showError, perform: { value in
            if value {
                Task {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    vm.showError = false
                }
            }
        })
        .animation(.easeInOut, value: vm.showError)
        .navigationBarBackButtonHidden()
    }
}

extension AddMannuallyView {
    
    func fourDigitFormatted(of string: String) -> String {
        let res = string.replacingOccurrences(
            of: "(\\w{4})(?=\\w)",
            with: "$1 ",
            options: .regularExpression
        )
        .trimmingCharacters(in: .whitespaces)
        
        return res
    }
}

//#Preview {
//    AddMannuallyView()
//}
