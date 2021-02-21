//
//  HTTPManager.swift
//  test
//
//  Created by И.В. Винокуров on 21.02.2021.
//

import Foundation
import SwiftUI
import Combine

class HTTPManager: ObservableObject {

    @State var token: String?
    
    private struct AuthResponse: Decodable {
        struct SuccessInfo: Decodable {
            var token: String
        }
        public var success: String
        public var response: SuccessInfo
    }

    func postAuth(login: String, password: String) {
        guard let url = URL(string: "http://82.202.204.94/api/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let body: [String: String] = ["login": login.lowercased(), "password": password]
        let resultBody = try! JSONSerialization.data(withJSONObject: body)
        request.httpBody = resultBody
        
        for (key, value) in ["app-key": "12345", "v": "1"] {
            request.setValue(value, forHTTPHeaderField: key)
        }

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            do {
                let resData = try JSONDecoder().decode(AuthResponse.self, from: data)
                if resData.success == "true" {
                    DispatchQueue.main.async {
                        #if DEBUG
                            debugPrint(resData.response.token)
                        #endif
                        self.token = resData.response.token
                        Helper.saveFullInfo(login: login, password: password)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.token = nil
                    Helper.showAlert(title: "Ошибка", msg: "Логин или пароль неверные")
                }
            }
        }.resume()
    }
}
