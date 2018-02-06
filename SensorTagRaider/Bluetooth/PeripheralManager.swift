//
//  PeripheralDiscoverer.swift
//  SensorTagRaider
//
//  Created by Lennart Olsen on 13/01/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation
import CoreBluetooth


enum PDNotificationType:String{
    case newPeripheralsDiscovered
    case peripheralStateChanged
    case serviceDiscovered
    case characteristicDiscovered
    case allServicesAndCharacteristicsDiscovered
    case discriptorUpdated
    case valueUpdated
}

class PeripheralManager : NSObject, CBCentralManagerDelegate {
    
    private var D = false
    
    
    //Singleton pattern, we want only one instance of this class.
    static let sharedInstance = PeripheralManager()
    
    var central:CBCentralManager?
    
    var lisenterDelegate: BluetoothListenerDelegate?
    
    var discoveredDevices:[UUID:CBPeripheral] = [:]
    
    private override init()
    {
        super.init()
        self.central = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        if(D){print("PeripheralDiscoverer.init()")}
    }
    
    func connectToDevice(uuid : UUID) -> CBPeripheral! {
        if let device = discoveredDevices[uuid] {
            self.central?.connect(device)
            return device
        }
        return nil
    }
    
    func stopScan(){
        central?.stopScan()
    }
}

// MARK: --- CBCentralManagerDelegate ---
extension PeripheralManager {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if (central.state == CBManagerState.poweredOn)
        {
            if(D){print("PeripheralDiscoverer: didUpdateState ON")}
            
            //Specific service
            //let MyServiceUuid = CBUUID.init(string: "7E940010-8030-4261-8523-8953AB03CFC0")
            //self.central?.scanForPeripherals(withServices:[MyServiceUuid], options: nil)
            
            //All serivces
            self.central?.scanForPeripherals(withServices:nil, options: nil)
        }
        else
        {
            // do something like alert the user that ble is not on
            if(D){print("PeripheralDiscoverer: didUpdateState \(central.state)")}
        }
    }
    
    //MARK: --- didDiscover ---
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let id = peripheral.identifier //iOS abstraction over hardware address to comply with privacy of the MAC address.
        
        //Add peripheral to dict.
        self.discoveredDevices[id] = peripheral
        
        if(D){print("PeripheralDiscoverer: didDiscoverPeripheral: \(id.uuidString) \(String(describing: peripheral.name))")}
        
    
        lisenterDelegate?.didDiscover(peripheralDevice: peripheral)
        
    }
    
    //MARK: --- didConnect ---
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if(D){print("PeripheralDiscoverer: didConnectPeripheral: \(peripheral.state.rawValue)")}
        
        
        lisenterDelegate?.didConnect(peripheralDevice: peripheral)
    }
    
    //MARK: --- didDisconnect ---
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if(D){print("PeripheralDiscoverer: didDisconnectPeripheral: \(peripheral.state.rawValue)")}
        
        
    }
}
