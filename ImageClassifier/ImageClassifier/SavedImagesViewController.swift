//
//  SavedImagesViewController.swift
//  ImageClassifier
//
//  Created by Sam Henry on 5/3/19.
//  Copyright © 2019 Practice. All rights reserved.
//

import UIKit
import Firebase

class SavedImagesViewController: UIViewController, UICollectionViewDataSource {

    var images = [imagePost]()

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var identifierHolder = ""
        var confidenceHolder = 0

        let DBRef = Database.database().reference().child("Images")
        DBRef.observe(.childAdded, with: {
            snapshot in

            let snapObject = snapshot.value as! NSDictionary
            
//            print("OBJ", snapObject)
            
            identifierHolder = snapObject["indentifier"] as! String
            confidenceHolder = snapObject["confidence"] as! Int
            
            let dlLink = snapObject["downloadURL"] as! String
            
//            print("conf", confidenceHolder, "id", identifierHolder, "img", dlLink)
            
            self.downloadImages(confidence: confidenceHolder, identifier: identifierHolder, link: dlLink)

            
        })
    }
    
    func downloadImages(confidence: Int, identifier: String, link: String){
        print("IN DOWLOAD WITH", confidence, identifier, link)
        
        let group = DispatchGroup()
        group.enter()
        
        DispatchQueue.main.async {
            let storageRef = Storage.storage().reference(forURL: link)
            storageRef.downloadURL {
                (url, error) in
                
                if let data = try? Data(contentsOf: url!) {
                    if let image = UIImage(data: data){
                        print("IMAGE", image)
                        self.images.append(imagePost(image: image, confidence: confidence, identifier: identifier))
                    }
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            print("download done")
            print("conf", confidence, "id", identifier)
            self.collectionView.reloadData()
        }

        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("count", images.count)
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "uploadCell", for: indexPath) as! UploadedCollectionViewCell
        
        let confidenceString = String(images[indexPath.row].confidence)
        
//        print("ID", images[indexPath.row].identifier)
        
        cell.cellImage.image = images[indexPath.row].image
        cell.cellConfLabel.text = "\(confidenceString) %"
        cell.cellIdentLabel.text = images[indexPath.row].identifier
        
        return cell
    }
}

class imagePost {
    let image: UIImage
    let confidence: Int
    let identifier: String
    
    init(image: UIImage, confidence: Int, identifier: String) {
        self.image = image
        self.confidence = confidence
        self.identifier = identifier
    }
}

