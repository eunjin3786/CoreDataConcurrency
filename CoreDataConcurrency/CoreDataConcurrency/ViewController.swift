//
//  ViewController.swift
//  CoreDataConcurrency
//
//  Created by Jinny on 2020/04/03.
//  Copyright © 2020 eunjin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        CoreDataManager.shared.deleteAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            for i in 0...10000 {
                CoreDataManager.shared.createStudent(name: "죠르디 \(i)", age: 10)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            CoreDataManager.shared.retrieveAll()
        }
    }
}
