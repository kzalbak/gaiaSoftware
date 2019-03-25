//
//  HomeScreenViewController.swift
//  gaiaDemo
//
//  Created by User on 3/20/19.
//  Copyright © 2019 IQVIS. All rights reserved.
//

import UIKit

class HomeScreenViewController: UIViewController {

    @IBOutlet weak var Timelbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "splashScreen")
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    // For Timer
    var ActTime = 0
    var TimeS = 0
    var TimeM = 0
    var TimeH = 0
    
    // Actual Timer
    var timerA = Timer()
    
    @IBAction func startTimer(_ sender: Any) {
        timerA = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(HomeScreenViewController.ActStart), userInfo: nil, repeats: true)
    }
    
    
    @IBAction func stopTimer(_ sender: Any) {
        timerA.invalidate()
        timerA.invalidate()
        /*
        ActTime = 0
        TimeH = 0
        TimeM = 0
        TimeS = 0
        Timelbl.text = String(format: "%02d",TimeH) + ":" + String(format: "%02d", TimeM) + ":" + String(format: "%02d", TimeS)
        */
    }
    
    func ActStart(){
        ActTime += 1//Actual Time
        TimeS = ActTime % 60 //Seconds
        TimeM = (ActTime / 60) % 60 //Minutes
        TimeH = ActTime / 3600 //Hours
        
        Timelbl.text = String(format: "%02d",TimeH) + ":" + String(format: "%02d", TimeM) + ":" + String(format: "%02d", TimeS)
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
