//
//  ViewController.swift
//  EZCart
//
//  Created by Claudio Suzarte on 03/06/24.
//

import UIKit
import Vision
import CoreData

protocol ProductManagerDelegate {
    func didProductWasadd()
}

class ScanViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var delegate: ProductManagerDelegate?
    
    var cartList = [Product]()
    var wordsGeted:[String] = []
    var possiblePrice:[String] = []
    var possibleProducts:[String] = []

    @IBOutlet weak var titleTextLable: UILabel!
    @IBOutlet weak var priceTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
    }
    
    
    @IBAction func refreshTitle(_ sender: Any) {
        titleTextLable.text = possibleProducts.randomElement()
    }
    
    @IBAction func refreshPrice(_ sender: Any) {
        priceTextLabel.text = possiblePrice.randomElement()
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickerImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            recognizeLabel(image: userPickerImage)
            imagePicker.dismiss(animated: true)
        }
    }
    
    func recognizeLabel(image: UIImage?){
        // Get the CGImage on which to perform requests.
        guard let cgImage = image?.cgImage else { return }


        // Create a new image-request handler.
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)


        // Create a new request to recognize text.
        let request = VNRecognizeTextRequest { request, error in
            
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                return
            }
            
            
           let text = observations.compactMap({
                $0.topCandidates(1).first?.string
            }).joined(separator: ";")
            
            
            DispatchQueue.main.async {
               // print("Sentence: \(text)")
                self.textHandle(text: text)
                
            }
        }


        do {
            // Perform the text-recognition request.
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }
    
    func textHandle(text : String){
        possiblePrice = []
        possibleProducts = []
        
        wordsGeted = text.components(separatedBy: ";")
        
        for word in wordsGeted {
            if word.contains(",") && word.count < 8{
                //print("PREÇO: \(word)")
                possiblePrice.append(word)
            } else {
                analiseTitle(titleCheck: word)
            }
        }
        
       // print("PREÇO: \(possiblePrice)")
        //print("PRODUT: \(possibleProducts)")
       titleTextLable.text = possibleProducts.randomElement()
        priceTextLabel.text = possiblePrice.randomElement()

    }
    
    func checkNumeric(S: String) -> Bool {
       return Double(S) != nil
    }
    
    func analiseTitle(titleCheck: String){
        let model = try! LabelClassifier()
        let input = LabelClassifierInput(text: titleCheck)
        guard let output = try? model.prediction(text: titleCheck) else {
            return
        }
        
        if output.label == "title" && titleCheck.count > 5{
            print(titleCheck)
            possibleProducts.append(titleCheck)
        }
    }
    
    @IBAction func addToCartButtonPressed(_ sender: UIButton) {
        var newProduct = Product(context: self.context)
        newProduct.label = titleTextLable.text
        newProduct.priceLabel = priceTextLabel.text
        
        cartList.append(newProduct)
        saveProduct()
        print(newProduct)
    }
    
    func saveProduct(){
        do {
            try context.save()
            self.dismiss(animated: true)
            self.delegate?.didProductWasadd()
        } catch {
            print("Erro to save product: \(error)")
        }
    }
    
    @IBAction func scanButtonPressed(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    
}

