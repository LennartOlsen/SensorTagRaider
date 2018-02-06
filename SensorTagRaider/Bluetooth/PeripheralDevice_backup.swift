//
//  PeripheralDevice.swift
//  SensorTagRaider
//
//  Created by Lennart Olsen on 13/01/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation
import CoreBluetooth

//MARK: --- CBPeripheralDelegate ---
class PeripheralDevice : NSObject, CBPeripheralDelegate {
    
    private let D = true
    
    var lisenterDelegate: PeripheralListenerDelegate?
    
    override init(){
        super.init()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if(D){print("PeripheralDiscoverer: didDiscoverServices")}
        for service:CBService in peripheral.services!{
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if(D){print("PeripheralDiscoverer: didDiscoverCharacteristicsForService")}
        
        for c:CBCharacteristic in service.characteristics!{
            if(D){print("\(c.uuid.uuidString)")}
            
            //Notify characteristic discovered.
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: PDNotificationType.characteristicDiscovered.rawValue), object: c)
            
            //Discover descriptors
            peripheral.discoverDescriptors(for:c)
        }
        
        
        //Determine if charasteristics for all services has been discovered
        var all_characteristics_discovered = true
        for s:CBService in peripheral.services!{
            if s.characteristics == nil{
                all_characteristics_discovered = false
            }
        }
        
        if all_characteristics_discovered == true {
            
            //Notify when all characteristics for all services has been fund.
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: PDNotificationType.allServicesAndCharacteristicsDiscovered.rawValue), object: peripheral)
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if(D){print("PeripheralDiscoverer: didDiscoverDescriptorsForCharacteristic \(characteristic.uuid.uuidString)")}
        
        //Read values for desctiptors
        for d in characteristic.descriptors! {
            peripheral.readValue(for:d)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        if(D){print("PeripheralDiscoverer: didUpdateValueForDescriptor")}
        
        //Notify about updated descriptor
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PDNotificationType.discriptorUpdated.rawValue), object: descriptor)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if(D){print("PeripheralDiscoverer: didUpdateValueForCharacteristic")}
        
        //Notify about updated value
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PDNotificationType.valueUpdated.rawValue), object: characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if(D){print("PeripheralDiscoverer: didUpdateNotificationStateForCharacteristic charac=\(characteristic.uuid.uuidString) isNotifying=\(characteristic.isNotifying)")}
    }
}
