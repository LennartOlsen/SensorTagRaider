//
//  Device.swift
//  SensorTagRaider
//
//  Created by Lennart Olsen on 04/02/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation
import CoreBluetooth

let DEVICE_NAME = "TI BLE Sensor Tag"

enum SensorTagError: Error {
    case InvalidDevice
}

class SensorTagPeripheral : NSObject {
    private let sensorTag : CBPeripheral
    private var enableValue = 1
    private var enablyBytes : NSData
    
    private let D = true
    
    private var services = [String : CBService]()
    private var characteristics = [String: CBCharacteristic]()
    
    var ready = false
    
    var sensorTagDelegate : SensorTagDelegate?
    
    
    let controller = Controller()
    
    init(device: CBPeripheral) {
        self.sensorTag = device
        self.enablyBytes = NSData(bytes: &enableValue, length: MemoryLayout<UInt8>.size)
        super.init()
        self.sensorTag.delegate = self
    }
    
    static func validateSensorTag(device : CBPeripheral) -> Bool {
        if(device.name != DEVICE_NAME){
            return false
        }
        return true
    }
    
    func setup(){
        sensorTag.discoverServices(nil)
    }
    
    func addCharateristic(_ characteristic : CBCharacteristic) -> Bool {
        if(validCharacteristic(uuid : characteristic.uuid)){
            characteristics[characteristic.uuid.uuidString] = characteristic
            return true
        }
        return false
    }
    
    func addService(_ service : CBService) -> Bool {
        if(validService(uuid : service.uuid)){
            services[service.uuid.uuidString] = service
            return true
        }
        return false
    }
}

extension SensorTagPeripheral {
    
    func listenForAccelerometer() {
        if self.services[SENSORTAG_SERVICES.TI_SENSORTAG_ACCELEROMETER_SERVICE.uuidString] != nil {
            
            if let configCharacteristic = self.characteristics[SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_ACCELEROMETER_CONFIG.uuidString] {
                sensorTag.writeValue(enablyBytes as Data, for: configCharacteristic, type: .withResponse)
                
                if let dataCharacteristic = self.characteristics[SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_ACCELEROMETER_DATA.uuidString] {
                    sensorTag.setNotifyValue(true, for: dataCharacteristic)
                }
            }
        }
    }
    
    func listenForGyroscope(){
        if self.services[SENSORTAG_SERVICES.TI_SENSORTAG_GYROSCOPE_SERVICE.uuidString] != nil {
            
            
            if let configCharacteristic = self.characteristics[SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_GYROSCOPE_CONFIG.uuidString] {
                sensorTag.writeValue(enablyBytes as Data, for: configCharacteristic, type: .withResponse)
                
                if let dataCharacteristic = self.characteristics[SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_GYROSCOPE_DATA.uuidString] {
                    sensorTag.setNotifyValue(true, for: dataCharacteristic)
                }
            }
            
        }
    }
    
    func listenForMagnetometer(){
        if self.services[SENSORTAG_SERVICES.TI_SENSORTAG_MAGNETOMETER_SERVICE.uuidString] != nil {
            
            if let configCharacteristic = self.characteristics[SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_MAGNETOMETER_CONFIG.uuidString] {
                sensorTag.writeValue(enablyBytes as Data, for: configCharacteristic, type: .withResponse)
                
                if let dataCharacteristic = self.characteristics[SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_MAGNETOMETER_DATA.uuidString] {
                    sensorTag.setNotifyValue(true, for: dataCharacteristic)
                }
            }
            
        }
    }
}

extension SensorTagPeripheral : CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service:CBService in peripheral.services!{
            if(addService(service)){
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if(D){print("PeripheralDiscoverer: didDiscoverCharacteristicsForService")}
        
        for c:CBCharacteristic in service.characteristics!{
            _ = addCharateristic(c)
        }
       
        //Determine if charasteristics for all services has been discovered
        var allCharacteristicsDiscovered = true
        for service:CBService in peripheral.services!{
            if service.characteristics == nil &&
                !SENSORTAG_SERVICES.NO_CHARACTERISTICS_ARRAY.contains(service.uuid) {
                allCharacteristicsDiscovered = false
            }
        }
        
        if allCharacteristicsDiscovered {
            for characteristic:CBCharacteristic in service.characteristics!{
                if(D){print("\(characteristic.uuid.uuidString)")}
            }
            
            sensorTagDelegate?.ready()
            ready = true
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) { /** We only listen to characteristics **/ }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if(D){print("PeripheralDiscoverer: didUpdateValueForCharacteristic")}
        
        if(error == nil){
            if characteristic.uuid == SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_ACCELEROMETER_DATA {
                sensorTagDelegate?.Accelerometer(values: controller.getAccelerometerData(value: characteristic.value! as NSData ))
            }
            if characteristic.uuid == SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_MAGNETOMETER_DATA {
                sensorTagDelegate?.Magnetometer(values: controller.getMagnetometerData(value: characteristic.value! as NSData ))
            }
            if characteristic.uuid == SENSORTAG_CHARACTERISTICS.TI_SENSORTAG_GYROSCOPE_DATA {
                sensorTagDelegate?.Gyroscope(values: controller.getGyroscopeData(value: characteristic.value! as NSData ))
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if(D){print("PeripheralDiscoverer: didUpdateNotificationStateForCharacteristic charac=\(characteristic.uuid.uuidString) isNotifying=\(characteristic.isNotifying)")}
    }
}

extension SensorTagPeripheral {
    private func validService(uuid : CBUUID) -> Bool{
        return SENSORTAG_SERVICES.array.contains(uuid)
    }
    
    private func validCharacteristic(uuid : CBUUID) -> Bool {
        return SENSORTAG_CHARACTERISTICS.array.contains(uuid)
    }
}
