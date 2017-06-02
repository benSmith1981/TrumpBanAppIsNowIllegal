//
//  ViewController.swift
//  IsNowIllegal
//
//  Created by Maya Lekova on 2/7/17.
//  Copyright © 2017 Maya Lekova. All rights reserved.
//

import UIKit
import MapleBacon
import Alamofire
import MBProgressHUD

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var textBox: UITextField!
    @IBOutlet weak var resultMeme: UIImageView!
    @IBOutlet var ownView: UIView!
    @IBOutlet weak var creditsLabelOutlet: UILabel!
    @IBOutlet weak var illegalizeButton: UIButton!
    @IBOutlet weak var titleLabelOutlet: UILabel!
    
    var loadingNotification: MBProgressHUD?
    
    var enteredText: String? {
        guard let text = self.textBox.text?.uppercased() else {
            return nil
        }
        guard !text.isEmpty else {
            return nil
        }
        
        let trimToIdx = min(text.characters.count, 10)
        return text.substring(to: text.index(text.startIndex, offsetBy: trimToIdx))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textBox.font = UIFont(name: "Trumpit", size: 32)!
        titleLabelOutlet.font = UIFont(name: "Trumpit", size: 32)!
        illegalizeButton.titleLabel?.font = UIFont(name: "Trumpit", size: 32)!
//         [NSFontAttributeName: UIFont(name: "SFShaiFontai-Bold", size: 32)!,
//         NSForegroundColorAttributeName : UIColor.white]
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        view.endEditing(true)
    }
    
    @IBAction func dismisskey(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        guard let enteredText = self.enteredText else {
            return
        }

        let parameters: Parameters = [
            "task": "gif",
            "word": enteredText
        ]
        let url = "https://is-now-illegal.firebaseio.com/queue/tasks.json"

        self.showLoadingNotification()

        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseString {
            [unowned self] response in
            if let error = response.error {
                print("ERROR: Generating gif with text\(enteredText): \(error)")
                // TODO: Show error
                self.hideLoadingNotification()
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: {
                self.getGifUrl() { urlString in
                    self.hideLoadingNotification()
                    
                    guard let url = URL(string: urlString) else {
                        print("ERROR: Invalid URL for generated gif: \(urlString)")
                        return
                    }
                    
                    self.resultMeme.setImage(withUrl: url) { instance, error in
                        if let error = error {
                            print("ERROR while downloading image: \(error)")
                        }
                    }
                }
            })
        }
    }
    
    func getGifUrl(callback: @escaping (String) -> Void) {
        guard let enteredText = self.enteredText else {
            return
        }

        let url = "https://is-now-illegal.firebaseio.com/gifs/\(enteredText).json"
        
        Alamofire.request(url).responseString { response in
            if let JSON = response.result.value,
                let jsonObj = JSON.parseJSONString,
                let gifData = jsonObj as? NSDictionary,
                let gifObj = IllegalGif(dictionary: gifData) {
                return callback(gifObj.url ?? "")
            } else {
                return callback("")
            }
        }
    }

    func showLoadingNotification() {
        self.loadingNotification = MBProgressHUD.showAdded(to: self.ownView, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.label.text = "Illegalizing..."
    }
    
    func hideLoadingNotification() {
        self.loadingNotification?.hide(animated: true)
    }
}

// Inspired by http://stackoverflow.com/a/27269242
extension String {
    
    var parseJSONString: Any? {
        
        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        if let jsonData = data {
            // Will return an object or nil if JSON decoding fails
            do {
                let parsedData = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
                return parsedData
            } catch {
                return nil
            }
        } else {
            // Lossless conversion of the string was not possible
            return nil
        }
    }
}
