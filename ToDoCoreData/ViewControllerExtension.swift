//
//  ViewControllerExtension.swift
//  ToDoCoreData
//
//  Created by Sharandeep Singh on 18/12/24.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
}
