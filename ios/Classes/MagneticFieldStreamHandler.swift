//
//  AccelerometerStreamHandler.swift
//  flutter_sensors
//
//  Created by Luis Jara Castillo on 11/21/19.
//

import Foundation
import Flutter
import CoreMotion

public class MagneticFieldStreamHandler : NSObject, FlutterStreamHandler {
    public static let SENSOR_ID = 2
    private var motionManager: CMMotionManager?
    
    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        if isAvailable() {
            self.startUpdates(arguments: arguments, eventSink: eventSink)
        }
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.stopUpdates()
        return nil
    }
    
    private func initMotionManager() {
        if motionManager == nil{
            motionManager = CMMotionManager()
        }
    }
    
    private func configMotionManager(arguments: Any?) {
        if arguments != nil{
            let args = arguments as? [String: Any] ?? Dictionary<String, Any>()
            let interval = args["interval"] as? Int ?? 0
            setInterval(interval: interval)
        }
    }
    
    private func startUpdates(arguments: Any?, eventSink:@escaping FlutterEventSink){
        initMotionManager()
        configMotionManager(arguments: arguments)
        self.motionManager?.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: { (data, error) in
            guard error == nil else { return }
            guard let deviceMotion = data else { return }
            let values = deviceMotion.magneticField.field
            let dataArray = [
                values.x,
                values.y,
                values.z
            ]
            SwiftFlutterSensorsPlugin.notify(sensorId: MagneticFieldStreamHandler.SENSOR_ID, sensorData: dataArray, eventSink: eventSink)
        })
    }
    
    private func stopUpdates(){
        motionManager?.stopDeviceMotionUpdates()
        motionManager = nil
    }
    
    public func setInterval(interval: Int) {
        motionManager?.deviceMotionUpdateInterval = TimeInterval(interval)
    }
    
    public func isAvailable() -> Bool {
        return CMMotionManager().isDeviceMotionAvailable
    }
}
