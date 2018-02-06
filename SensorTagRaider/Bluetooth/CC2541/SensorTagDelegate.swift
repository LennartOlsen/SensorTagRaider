//
//  SensorTagDelegate.swift
//  SensorTagRaider
//
//  Created by Lennart Olsen on 04/02/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import Foundation

protocol SensorTagDelegate {
    func ready()
    func errored()
    
    func Accelerometer(values : [Double])
    
    func Magnetometer(values : [Double])
    
    func Gyroscope(values : [Double])
}
