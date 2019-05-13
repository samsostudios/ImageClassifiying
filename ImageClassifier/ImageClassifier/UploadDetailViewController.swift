//
//  UploadDetailViewController.swift
//  ImageClassifier
//
//  Created by Sam Henry on 5/1/19.
//  Copyright © 2019 Practice. All rights reserved.
//

import UIKit
import CoreML
import Vision
import YPImagePicker
import Hero
import Firebase

class UploadDetailViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var selectedImage = UIImage()
    var analyzeImage = CIImage()
    
    var modelConfidence: Float = 0.00
    var modelClassification =  ""
    var truncatedConfidence = 0.0
    var identifierResult = ""
    
    @IBOutlet weak var modelInfoLabel: UILabel!
    @IBOutlet weak var uploadImageView: UIImageView!
    
    @IBOutlet weak var analyzeButtonSetup: UIButton!
    @IBAction func analyzeButton(_ sender: UIButton) {
        if analyzeButtonSetup.currentTitle == "Analyze"{
            print("analyze image")
            self.detectImage(image: analyzeImage)
        }
        if analyzeButtonSetup.currentTitle == "Save" {
            print("Save to firebase")
            
            let imageID = UUID().uuidString
            let dbRef = Database.database().reference().child("Images").child(imageID)
            let storageRef = Storage.storage().reference().child("Images")
            
            guard let imageData = selectedImage.jpegData(compressionQuality: 0.1) else {return}
            let imageMetaData = StorageMetadata()
            imageMetaData.contentType = "image/jpg"
            
            let uploadTask = storageRef.child(imageID).putData(imageData, metadata: imageMetaData) {
                (metaData, error) in
                
                if error != nil {
                    print("error with upload", error!)
                }else{
                    storageRef.child(imageID).downloadURL {
                        (imgURL, error) in
                        
                        if error != nil {
                            print("error with downloadURL")
                        }else{
                            let downloadUrl = imgURL?.absoluteString
                            let link = downloadUrl as! String
                            
//                            print("identfifier", self.identifierResult, "confidence", self.truncatedConfidence, "downloadURL", downloadUrl!)
                            
                            let uploadObject = ["indentifier": self.identifierResult, "confidence": self.truncatedConfidence, "downloadURL": link] as [String : Any]
                            print(uploadObject)
                            
                            dbRef.setValue(uploadObject)
                            
                        }
                    }
                }
            }
            
            print("Identifier", identifierResult, "confidence", truncatedConfidence, "image", selectedImage)
            
        }
        
        analyzeButtonSetup.text("Save")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        let buttonHeight = analyzeButtonSetup.bounds.height
        analyzeButtonSetup.layer.cornerRadius = buttonHeight/2
        
        showPicker()
    }
    
    
    func showPicker() {
        var config = YPImagePickerConfiguration()
        config.shouldSaveNewPicturesToAlbum = false
        config.startOnScreen = .library
        config.screens = [.library, .photo]
        config.video.libraryTimeLimit = 500.0
        config.wordings.libraryTitle = "Gallery"
        config.hidesStatusBar = false
        config.hidesBottomBar = false
        config.library.maxNumberOfItems = 1
        config.showsPhotoFilters = false
        config.showsCrop = .none
        config.library.spacingBetweenItems = 0.5
        config.overlayView = UIView()
        
        let picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { [unowned picker] items, cancelled in
            
            if cancelled {
                print("Picker was canceled")
                picker.dismiss(animated: true, completion: nil)
                return
            }
            
            for item in items{
                switch item {
                case .photo(let photo):
                    self.selectedImage = photo.image
                    self.uploadImageView.image = photo.image
                    
                    guard let ciImage = try? CIImage(image: photo.image) else{
                        fatalError("error getting CIImage")
                    }
                    self.analyzeImage = ciImage
                    
                case .video(let video):
                    print("VIDEO", video)
                }
            }
            picker.dismiss(animated: true, completion: nil)
            
        }
        present(picker, animated: true, completion: nil)
    }
    
    func detectImage(image: CIImage){
//        let dbRef = Database.database().reference().child({<#T##pathString: String##String#>})
        guard let model = try? VNCoreMLModel(for: ImageClassifier().model) else{
            fatalError("loading model failed")
        }
        
        let request = VNCoreMLRequest(model: model) {
            (request, error) in
            guard let results  = request.results as? [VNClassificationObservation] else{
                fatalError("model error")
            }
            print("RESULTS", results[0].identifier)
            let confidenceDec = results[0].confidence as! Float
            let confidence = confidenceDec * 100
            self.truncatedConfidence = Double(round(confidence))
            
            self.identifierResult = results[0].identifier
            
            self.modelInfoLabel.text = "\(self.truncatedConfidence)% \(self.identifierResult)"
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
          try! handler.perform([request])
        }catch{
            print(error)
        }
        
    }

}
