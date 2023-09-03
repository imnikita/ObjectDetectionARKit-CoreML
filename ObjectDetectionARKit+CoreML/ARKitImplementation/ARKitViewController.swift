//
//  ARKitViewController.swift
//  ObjectDetectionARKit+CoreML
//
//  Created by Mykyta Popov on 03/09/2023.
//

import UIKit
import SceneKit
import ARKit

class ARKitViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!

    private let restNetModel = Resnet50()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
                
        registerGestures()
    }
    
    private func registerGestures() {
        let gestureRecognizer = UITapGestureRecognizer(target: self,
                                                       action: #selector(shoot))
        sceneView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func shoot(_ recognizer: UITapGestureRecognizer) {
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}
