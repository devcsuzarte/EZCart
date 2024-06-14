//
//  CartViewController.swift
//  EZCart
//
//  Created by Claudio Suzarte on 12/06/24.
//

import UIKit
import CoreData

class CartViewController: UITableViewController, ProductManagerDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var cartList = [Product]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func didProductWasadd() {
        print("Did product was add")
        loadProducts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("oi")
        loadProducts()
    }
    
    
    func loadProducts(){
        let request : NSFetchRequest<Product> = Product.fetchRequest()
        do {
            cartList = try context.fetch(request)
            for label in cartList {
                print("Items fetched from database: \(label.label!)")
            }
        } catch {
            print("Erro fetching data: \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ScanViewController
        destinationVC.delegate = self

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = cartList[indexPath.row].label
        cell.detailTextLabel?.text = cartList[indexPath.row].priceLabel
        return cell
    }
}
