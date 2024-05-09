//
//  ViewController.swift
//  Poehali
//
//  Created by Nurken Kidirmaganbetov  on 09.05.2024.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

enum APIError: Error {
    case invalidPlaceType
    case invalidURL
    case invalidResponse
    case invalidData
    case invalidStatusCode
    case jsonSerializationError
}
