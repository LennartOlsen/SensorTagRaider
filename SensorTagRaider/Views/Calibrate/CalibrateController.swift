//
//  CalibrateController.swift
//  SensorTagRaider
//
//  Created by Lennart Olsen on 29/01/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation

import UIKit
import SceneKit

class CalibrateController: UIViewController {
    var device : SensorTagPeripheral! = nil
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var faceView: SCNView!
    
    var fvc : FaceViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configure(){
        infoLabel.text = "Initiating Pacman"
        device.sensorTagDelegate = self
        device.setup()
        fvc = FaceViewController(scene : faceView)
    }
}
extension CalibrateController : SensorTagDelegate {
    
    func errored() {
        infoLabel.text = "Error"
    }
    
    func ready() {
        infoLabel.text = "Ready"
        device.listenForAccelerometer()
        //device.listenForGyroscope()
        //device.listenForMagnetometer()
        
    }
    
    func Accelerometer(values: [Double]) {
        print("Accellerometer \(values)")
        fvc.rotate(x: values[0], y: values[1], z: values[2])
    }
    func Magnetometer(values: [Double]) {
        print("Magnetometer \(values)")
        //fvc.rotate(x: values[0], y: values[1], z: values[2])
    }
    
    func Gyroscope(values: [Double]) {
        print("Gyro \(values)")
        fvc.rotate(x: values[0], y: values[1], z: values[2])
    }
}
