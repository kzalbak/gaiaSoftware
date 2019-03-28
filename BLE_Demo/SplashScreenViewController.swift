//
//  SplashScreenViewController.swift
//  gaiaDemo
//
//  Created by User on 3/18/19.
//  Copyright © 2019 IQVIS. All rights reserved.
//

import UIKit
import AudioToolbox

class SplashScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func moveBlue(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "navScreen") 
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    @IBAction func goHomeScreen(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "homeScreen")
        self.present(nextViewController, animated: true, completion: nil)
        print(ViewController().getCurrentConnectedPeripheral()?.name)
         //AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate)) 
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
