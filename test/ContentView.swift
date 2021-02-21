//
//  ContentView.swift
//  test
//
//  Created by И.В. Винокуров on 21.02.2021.
//

import SwiftUI

struct ContentView : View {
    
    @ObservedObject var manager = HTTPManager()
    @State var showAlert = false
    
    @State var login: String = Helper.getLogin()
    @State var password: String = "" // Helper.getPassword()
    
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
                self.manager.postAuth(login: self.login, password: self.password)
                guard self.manager.token != nil else {
                    self.showAlert = true
                    return
                }
            })
            { LoginButtonContent() }
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
        return Text("ВОЙТИ")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(Color.green)
            .cornerRadius(15.0)
    }
}

struct LogoutButtonContent : View {
    var body: some View {
        return Text("Сменить пользователя")
            .font(.footnote)
            .foregroundColor(.red)
            .padding()
            .frame(width: 220, height: 60)
            .cornerRadius(15.0)
    }
}


