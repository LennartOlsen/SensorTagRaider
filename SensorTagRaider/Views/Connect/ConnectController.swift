//
//  ConnectController.swift
//  SensorTagRaider
//
//  Created by Lennart Olsen on 29/01/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation

import CoreBluetooth
import UIKit

class ConnectController: UIViewController, BluetoothListenerDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var bluetoothButton: UIButton!
    @IBOutlet weak var informationLabel: UILabel!
    
    private var pm = PeripheralManager.sharedInstance //singleton
    
    private var discoveredDevice : CBPeripheral!
    private var connectedDevice : CBPeripheral!
    
    private let D = true
    
    var devices: [UUID : CBPeripheral] = [:]
    
    func didDiscover(peripheralDevice: CBPeripheral) {
        
        if( SensorTagPeripheral.validateSensorTag(device : peripheralDevice) ){
            informationLabel.text = "Found device, click icon to connect"
            activityIndicator.stopAnimating()
            UIView.animate(withDuration: 0.2, animations: {
                self.bluetoothButton.alpha = 1
                self.activityIndicator.alpha = 0
            })
            discoveredDevice = peripheralDevice
            
            pm.stopScan()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func Connect(_ sender: Any) {
        if(D){
            print("hello from connect")
        }
        
        if let dd = discoveredDevice {
            informationLabel.text = "Connecting..."
            discoveredDevice = pm.connectToDevice(uuid: dd.identifier)
        }
    }
    
    func didConnect(peripheralDevice: CBPeripheral) {
        if(D) {
            print("did connect", peripheralDevice)
        }
        
        if SensorTagPeripheral.validateSensorTag(device: peripheralDevice) {
            informationLabel.text = "Device Connected"
            connectedDevice = peripheralDevice
            print("success", peripheralDevice)
            
            performSegue(withIdentifier: "calibrateSegue", sender : nil)
        }
    }
    
    func configure(){
        pm.lisenterDelegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "calibrateSegue" {
            let vc = segue.destination as! CalibrateController
            vc.device = SensorTagPeripheral(device: connectedDevice)
        }
    }
}

