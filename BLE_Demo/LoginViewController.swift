//
//  LoginViewController.swift
//  gaiaDemo
//
//  Created by User on 3/19/19.
//  Copyright © 2019 IQVIS. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseAuth

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
   
    
    @IBAction func signUpClicked(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "signUpScreen")
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    
    @IBAction func firstClicked(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "signInScreen")
        self.present(nextViewController, animated:true, completion:nil)
        
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

extension LoginViewController: FUIAuthDelegate{
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        
        guard error == nil else{
            return
        }
        
        performSegue(withIdentifier: "goHome", sender: self)
    }
    
}
