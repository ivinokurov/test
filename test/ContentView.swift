//
//  ContentView.swift
//  test
//
//  Created by И.В. Винокуров on 21.02.2021.
//

import SwiftUI

struct ContentView : View {
    
    @ObservedObject var manager = HTTPManager()
    @State var login: String = Helper.getLogin()
    @State var password: String = "" // Helper.getPassword()
    @State var readyToShowPayments: Bool = false
    @State var showErrorAlert: Bool = false
    
    let greyColor = Color(red: 244.0/255.0, green: 244.0/255.0, blue: 244.0/255.0, opacity: 1.0)
    
    var body: some View {
        
        VStack {
            TextField("Логин", text: $login)
                .padding()
                .background(greyColor)
                .padding(.bottom, 20)
            SecureField("Пароль", text: $password)
                .padding()
                .background(greyColor)
                .padding(.bottom, 20)
            Button(action: {
                self.manager.showPayments(login: self.login, password: self.password, completion: { result in
                    self.readyToShowPayments = result
                    self.showErrorAlert = !result
                })
            })
            { LoginButtonContent() }
                .sheet(isPresented: $readyToShowPayments) {
                    PaimentsView(manager: self.manager)
                }
                .alert(isPresented: $showErrorAlert) {
                    Alert(title: Text("Ошибка!"))
            }
            Button(action: {
                Helper.removeFullInfo()

                self.login = Helper.getLogin()
                self.password = "" // Helper.getPassword()
            })
            { LogoutButtonContent() }
        }
        .padding()
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

struct LoginButtonContent : View {
    var body: some View {
        return Text("ВОЙТИ").bold()
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(Color.blue)
            .cornerRadius(15.0)
    }
}

struct LogoutButtonContent : View {
    var body: some View {
        return Text("Сменить пользователя")
            .font(.subheadline)
            .foregroundColor(.red)
            .padding()
            .frame(width: 220, height: 60)
    }
}

struct PaimentsView: View {
    var manager: HTTPManager
    init(manager: HTTPManager) {
        self.manager = manager
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(self.manager.payments) { payment in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(payment.desc!).font(.title).bold()
                        Text("Валюта: " + payment.currency!).font(.subheadline)
                        Text("Размер платежа: " + payment.amount!).font(.subheadline)
                    }
                    .padding(.top, 5)
                }
            }
            .navigationBarTitle(Text("Платежи"))
        }
    }
}



