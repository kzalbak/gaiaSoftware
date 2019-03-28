//
//  HomeScreenViewController.swift
//  gaiaDemo
//
//  Created by User on 3/20/19.
//  Copyright © 2019 IQVIS. All rights reserved.
//

import UIKit
import CoreBluetooth
import Foundation

class HomeScreenViewController: UIViewController, CBCentralManagerDelegate,CBPeripheralDelegate {

    @IBOutlet weak var Timelbl: UILabel!
    @IBOutlet weak var HeartRatelbl: UILabel!
    
    //central manager, receiving data
    var centralManager:CBCentralManager!
    //peripheral manager, sending data
    var connectingPeripheral:CBPeripheral!
    
    /////////Polar Heart Rate////////////
    let HSP3_5_UUID = "180D"
    override func viewDidLoad() {
        super.viewDidLoad()

        let heartRateServiceUUID = CBUUID(string: HSP3_5_UUID)
        let services = [heartRateServiceUUID];
        let centralManager = CBCentralManager(delegate: self, queue: nil)
        
        centralManager.scanForPeripherals(withServices: services, options: nil)
        
        //Arduino
        //centralManager.scanForPeripherals(withServices: ArduinoServices, options: nil)
        
        //[centralManager scanForPeripheralsWithServices:services options:nil];
        self.centralManager = centralManager;
        // Do any additional setup after loading the view.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
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
        var bpmTemp:Int
        bpmTemp = Int(UInt(bpm!))
        var GSRL: String
        if let actualBpm = bpm{
            print(actualBpm)
            HeartRatelbl.text = ("\(actualBpm)")
            //GSRlbl.text = (GSRL)
        }else {
            HeartRatelbl.text = ("\(bpm!)")
            //GSRlbl.text = (GSRL)
            print(bpm!)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("--- didUpdateValueForCharacteristic")
        
        if (error) != nil{
            
        }else {
            switch characteristic.uuid.uuidString{
            case "2A37":
                update(heartRateData:characteristic.value!)
                
            default:
                print("--- something other than 2A37 uuid characteristic")
            }
        }
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
