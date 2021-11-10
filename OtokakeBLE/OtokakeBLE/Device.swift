//
//  Device.swift
//  OtokakeBLE
//
//  Created by gotokazu1884 on 2021/10/23.
//

import Foundation
import CoreBluetooth

final class Device: NSObject {
    let peripheral: CBPeripheral
    let rssi: NSNumber
    var state = State.disconnected

    init(peripheral: CBPeripheral, rssi: NSNumber) {
        self.peripheral = peripheral
        self.rssi = rssi
        super.init()
        peripheral.delegate = self
    }
}

extension Device {

    enum State: String, CustomStringConvertible {
        case disconnected
        case connected

        var description: String {
            return rawValue
        }
    }
}


// MARK: - CBPeripheralDelegate

extension Device: CBPeripheralDelegate {}
