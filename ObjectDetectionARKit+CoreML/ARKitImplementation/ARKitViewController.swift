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
    
    private var hitTestResult: ARHitTestResult?
    
    private var visionRequests = [VNRequest]()
    
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
    
    private func registerGestures() {
        let gestureRecognizer = UITapGestureRecognizer(target: self,
                                                       action: #selector(tap))
        sceneView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func tap(_ recognizer: UITapGestureRecognizer) {
        guard let sceneView = recognizer.view as? ARSCNView else { return }
        let touchLocation = sceneView.center
        
        guard let currentFrame = sceneView.session.currentFrame else { return }
        
        let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
        
        guard !hitTestResults.isEmpty,
                let hitResult = hitTestResults.first  else { return }
        
        self.hitTestResult = hitResult
        
        performRequest(currentFrame.capturedImage)
    }
    
    private func performRequest(_ pixelBuffer: CVPixelBuffer) {
        guard let visionModel = try? VNCoreMLModel(for: restNetModel.model) else { return }
        
        let request = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
            if let error = error {
                fatalError("Failed to create request")
            }
            
            guard let observations = request.results,
                  let observation = observations.first as? VNClassificationObservation
            else { return }
            
            let predictionText = "Name \(observation.identifier) with confidence \(observation.confidence * 100) "
            
            DispatchQueue.main.async {
                self?.displayPredictions(predictionText)
            }
            
        }
        
        request.imageCropAndScaleOption = .centerCrop
        visionRequests = [request]
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                        orientation: .upMirrored)
        
        DispatchQueue.global(qos: .userInitiated).async {
            try? imageRequestHandler.perform(self.visionRequests)
        }
    }
    
    private func displayPredictions(_ text: String) {
        let node = createTextNode(text)
        
        guard let columns = self.hitTestResult?.worldTransform.columns.3 else { return }
        node.position = SCNVector3(columns.x, columns.y, columns.z)
        
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    private func createTextNode(_ text: String) -> SCNNode {
        let parentNode = SCNNode()
        
        let sphere = SCNSphere(radius: 0.01)
        
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = UIColor.orange
        sphere.firstMaterial = sphereMaterial
        
        let sphereNode = SCNNode(geometry: sphere)
        
        let textGeometry = SCNText(string: text, extrusionDepth: 0)
        
        textGeometry.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        textGeometry.firstMaterial?.diffuse.contents = UIColor.orange
        textGeometry.firstMaterial?.specular.contents = UIColor.white
        textGeometry.firstMaterial?.isDoubleSided = true
        
        var font = UIFont(name: "Futura", size: 0.15)
        textGeometry.font = font
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.scale = SCNVector3Make(0.2, 0.2, 0.2)
        
        parentNode.addChildNode(sphereNode)
        parentNode.addChildNode(textNode)
        
        return parentNode
    }
}
