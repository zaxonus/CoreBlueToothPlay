//
//  ViewController.swift
//  CBPeripheral
//
//  Created by Michel Bouchet on 2018/12/21.
//  Copyright © 2018 Michel Bouchet. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController,CBPeripheralManagerDelegate {
    // Strings like the ones in the two following lines can be generated using the uuidgen command in a terminal.
    let serviceOne_UUID = CBUUID(string:"D95FB3F6-29BF-4D82-B29B-1A8EEB6C855C"),
    svcOneChrcOne_UUID = CBUUID(string:"30D04CBA-6750-4EEC-96D7-A806E70251A9"),
    signalButton = UIButton(type: .custom), beepLabel = UILabel()
    var cbPerifMngr:CBPeripheralManager!, mutaSRVC:CBMutableService!,
    svcOneCharacOne:CBMutableCharacteristic!, beepRandomValue:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cbPerifMngr = CBPeripheralManager(delegate: self, queue: nil)
        
        signalButton.setTitleColor(UIColor.darkGray, for: .normal)
        signalButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        signalButton.setTitle("Beep !!!", for: .normal)
        signalButton.addTarget(self, action: #selector(beepHandler), for: .touchUpInside)
        signalButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signalButton)
        
        beepLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        beepLabel.textColor = UIColor.purple
        beepLabel.textAlignment = .center
        beepLabel.text = "0"
        beepLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(beepLabel)
        
        view.addConstraints([
            NSLayoutConstraint(item: signalButton, attribute: .centerX, relatedBy: .equal,
                               toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: signalButton, attribute: .width, relatedBy: .equal,
                               toItem: view, attribute: .width, multiplier: 0.4, constant: 0.0),
            NSLayoutConstraint(item: signalButton, attribute: .centerY, relatedBy: .equal,
                               toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: signalButton, attribute: .height, relatedBy: .equal,
                               toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: 40.0),
            NSLayoutConstraint(item: beepLabel, attribute: .centerX, relatedBy: .equal,
                               toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: beepLabel, attribute: .width, relatedBy: .equal,
                               toItem: view, attribute: .width, multiplier: 0.6, constant: 0.0),
            NSLayoutConstraint(item: beepLabel, attribute: .centerY, relatedBy: .equal,
                               toItem: view, attribute: .centerY, multiplier: 0.5, constant: 0.0),
            NSLayoutConstraint(item: beepLabel, attribute: .height, relatedBy: .equal,
                               toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: 40.0)])
    }
    
    
    @objc func beepHandler() {
        // This function generates a random value each time it is called.
        beepRandomValue = Int.random(in: 1 ... 1000000)
        // We set this random value as the text of the label.
        beepLabel.text = "\(beepRandomValue!)"

        // We then publish the value as a characteristic of our service.
        if cbPerifMngr.updateValue(Data("\(beepRandomValue!)".utf8),
                                   for: svcOneCharacOne,
                                   onSubscribedCentrals: nil) {
            // All is OK.
        } else {
            print("For some reason, the CBPeripheralManager update was not performed in \(#function).")
        }
    }


    // CBPeripheralManagerDelegate protocol implementation.
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            mutaSRVC = CBMutableService(type: serviceOne_UUID, primary: true)
            svcOneCharacOne = CBMutableCharacteristic(type: svcOneChrcOne_UUID,
                                                      properties: [.read, .notify],
                                                      value: Data(base64Encoded: "Hello!"), permissions: .readable)
            mutaSRVC.characteristics = [svcOneCharacOne]
            cbPerifMngr?.add(mutaSRVC)
        }
    }
    
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if error != nil {
            print("Error in \(#function) :\n\(error!)")
        } else {
            cbPerifMngr.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[service.uuid]])
        }
    }
    
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if error != nil {
            print("Error in \(#function) :\n\(error!)")
        }
    }
}
