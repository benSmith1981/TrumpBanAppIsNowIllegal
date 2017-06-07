//
//  ViewController.swift
//  IsNowIllegal
//
//  Created by Ben Smith on 29/05/2017.
//  Copyright © 2017 Ben Smith. All rights reserved.
//


import UIKit
import MapleBacon
import Alamofire
import MBProgressHUD
import GoogleMobileAds

class ViewController: UIViewController, UITextFieldDelegate, GADBannerViewDelegate {
    @IBOutlet weak var textBox: UITextField!
    @IBOutlet weak var resultMeme: UIImageView!
    @IBOutlet var ownView: UIView!
    @IBOutlet weak var illegalizeButton: UIButton!
    @IBOutlet weak var titleLabelOutlet: UILabel!
    @IBOutlet weak var shareButtonOutlet: UIButton!
    var gifObj: IllegalGif?
    var loadingNotification: MBProgressHUD?
    @IBOutlet weak var adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)

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
        adBannerView?.delegate = self
        adBannerView?.adUnitID = "ca-app-pub-0852965901868072/6496687572"
        adBannerView?.rootViewController = self
        let request = GADRequest()
        adBannerView?.load(request)

        textBox.font = UIFont(name: "Trumpit", size: 20)!
        titleLabelOutlet.font = UIFont(name: "Trumpit", size: 20)!
        illegalizeButton.titleLabel?.font = UIFont(name: "Trumpit", size: 20)!
        
        shareButtonOutlet.layer.masksToBounds = true
        shareButtonOutlet.clipsToBounds = true
        shareButtonOutlet.layer.cornerRadius = 5
        
        resultMeme.layer.masksToBounds = true
        resultMeme.clipsToBounds = true
        resultMeme.layer.cornerRadius = 5

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        illegalise()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        view.endEditing(true)
    }
    
    @IBAction func dismisskey(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        view.endEditing(true)
        illegalise()
    }
    
    func illegalise() {
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
                        //                        MapleBaconStorage.sharedStorage.store(image: (instance?.image)!, data: nil, forKey: "gifImage")
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
                self.gifObj = gifObj
                return callback(gifObj.url ?? "")
            } else {
                return callback("")
            }
        }
    }

    @IBAction func shareFestival(_ sender: UIButton) {
        guard let url = NSURL(string: (self.gifObj?.url)!) else {
            return
        }
        if let title: String = self.enteredText {
            let text = "\(title) is now illegal!"

            let activityViewController = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: { 
                print("Finished")
            })
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
    
    // MARK: - GADBannerViewDelegate
    // Called when an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    // Called when an ad request failed.
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("\(#function): \(error.localizedDescription)")
    }
    
    // Called just before presenting the user a full screen view, such as a browser, in response to
    // clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    // Called just before dismissing a full screen view.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    // Called just after dismissing a full screen view.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    // Called just before the application will background or terminate because the user clicked on an
    // ad that will launch another application (such as the App Store).
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print(#function)
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
