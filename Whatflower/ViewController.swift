//
//  ViewController.swift
//  WhatFlower
//
//  Created by Hrithvik  Alex on 2018-10-07.
//  Copyright © 2018 Hrithvik  Alex. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON
import SDWebImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let wikipediaURl = "https://en.wikipedia.org/w/api.php"

   
    @IBOutlet weak var ImageView: UIImageView!
    
    @IBOutlet weak var textLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            guard let ciImage = CIImage(image: userPickedImage)else {
                fatalError("could not convert")
            }
            
            detect(image: ciImage)
         ImageView.image = userPickedImage
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage){
        
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError("cannot import")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let classification = request.results?.first as? VNClassificationObservation else {
                fatalError("No flower found")
            }
            
            self.navigationItem.title = classification.identifier.capitalized
            self.requestInfo(flowerType: classification.identifier)
        
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
   
    func requestInfo(flowerType: String){
        
        let parameters : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts|pageimages",
            "exintro" : "",
            "explaintext" : "",
            "titles" : flowerType,
            "indexpageids" : "",
            "redirects" : "1",
            "pithumbsize" : "500",
            
            ]
        Alamofire.request(wikipediaURl, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                print("got info")
                let flowerJSON : JSON = JSON(response.result.value!)
                let pageID = flowerJSON["query"]["pageids"][0].stringValue
                let extract = flowerJSON["query"]["pages"][pageID]["extract"].stringValue
                let imageURL = flowerJSON["query"]["pages"][pageID]["thumbnail"]["source"].stringValue
                
                self.ImageView.sd_setImage(with: URL(string: imageURL))
                self.textLabel.text = extract
            }
        }
    }
    
    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    

}










