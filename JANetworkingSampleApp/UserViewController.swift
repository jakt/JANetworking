//
//  UserViewController.swift
//  JANetworking
//
//  Created by Jay Chmilewski on 6/21/17.
//  Copyright © 2017 JAKT. All rights reserved.
//

import UIKit
import JANetworking

class UserViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var tokenLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.text = "Loading..."
        phoneTextField.text = "Loading..."

        fetchUserDetails()
        NotificationCenter.default.addObserver(self, selector: #selector(tokenStatusChanged), name: tokenStatusNotificationName, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: tokenStatusNotificationName, object: nil)
    }
    
    @objc func tokenStatusChanged() {
        switch JANetworking.tokenStatus {
        case .invalidCantRefresh?:
            tokenLabel.text = "Token is invalid and cannot be refreshed"
        case .invalidRefreshedSuccessfully?:
            tokenLabel.text = "Token was invalid on last server call but was updated successfully and is now valid"
        case .valid?:
            tokenLabel.text = "Token is valid!"
        case nil:
            tokenLabel.text = "Token has not been initialized"
        }
    }
    
    func fetchUserDetails() {
        let resource = User.userDetails()
        JANetworking.loadJSON(resource: resource) { (user, error) in
            guard let user = user else {
                if let err:JANetworkingError = error {
                    print("NETWORK ERROR: \(err.errorType.errorTitle())")
                    if let data = err.errorData, let code = err.statusCode {
                        print("Status Code: \(code), Details: \(data)")
                    }
                }
                return
            }
            self.usernameTextField.text = user.username
            self.phoneTextField.text = "\(user.phoneNumber)"
        }
    }
    
    // MARK: - Button Actions
    
    @IBAction func resetTokenPressed(_ sender: Any) {
        // Set token to an invalid string and call a server call. The call should fail but then trigger the token refresh logic set up in AppDelegate.
        JANetworkingConfiguration.token = "expired token"
        fetchUserDetails()
    }

    @IBAction func savePressed(_ sender: Any) {
        guard let username = usernameTextField.text, let phone = phoneTextField.text else {
            return print("Enter both fields before udpdating")
        }
        guard let phoneInt = Int(phone), phoneInt < 99999999999 else {
            return print("Enter a valid integer value for the phone number")
        }
        
        let resource = User.update(username: username, phone: phoneInt)
        JANetworking.loadJSON(resource: resource) { (user, error) in
            guard let user = user else {
                if let err:JANetworkingError = error {
                    print("NETWORK ERROR: \(err.errorType.errorTitle())")
                    if let data = err.errorData, let code = err.statusCode {
                        print("Status Code: \(code), Details: \(data)")
                    }
                }
                return
            }
            self.usernameTextField.text = user.username
            self.phoneTextField.text = "\(user.phoneNumber)"
        }
    }

}
