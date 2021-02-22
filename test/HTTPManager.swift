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

    var token: String?
    var baseURL = "http://82.202.204.94/api"
    var isLoading : Bool = false
    
    private struct AuthResponse: Decodable {
        struct SuccessInfo: Decodable {
            var token: String
        }
        public var success: String
        public var response: SuccessInfo
    }
    
    public struct PaymentsResponse: Identifiable {
        var id: UUID
        var desc: String?
        var amount: String?
        var currency: String?
    //    var created: String?
        
        init(desc: String?, amount: String?, currency: String?/*, created: String?*/) {
            id = UUID()
            self.desc = desc
            self.amount = amount
            self.currency = currency
        //    self.created = created
        }
    }
    var payments = [PaymentsResponse]()

    func postAuth(login: String, password: String) {
        
        guard let url = URL(string: baseURL + "/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let body: [String: String] = ["login": login.lowercased(), "password": password]
        let resultBody = try! JSONSerialization.data(withJSONObject: body)
        request.httpBody = resultBody
        
        for (key, value) in ["app-key": "12345", "v": "1"] {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        self.token = nil
        
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
                } else {
                    DispatchQueue.main.async {
                        Helper.showAlert(title: "Ошибка", msg: "Логин или пароль неверные")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    Helper.showAlert(title: "Ошибка", msg: error.localizedDescription)
                }
            }
        }.resume()
    }
    
    func getPayments() {
        guard let url = URL(string: baseURL + "/payments?token=" + self.token!) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        for (key, value) in ["app-key": "12345", "v": "1"] {
            request.setValue(value, forHTTPHeaderField: key)
        }

        self.payments.removeAll()
        self.isLoading = true
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }

            let resData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            if let response = resData!["response"] as? [[String:Any]] {
                self.payments = response.compactMap{ payment in
                    let desc = payment["desc"] as? String
                    let amount = payment["amount"] as? String ?? String(payment["amount"] as! Double)
                    let currency = payment["currency"] as? String ?? ""
                    //     let created = payment["created"] as? String
                    return PaymentsResponse(desc: desc, amount: amount, currency: currency/*, created: created*/ )
                }
                self.isLoading = false
            }
        }.resume()
    }
}
