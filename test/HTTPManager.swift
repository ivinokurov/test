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
    //    var created: String? не понял, что здесь такое
        
        init(desc: String?, amount: String?, currency: String?/*, created: String?*/) {
            id = UUID()
            self.desc = desc
            self.amount = amount
            self.currency = currency
        //    self.created = created
        }
    }
    var payments = [PaymentsResponse]()

    func postAuth(login: String, password: String, completion: @escaping ((String?) -> Void)) {
        
        guard let url = URL(string: baseURL + "/login") else { return }
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

            let resData = try? JSONDecoder().decode(AuthResponse.self, from: data)
                if let response = resData {
                    if response.success == "true" {
                        DispatchQueue.main.async {
                            #if DEBUG
                                debugPrint(response.response.token)
                            #endif
                        self.token = response.response.token
                        Helper.saveFullInfo(login: login, password: password)
                        completion(self.token!)
                        }
                    }
                } else {
                    completion(nil)
                }
        }.resume()
    }
    
    func getPayments(token: String?,  completion: @escaping ((Bool) -> Void)) {
        guard token != nil else {
            return completion(false)
        }
        guard let url = URL(string: baseURL + "/payments?token=" + token!) else {
            return completion(false)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        for (key, value) in ["app-key": "12345", "v": "1"] {
            request.setValue(value, forHTTPHeaderField: key)
        }

        self.payments.removeAll()
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                return
            }

            let resData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            if let response = resData!["response"] as? [[String:Any]] {
                self.payments = response.compactMap{ payment in
                    let desc = payment["desc"] as? String
                    let amount = payment["amount"] as? String ?? String(payment["amount"] as! Double)
                    let currency = payment["currency"] as? String ?? ""
                //    let created = payment["created"] as? String
                    return PaymentsResponse(desc: desc, amount: amount, currency: currency/*, created: created*/ )
                }
                if self.payments.isEmpty {
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }.resume()
    }
    
    func showPayments(login: String, password: String,  completion: @escaping ((Bool) -> Void)) {
        self.postAuth(login: login, password: password, completion: {
            token in self.getPayments(token: token, completion: {
                result in
                completion(result)
            })
        })
    }
}
