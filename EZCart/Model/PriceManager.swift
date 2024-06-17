//
//  ScanManager.swift
//  EZCart
//
//  Created by Claudio Suzarte on 17/06/24.
//

import Foundation

struct PriceManager {
    
    
    func convertToARealPrice(for price: String) -> Double {
        
        if priceLabelIsValid(for: price) {
            
            let commaReplaced = price.replacingOccurrences(of: ",", with: ".")
            let convertedPrice = Double(commaReplaced.filter("0123456789.".contains))
            
            if let value = convertedPrice {
                return value
            } else {
                return 0.0
            }
            
        } else {
          return 0.0
        }
    }
    
    func priceLabelIsValid(for priceLabel: String) -> Bool{
        
        if priceLabel.count > 2 && priceLabel.count < 8 {
            
            if priceLabel.contains(",") && hasANumber(price: priceLabel){
                 return true
            } else {
                return false
            }
        } else {
            return false
        }
        
    }
    
    func hasANumber(price: String) -> Bool {
        
        let decimal = CharacterSet.decimalDigits
        
        let check = price.rangeOfCharacter(from: decimal)
        
        if check != nil {
            return true
        } else {
            return false
        }
    }
    
    
}
