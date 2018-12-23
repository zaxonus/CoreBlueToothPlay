//
//  ViewController.swift
//  CBCentral
//
//  Created by Michel Bouchet on 2018/12/22.
//  Copyright © 2018 Michel Bouchet. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController,CBCentralManagerDelegate,CBPeripheralDelegate {
    // In the two following lines we use the same strings as in the peripheral app.
    let serviceOne_UUID = CBUUID(string:"D95FB3F6-29BF-4D82-B29B-1A8EEB6C855C"),
    svcOneChrcOne_UUID = CBUUID(string:"30D04CBA-6750-4EEC-96D7-A806E70251A9"),
    beepLabel = UILabel()
    var cbCenterMngr:CBCentralManager!, cbPerifHandle:CBPeripheral!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cbCenterMngr = CBCentralManager(delegate: self, queue: nil)
        
        beepLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        beepLabel.textColor = UIColor.purple
        beepLabel.textAlignment = .center
        beepLabel.text = "0"
        beepLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(beepLabel)
        
        view.addConstraints([
            NSLayoutConstraint(item: beepLabel, attribute: .centerX, relatedBy: .equal,
                               toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: beepLabel, attribute: .width, relatedBy: .equal,
                               toItem: view, attribute: .width, multiplier: 0.6, constant: 0.0),
            NSLayoutConstraint(item: beepLabel, attribute: .centerY, relatedBy: .equal,
                               toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: beepLabel, attribute: .height, relatedBy: .equal,
                               toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: 40.0)])
    }


    // CBCentralManagerDelegate protocol implementation.
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: [serviceOne_UUID],
                                       options: nil)
        }
    }
    
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        peripheral.delegate = self
        cbPerifHandle = peripheral
        central.connect(peripheral, options: nil)
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([serviceOne_UUID])
    }
    
    
    // CBPeripheralDelegate protocol implementation.
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: Error?) {
        if error != nil {
            print("Error in \(#function) :\n\(error!)")
        }
        
        peripheral.discoverCharacteristics([svcOneChrcOne_UUID],
                                           for: (peripheral.services?.first)!)
    }
    
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        if error != nil {
            print("Error in \(#function) :\n\(error!)")
        } else {
            peripheral.setNotifyValue(true,
                                      for: (service.characteristics?.first)!)
            cbCenterMngr.stopScan() // We've got all we need. There is need to scan anymore.
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        if error != nil {
            print("Error in \(#function) :\n\(error!)")
        } else {
            let serviceRandonVal = Int(String(data: characteristic.value!,
                                              encoding: String.Encoding.utf8)!)!
            beepLabel.text = "\(serviceRandonVal)"
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        if invalidatedServices.first?.uuid == serviceOne_UUID {
            if cbCenterMngr.state == .poweredOn {
                // We restart scanning, hoping the service will come back to life.
                cbCenterMngr.scanForPeripherals(withServices: [serviceOne_UUID],
                                                options: nil)
            }
        }
    }
}
