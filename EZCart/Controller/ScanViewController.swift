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
    func didProductWasAdd()
}

class ScanViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var delegate: ProductManagerDelegate?
    
    var wordsGeted:[String] = []
    var possiblePrice:[Double] = []
    var possibleProducts:[String] = []
    
    var priceManger = PriceManager()
    var cartList = [Product]()

    var realPrice: Double = 0.0
    var amount: Int = 1
    
    @IBOutlet weak var priceLabelTextField: UITextField!
    @IBOutlet weak var productLabelTextField: UITextView!
    @IBOutlet weak var amountTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
    }
    
    
    @IBAction func refreshTitle(_ sender: Any) {
        productLabelTextField.text = possibleProducts.randomElement()
    }
    
    @IBAction func refreshPrice(_ sender: Any) {
        realPrice = possiblePrice.randomElement() ?? 0.0
        priceLabelTextField.text = String(realPrice)
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
            if priceManger.priceLabelIsValid(for: word){
                let number = priceManger.convertToARealPrice(for: word)
                print("This is a number geted >>>>>>> \(number)")
                possiblePrice.append(number)
            } else {
                analiseTitle(titleCheck: word)
            }
        }
        
        productLabelTextField.text = possibleProducts.randomElement()
        realPrice = possiblePrice.randomElement() ?? 0.0
        priceLabelTextField.text = String(realPrice)

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
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        sender.minimumValue = 1
        amount = Int(sender.value)
        amountTextLabel.text = "Amount: \(amount)x"
        
    }
    
    @IBAction func addToCartButtonPressed(_ sender: UIButton) {
        var newProduct = Product(context: self.context)
        newProduct.label = productLabelTextField.text
        newProduct.priceReal = realPrice
        newProduct.amount = Int32(amount)
        
        cartList.append(newProduct)
        saveProduct()
        print(newProduct)
    }
    
    func saveProduct(){
        do {
            try context.save()
            delegate?.didProductWasAdd()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Erro to save product: \(error)")
        }
    }
    
    @IBAction func scanButtonPressed(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    
}

