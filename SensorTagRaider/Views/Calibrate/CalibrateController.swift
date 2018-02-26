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
    
    @IBOutlet weak var calibrateButton: UIButton!
    
    var fvc : FaceViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        calibrateButton.isEnabled = false
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
    
    @IBAction func doCalibrate(_ sender: Any) {
        device.calibrate()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is RecorderController {
            if let d = device {
                let vc = segue.destination as! RecorderController
                vc.device = d
            }
        }
    }
}
extension CalibrateController : SensorTagDelegate {
    func Ready(){
        infoLabel.text = "Ready"
        device.listenForAccelerometer()
        device.listenForGyroscope()
        device.listenForMagnetometer()
    }
    func Errored() {
        infoLabel.text = "Error"
    }
    
    func Accelerometer(measurement : AccelerometerMeasurement) {}
    
    func Magnetometer(measurement : MagnetometerMeasurement) {}
    
    func Gyroscope(measurement : GyroscopeMeasurement){}
    
    func Calibrated(values : [[Double]]){
        performSegue(withIdentifier: "recorderSegue", sender: self)
    }
    
    func ReadyForCalibration() {
        calibrateButton.isEnabled = true
    }
}
