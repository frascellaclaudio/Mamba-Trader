//
//  ViewController.swift
//  MambaTrader
//
//  Created by Frascella Claudio on 6/7/17.
//  Copyright © 2017 TeamDecano. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {


    @IBOutlet weak var resultStockCodeLabel: UILabel!
    @IBOutlet weak var resultPercentage: UILabel!
    @IBOutlet weak var resultAveragePrice: UILabel!
    @IBOutlet weak var resultGainLoss: UILabel!
    @IBOutlet weak var resultSellingPrice: UILabel!
    @IBOutlet weak var resultMoneyIn: UILabel!
    @IBOutlet weak var resultMoneyOut: UILabel!
    @IBOutlet weak var inputStockCode: UITextField!
    @IBOutlet weak var inputBuyingPrice: UITextField!
    @IBOutlet weak var inputShares: UITextField!
    @IBOutlet weak var inputMarketPrice: UITextField!
    @IBOutlet weak var resultIndicatorGainLoss: UILabel!
    
    @IBAction func stockCodeLabelUpdate(_ sender: Any) {
        resultStockCodeLabel.text = inputStockCode.text
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        inputStockCode.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        //resultStockCodeLabel.text = inputStockCode.text! != "" ? inputStockCode.text: inputStockCode.placeholder
    }

    
    // Removing the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func calculate(_ sender: Any) {
        if inputMarketPrice.text! == "" {
            inputMarketPrice.text = inputMarketPrice.placeholder
        }
        
        if inputShares.text! == "" {
            inputShares.text = inputShares.placeholder
        }
        
        if inputBuyingPrice.text! == "" {
            inputBuyingPrice.text = inputBuyingPrice.placeholder
        }
        
        if inputStockCode.text! == "" {
            inputStockCode.text = inputStockCode.placeholder
        }
        
        calculatePage()
    }
    
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {(UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func formatDecimal(decimalNumber: Double, decimalPlaces: Int) -> String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.minimumFractionDigits = decimalPlaces
        numberFormatter.maximumFractionDigits = decimalPlaces
        
        let formattedNumber = numberFormatter.string(from: NSNumber(value:decimalNumber))!
        
        return formattedNumber
    }
    
    func calculatePage() {
    
        //resultStockCodeLabel.text = inputStockCode.text! != "" ? inputStockCode.text: inputStockCode.placeholder
        
        let buyPrice = (Double(inputBuyingPrice.text!))!
        let marketPrice = (Double(inputMarketPrice.text!))!
        let numShares = (Double(inputShares.text!))!
        
        if (numShares > 0.0 && buyPrice > 0.0) {

            let averageBuyPrice = calculateAverageBuyingPrice(buyPrice: buyPrice, numShares: numShares)
            let _ = calculateAverageSellingPrice(buyPrice: averageBuyPrice, numShares: numShares)
            
            let moneyIn = calculateMoneyInPrice(buyPrice: buyPrice, numShares: numShares)
            let moneyOut = calculateMoneyOutPrice(numShares: numShares, marketPrice: marketPrice)
            let gainLossTotal = moneyOut - moneyIn
            let gainLossPercentage = (gainLossTotal / moneyIn) * 100
    
            
            resultGainLoss.text = formatDecimal(decimalNumber: gainLossTotal, decimalPlaces: 2)
            resultPercentage.text = formatDecimal(decimalNumber: gainLossPercentage, decimalPlaces: 2) + "%"
    
            // set text color
            if gainLossTotal < 0 {
                resultGainLoss.textColor = UIColor.red
                resultPercentage.textColor = UIColor.red
                
                resultIndicatorGainLoss.alpha = 1
                resultIndicatorGainLoss.text = "Loss"
                resultIndicatorGainLoss.textColor = UIColor.red
                
                resultMoneyOut.textColor = UIColor.red
                
            } else {
                resultGainLoss.textColor = UIColor.green
                resultPercentage.textColor = UIColor.green
                
                resultIndicatorGainLoss.alpha = 1
                resultIndicatorGainLoss.text = "Gain"
                resultIndicatorGainLoss.textColor = UIColor.green
                
                resultMoneyOut.textColor = UIColor.green
            }
        } else {
            // create alert
            displayAlert(title: "Error", message: "Please enter number of shares or buy in price.")
        }
    }
    
    func calculateAverageSellingPrice(buyPrice: Double, numShares: Double) -> Double {
        
        // Buy COL charges
        var buyCommission = 20.0
        
        if ((buyPrice * numShares * 0.0025) > 20) {
            buyCommission = buyPrice * numShares * 0.0025
        }
        
        let buyVat = buyCommission * 0.12
        let buyPseFee = buyPrice * numShares * 0.00005
        let buySecFee = buyPrice * numShares * 0.0001
        let salesTax = buyPrice * numShares * 0.005
        let buyTotalCharges = buyCommission + buyVat + buyPseFee + buySecFee + salesTax
        
        let averageSellPrice = ((buyPrice * numShares) + buyTotalCharges) / numShares
        
        //DecimalFormat formatter = new DecimalFormat("###,###,###.0000");
        resultSellingPrice.text = formatDecimal(decimalNumber: averageSellPrice, decimalPlaces: 4)
        
        return averageSellPrice
    
    }
    
    func calculateAverageBuyingPrice(buyPrice: Double, numShares: Double) -> Double {
        
        // Buy COL charges
        var buyCommission = 20.0
        
        if ((buyPrice * numShares * 0.0025) > 20) {
            buyCommission = buyPrice * numShares * 0.0025
        }
        
        let buyVat = buyCommission * 0.12
        let buyPseFee = buyPrice * numShares * 0.00005
        let buySecFee = buyPrice * numShares * 0.0001
        let buyTotalCharges = buyCommission + buyVat + buyPseFee + buySecFee
        
        let averageBuyPrice = ((buyPrice * numShares) + buyTotalCharges) / numShares

        resultAveragePrice.text = formatDecimal(decimalNumber: averageBuyPrice, decimalPlaces: 4)
        
        return averageBuyPrice
    }
    
    func calculateMoneyInPrice(buyPrice: Double, numShares: Double) -> Double {
        
        // Buy COL charges
        var buyCommission = 20.0
        
        if ((buyPrice * numShares * 0.0025) > 20) {
            buyCommission = buyPrice * numShares * 0.0025
        }
        
        let buyVat = buyCommission * 0.12
        let buyPseFee = buyPrice * numShares * 0.00005
        let buySecFee = buyPrice * numShares * 0.0001
        let buyTotalCharges = buyCommission + buyVat + buyPseFee + buySecFee
        
        let moneyIn = ((buyPrice * numShares) + buyTotalCharges)
        
        resultMoneyIn.text = formatDecimal(decimalNumber: moneyIn, decimalPlaces: 2)
        
        return moneyIn
    }
    
    func calculateMoneyOutPrice(numShares: Double, marketPrice: Double) -> Double {
        
        // Buy COL charges
        var buyCommission = 20.0
        
        if ((marketPrice * numShares * 0.0025) > 20) {
            buyCommission = marketPrice * numShares * 0.0025
        }
        
        let buyVat = buyCommission * 0.12
        let buyPseFee = marketPrice * numShares * 0.00005
        let buySecFee = marketPrice * numShares * 0.0001
        let salesTax = marketPrice * numShares * 0.005
        let buyTotalCharges = buyCommission + buyVat + buyPseFee + buySecFee + salesTax
        
        let moneyOut = ((marketPrice * numShares) - buyTotalCharges)
        
        resultMoneyOut.text = formatDecimal(decimalNumber: moneyOut,decimalPlaces: 2)
        
        return moneyOut
    }

    
    
}

