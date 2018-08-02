//
//  ViewController.swift
//  KTExpandableView
//
//  Created by Krishna Kumar on 06/25/2018.
//  Copyright (c) 2018 Krishna Kumar. All rights reserved.
//

import UIKit
import KTExpandableView

class HMViewController: UIViewController {

    @IBOutlet weak var container: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func ac(_ sender: Any) {
        let liveViewController =  KTExpandableViewController()
        self.present(liveViewController, animated: false, completion: nil)
    }
}

