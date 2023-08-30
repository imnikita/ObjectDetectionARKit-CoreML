//
//  ViewController.swift
//  ObjectDetectionARKit+CoreML
//
//  Created by Mykyta Popov on 30/08/2023.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    @IBAction func cameraButtonTappet(_ sender: UIButton) {
        debugPrint("button")
    }
}
