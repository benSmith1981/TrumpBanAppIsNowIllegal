//
//  StartViewController.swift
//  StreamingNetworkApp
//
//  Created by Jeroen de Bie on 31/03/2017.
//  Copyright © 2017 Jeroen de Bie. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak var illegalTItle: UIImageView!
    @IBOutlet weak var nowTextLabelOutlet: UILabel!
    @IBOutlet weak var isTextLabelOutlet: UILabel!
    
    @IBOutlet weak var nowXConstraint: NSLayoutConstraint!
    @IBOutlet weak var isXConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        illegalTItle.alpha = 0
        nowTextLabelOutlet.alpha = 0
        nowTextLabelOutlet.font = UIFont(name: "Trumpit", size: 32)!
        self.nowXConstraint.constant = 0

        isTextLabelOutlet.alpha = 0
        isTextLabelOutlet.font = UIFont(name: "Trumpit", size: 32)!
        self.isXConstraint.constant = 0

        UIView.animate(withDuration: 3, delay: 0, options: [], animations: {
            self.nowTextLabelOutlet.alpha = 1
            self.isTextLabelOutlet.alpha = 1
            self.illegalTItle.alpha = 1

            self.view.layoutIfNeeded()
        }) { (finished) in
            //
            
            self.performSegue(withIdentifier: "ToMainVIew", sender: self)
        }

        // Do any additional setup after loading the view.
    }

    override func viewWillDisappear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
