//
//  Recorder.swift
//  SensorTagRaider
//
//  Created by Lennart Olsen on 26/02/2018.
//  Copyright © 2018 lennartolsen.net. All rights reserved.
//

import UIKit
import AudioToolbox

class RecorderController: UIViewController {
    
    var device : SensorTagPeripheral! = nil
    
    var collector : Collector! = nil
    let predictor = Predictor()
    var numOfPredictions : Int = 0

    @IBOutlet weak var postureLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        collector = Collector(device : device!, delegate : self)
        
        startCollection()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startCollection(){
        DispatchQueue.main.asyncAfter(deadline : DispatchTime.now()) {
            AudioServicesPlaySystemSound(1003);
            self.collector?.doCollect(time: 1.5, type: .tiltLeft)
        }
    }
}

extension RecorderController : CollectorListenerDelegate {
    func collectionIsFinished(dataEntry : DataEntry) {
        if(numOfPredictions > 10){
            for collection in dataEntry.collections {
                let v = collection.asArray()
                print( """
                \(dataEntry.type), \(v[0]), \(v[1]), \(v[2]), \(v[3]), \(v[4]),\(v[5]),\(v[6]),\(v[7]),\(v[8]),\(dataEntry.collectionId) \n
                """ )
            }
            let prediction = predictor.PerformPrediction(dataEntry: dataEntry)
            
            if let v = prediction {
                postureLabel.text = v
            }
        }
        numOfPredictions += 1
        print(numOfPredictions)
        startCollection()
    }
}
