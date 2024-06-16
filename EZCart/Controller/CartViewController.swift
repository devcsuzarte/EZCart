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
        loadProducts()
    }
    
    func didProductWasAdd() {
        print(">>>>>>Did product was add")
        loadProducts()
    }
    
    func loadProducts(){
        let request : NSFetchRequest<Product> = Product.fetchRequest()
        do {
            cartList = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Erro fetching data: \(error)")
        }
    }
    
    // MARK: - Table view data source
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let scanVC = segue.destination as! ScanViewController
        scanVC.delegate = self
    }

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
