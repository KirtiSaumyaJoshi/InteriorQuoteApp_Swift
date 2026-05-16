//
//  ViewController.swift
//  InteriorQuoteApp_Swift
//
//  Created by Kirti Saumya Joshi on 4/5/2026.
//

import UIKit
import FirebaseFirestore
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let db = Firestore.firestore()

        db.collection("test").addDocument(data: [
            "name": "Kirti",
            "status": "connected"
        ]) { error in
            if let error = error {
                print("Firestore error: \(error)")
            } else {
                print("Firestore connected successfully!")
            }
        }
    }


}

