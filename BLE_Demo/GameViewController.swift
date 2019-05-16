//
//  GameViewController.swift
//  gaiaDemo
//
//  Created by User on 4/24/19.
//  Copyright © 2019 IQVIS. All rights reserved.
//

import UIKit
import SpriteKit
import Foundation
import CoreBluetooth
import AudioToolbox

class GameViewController: UIViewController, CBCentralManagerDelegate,CBPeripheralDelegate {
    
    @IBOutlet weak var faceLbl: UIImageView!
    
    @IBOutlet weak var meterLbl: UIImageView!
    
    var timeracc = 0.0
    var acc = 0.0
    
    //central manager, receiving data
    var centralManager:CBCentralManager!
    //peripheral manager, sending data
    var connectingPeripheral:CBPeripheral!
    
    let HSP3_5_UUID = "180D"
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        
        let heartRateServiceUUID = CBUUID(string: HSP3_5_UUID)
        let services = [heartRateServiceUUID];
        let centralManager = CBCentralManager(delegate: self, queue: nil)
        
        centralManager.scanForPeripherals(withServices: services, options: nil)
        
        //Arduino
        //centralManager.scanForPeripherals(withServices: ArduinoServices, options: nil)
        
        //[centralManager scanForPeripheralsWithServices:services options:nil];
        self.centralManager = centralManager;
        // Do any additional setup after loading the view.
        
        /*
        Timelbl.text = "00.00"
        HeartRatelbl.text = "00.00"
        timerA = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(HomeScreenViewController.ActStart), userInfo: nil, repeats: true)
        */
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("--- centralManagerDidUpdateState")
        switch central.state{
        case .poweredOn:
            print("poweredOn")
            
            let serviceUUIDs:[AnyObject] = [CBUUID(string: "180D")]
            let lastPeripherals = centralManager.retrieveConnectedPeripherals(withServices: serviceUUIDs as! [CBUUID])
            
            if lastPeripherals.count > 0{
                let device = lastPeripherals.last! as CBPeripheral;
                connectingPeripheral = device;
                centralManager.connect(connectingPeripheral, options: nil)
            }
            else {
                centralManager.scanForPeripherals(withServices: serviceUUIDs as? [CBUUID], options: nil)
                
            }
        case .poweredOff:
            print("--- central state is powered off")
        case .resetting:
            print("--- central state is resetting")
        case .unauthorized:
            print("--- central state is unauthorized")
        case .unknown:
            print("--- central state is unknown")
        case .unsupported:
            print("--- central state is unsupported")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("--- didDiscover peripheral")
        
        if let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String{
            print("--- found heart rate monitor named \(localName)")
            self.centralManager.stopScan()
            connectingPeripheral = peripheral
            connectingPeripheral.delegate = self
            centralManager.connect(connectingPeripheral, options: nil)
        }else{
            print("!!!--- can't unwrap advertisementData[CBAdvertisementDataLocalNameKey]")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("--- didConnectPeripheral")
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        print("--- peripheral state is \(peripheral.state)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if (error) != nil{
            print("!!!--- error in didDiscoverServices: \(error?.localizedDescription)")
        }
        else {
            print("--- error in didDiscoverServices")
            for service in peripheral.services as [CBService]!{
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if (error) != nil{
            print("!!!--- error in didDiscoverCharacteristicsFor: \(String(describing: error?.localizedDescription))")
        }
        else {
            
            if service.uuid == CBUUID(string: "180D"){
                for characteristic in service.characteristics! as [CBCharacteristic]{
                    switch characteristic.uuid.uuidString{
                        
                    case "2A37":
                        // Set notification on heart rate measurement
                        print("Found a Heart Rate Measurement Characteristic")
                        peripheral.setNotifyValue(true, for: characteristic)
                        
                    case "2A38":
                        // Read body sensor location
                        print("Found a Body Sensor Location Characteristic")
                        peripheral.readValue(for: characteristic)
                        
                    case "2A29":
                        // Read body sensor location
                        print("Found a HRM manufacturer name Characteristic")
                        peripheral.readValue(for: characteristic)
                        
                    case "2A39":
                        // Write heart rate control point
                        print("Found a Heart Rate Control Point Characteristic")
                        
                        var rawArray:[UInt8] = [0x01];
                        let data = NSData(bytes: &rawArray, length: rawArray.count)
                        peripheral.writeValue(data as Data, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
                        
                    default:
                        print()
                    }
                    
                }
            }
        }
    }



    @IBAction func goHomePage(_ sender: Any) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "homeScreen")
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    
    func update(heartRateData:Data){
        print("--- UPDATING ..")
        var buffer = [UInt8](repeating: 0x00, count: heartRateData.count)
        heartRateData.copyBytes(to: &buffer, count: buffer.count)
        
        var bpm:UInt16?
        if (buffer.count >= 2){
            if (buffer[0] & 0x01 == 0){
                bpm = UInt16(buffer[1]);
            }else {
                bpm = UInt16(buffer[1]) << 8
                bpm =  bpm! | UInt16(buffer[2])
            }
        }
        
         
         if(timeracc<=3)
         {
         acc = acc + Double(bpm!)
         }
         let final = acc/30
         print("accumulator: ", acc)
         print("time: ", timeracc)
         let calc1 = Int(ceil(final * 0.87))
         let calc2 = Int(ceil(final*0.9))
         let calc3 = Int(ceil(final*0.95))
         let calc4 = Int(ceil(final*1))
         let calc5 = Int(ceil(final*1.05))
         let calc6 = Int(ceil(final*1.15))
         let calc7 = Int(ceil(final*1.25))
        let bpmTemp:Int
        bpmTemp = Int(UInt(bpm!))
        var GSRL: String
        //if(timeracc>=30){
            switch bpmTemp{
            case 0...calc1:
                //lbl.text = ("😁: Doing Yoga?")
                meterLbl.image = UIImage(named: "MeterLow")!
                faceLbl.image = UIImage(named: "f0")!
                GSRL = "Low"
                break
            case calc1...calc2:
                //lbl.text = ("😄: You're cool")
                meterLbl.image = UIImage(named: "MeterLowHigh")!
                faceLbl.image = UIImage(named: "f1")!
                
                GSRL = "Low-High"
                break
            case calc2...calc3:
                //lbl.text = ("😃: Relaxed?")
                meterLbl.image = UIImage(named: "MeterNormLow")!
                faceLbl.image = UIImage(named: "f2")!
                
                GSRL = "Normal"
                break
            case calc3...calc4:
                //lbl.text = ("😊: Be Chill")
                meterLbl.image = UIImage(named: "MeterNorm")!
                faceLbl.image = UIImage(named: "f2")!
                
                GSRL = "Normal"
                break
            case calc4...calc5:
                //lbl.text = ("🙂: You're Good")
                meterLbl.image = UIImage(named: "MeterNormHigh")!
                faceLbl.image = UIImage(named: "f3")!
                
                GSRL = "Normal"
                break
            case calc5...calc6:
                //lbl.text = ("🙁: Breath")
                meterLbl.image = UIImage(named: "MeterHighLow")!
                faceLbl.image = UIImage(named: "f4")!
                
                GSRL = "High"
                break
            case let x where x > calc7:
                //lbl.text = ("☹️: Chillout")
                meterLbl.image = UIImage(named: "MeterHigh")!
                faceLbl.image = UIImage(named: "f5")!
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                let alert = UIAlertController(title: "Alert", message: "Chill out!", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                GSRL = "High"
                break
            default:
                GSRL = "N/A"
            //}
        }
        
        /*
        if let actualBpm = bpm{
            print(actualBpm)
            HeartRatelbl.text = ("\(actualBpm)")
            //GSRlbl.text = (GSRL)
        }else {
            HeartRatelbl.text = ("\(bpm!)")
            //GSRlbl.text = (GSRL)
            print(bpm!)
        }
        */
    }


}


    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


