//
//  CartViewController.swift
//  EZCart
//
//  Created by Claudio Suzarte on 12/06/24.
//

import UIKit
import CoreData
import SwipeCellKit

class CartViewController: UITableViewController, ProductManagerDelegate, SwipeTableViewCellDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var cartList = [Product]()
    var totalPrice: Double = 0.00

    override func viewDidLoad() {
        super.viewDidLoad()
        loadProducts()
        getCartPrice()
    }
    
    
    @IBAction func cleanCartButtonPressed(_ sender: UIBarButtonItem) {
        
        for product in cartList {
            context.delete(product)
        }
        
        do {
            try context.save()
        } catch {
            print("Erro to save product: \(error)")
        }
        
        getCartPrice()
        loadProducts()
        
    }
    
    // MARK: - LOAD DATA
    
    func didProductWasAdd() {
        loadProducts()
        getCartPrice()
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
    
    func getCartPrice(){
        for product in cartList {
            totalPrice += product.priceReal * Double(product.amount)
        }
        
        let totalFormated = String(format: "%.2f", totalPrice).replacingOccurrences(of: ".", with: ",")
        navigationItem.title = "R$ \(totalFormated)"
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        let product = cartList[indexPath.row]
        cell.textLabel?.text = "\(product.amount)x \(product.label!)"
        let priceString = String(format: "%.2f", product.priceReal).replacingOccurrences(of: ".", with: ",")
        cell.detailTextLabel?.text = "R$\(priceString)"

        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")

        return [deleteAction]
    }
}
