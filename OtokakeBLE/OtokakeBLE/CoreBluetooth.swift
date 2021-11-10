//
//  CoreBluetooth.swift
//  OtokakeBLE
//
//  Created by gotokazu1884 on 2021/10/22.
//

import Foundation
import SwiftUI
import CoreBluetooth
    
    class SomeClass: SomeSuperclass, CBCentralManagerDelegate {
        var centralManager: CBCentralManager!
        var peripheral: CBPeripheral!
    
        centralManager = CBCentralManager(delegate: self, queue: nil)
        func centralManagerDidUpdateState(central: CBCentralManager) {

            print("state: \(central.state)")
        }
