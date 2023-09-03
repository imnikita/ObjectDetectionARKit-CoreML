//
//  ViewController.swift
//  ObjectDetectionARKit+CoreML
//
//  Created by Mykyta Popov on 30/08/2023.
//

import UIKit
import CoreML
import Vision

class MainViewController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textView: UITextView!
    
    private let imagePicker = UIImagePickerController()
    
    private let model = GoogLeNetPlaces()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.delegate = self

    }
    
    @IBAction func cameraButtonTappet(_ sender: UIButton) {
        present(imagePicker, animated: true)
    }
    
    private func processImage(_ image: UIImage) {
        
        guard let ciImage = CIImage(image: image) else { return }
        
        guard let visionModel = try? VNCoreMLModel(for: model.model) else {
            fatalError("Unable to create model")
        }
        
        let visionRequest = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
            if let error = error {
                self?.textView.text = error.localizedDescription
                return
            }
            
            guard let result = request.results as? [VNClassificationObservation] else {
                self?.textView.text = "Unable to recognise object."
                return
            }
            
            let classifications = result.map { observation in
                let resultMessage = "It is \(observation.confidence * 100) that the object is \(observation.identifier)"
                return resultMessage
            }
            
            DispatchQueue.main.async {
                self?.textView.text = classifications.joined(separator: "\n")
            }
        }
        
        let visionRequestHandler = VNImageRequestHandler(ciImage: ciImage,
                                                         orientation: .up,
                                                         options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? visionRequestHandler.perform([visionRequest])
        }
    }
}

extension MainViewController: UINavigationControllerDelegate {
    
}

extension MainViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        imageView.image = pickedImage
        processImage(pickedImage)
    }
}
