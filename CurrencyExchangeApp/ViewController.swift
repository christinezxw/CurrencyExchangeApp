//
//  ViewController.swift
//  CurrencyExchangeApp
//
//  Created by Xuanwei Zhang on 10/15/21.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire
import Foundation

class ViewController: UIViewController, UIPickerViewDelegate,UIPickerViewDataSource, UITextFieldDelegate {
    // picker view
    @IBOutlet weak var picker: UIPickerView!
    
    var currencies = ["USD","AUD","CAD","PLN","MXN"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencies.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
         return currencies[row]
     }
    
//    func getCurrencies()->Array<String>{
////        SwiftSpinner.show("Initializing...")
//        let url = baseURL + "?access_key=" + apiKey
//        var currencies = [String]()
//        AF.request(url).responseJSON { response in
////            SwiftSpinner.hide()
//            if response.error != nil {
//                print(response.error)
//                return
//            }
//            let infos = JSON(response.data!)
//            let rates = infos["rates"]
//
//
//            for (key, Object) in rates {
//                currencies.append(key)
//            }
//        }
//        return currencies
//    }
     
    @IBOutlet weak var txtAmount: UITextField!
    
    //UITextField Delegates
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtAmount {
            let allowedCharacters = CharacterSet(charactersIn:"0123456789.")
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    
    @IBOutlet weak var lblExchange: UILabel!
    
    let baseURL = "http://api.exchangeratesapi.io/v1/latest"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        txtAmount.delegate = self
        picker.delegate = self
        picker.dataSource = self
//        print(self.getCurrencies())
    }
   
    @IBAction func getCurrencyExchange(_ sender: Any) {
        if txtAmount.text == "" {
            return;
        }
        let fromAmount = Double(txtAmount.text!)
        
        let from  = currencies[picker.selectedRow(inComponent: 0)]
        let to  = currencies[picker.selectedRow(inComponent: 1)]
        let apiKey = valueForAPIKey(named:"API_KEY")

        let url = baseURL + "?access_key=" + apiKey + "&symbols=" + from + "," + to
        
        SwiftSpinner.show("Getting currency exchange...")
        AF.request(url).responseJSON { response in
            SwiftSpinner.hide()
            if response.error != nil {
                print(response.error)
                return
            }
            let infos = JSON(response.data!)
            let fromCurrencyRate = infos["rates"][from].doubleValue
            let toCurrencyRate = infos["rates"][to].doubleValue
            let exchangeAmount = (toCurrencyRate/fromCurrencyRate)*fromAmount!
            let exchangeAmountString = String(format: "%.2f", exchangeAmount)
            self.lblExchange.text = "\(exchangeAmountString)"
        }
    }
    
    func valueForAPIKey(named keyname:String) -> String {
        let filePath = Bundle.main.path(forResource: "ApiKeys", ofType: "plist")
        let plist = NSDictionary(contentsOfFile:filePath!)
        let value = plist?.object(forKey: keyname) as! String
        return value
    }
}

