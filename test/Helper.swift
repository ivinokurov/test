//
//  Helper.swift
//  test
//
//  Created by И.В. Винокуров on 21.02.2021.
//

import Foundation
import UIKit

class Helper {
    
    static let defaults = UserDefaults.standard
    
    class func showAlert(title: String, msg: String) {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            UIApplication.shared.windows.first!.rootViewController?.present(alert, animated: true, completion: nil)
        }
    
    class func saveFullInfo(login: String, password: String) {
        defaults.set(login, forKey: "login")
        defaults.set(password, forKey: "password")
    }
    
    class func removeFullInfo() {
        for key in ["login", "password"] {
            defaults.removeObject(forKey: key)
        }
    }
    
    class func getLogin() -> String {
        return defaults.object(forKey:"login") as? String ?? ""
    }
    
    class func getPassword() -> String {
        return defaults.object(forKey:"password") as? String ?? ""
    }
}
