//
//  ViewController.swift
//  OtokakeBLE
//
//  Created by gotokazu1884 on 2021/10/17.
//

import UIKit
import CoreBluetooth

class ReciveViewController: UIViewController, CBPeripheralManagerDelegate {
   

 //   @IBOutlet weak var counterLabel: UILabel!
    
    var uuids = Array<UUID>()
    var names = [UUID : String]()
    var peripherals = [UUID : CBPeripheral]()
    var targetPeripheral: CBPeripheral!
    
    var centralManager: CBCentralManager!
    var peripheralManager: CBPeripheralManager!
    
    var serviceUUID = CBUUID(string: "3507E6F6-79B7-597A-8E96-6738F4EB4E76")
    var characteristic: CBMutableCharacteristic!
    var characteristics: [CBCharacteristic] = []
    var characteristicUUID = CBUUID(string: "f2d644e0-b89e-48c7-9d37-f9b3caec89f0")

    var sendData: Data = Data()
    var readValues: [Data] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
        setup()
    }

    
    
    private func setup() {
        print("setup...")

        centralManager = CBCentralManager()
        centralManager.delegate = self as CBCentralManagerDelegate
        peripheralManager.delegate = self
   }
    
    func startScan() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("スキャン開始")
            //let service = CBUUID(string: "3507e6f6-79b7-597a-8e96-6738f4eb4e76")
            self.centralManager.scanForPeripherals(withServices: nil, options: nil)
            Timer.scheduledTimer(withTimeInterval: 10/*nil*/, repeats: false) {_ in //後で変更
              //  print("スキャン停止/特定のペリフェラルはありません")
                self.centralManager.stopScan()
              //  print("スキャン停止")
            }
            
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("peripheral-State\(peripheral.state)")
      /*  let characteristic = CBMutableCharacteristic(type: characteristicUUID,properties: [.write, .notify], value: nil, permissions: .writeable)
        let service = CBMutableService(type: serviceUUID, primary: true)
        service.characteristics = [characteristic]
        peripheralManager.add(service)
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [service],
                                           CBAdvertisementDataLocalNameKey: "Device Information"])*/
    }
    
    func setPeripheral(target: CBPeripheral){
        self.targetPeripheral = target
    }
    
    func setCentralManager(manager: CBCentralManager){
        self.centralManager = manager
    }
    
    func searchService(){
        print("searchService")
        self.targetPeripheral.delegate = self
        self.targetPeripheral.discoverServices([serviceUUID])
    }
    
    func searchCharacteristics(service: CBService){
        print("searchCharacteristic")
        self.targetPeripheral.delegate = self
        self.targetPeripheral.discoverCharacteristics([characteristicUUID], for: service)
    }
    
    //service検索後
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let e = error {
            print("ErrorServices: \(e.localizedDescription)")
            return
        }
        
        print("didDiscoverServices")
        print("P: \(String(describing: peripheral.name)) - Discovered service S:'\(peripheral.services![0].uuid)'")
            searchCharacteristics(service: peripheral.services![0])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        print("didDiscoverCharacteristicsForService")
        
        for characteristic in service.characteristics! {
            characteristics.append(characteristic)
            self.targetPeripheral.readValue(for: characteristic)
        }
    }
    
    func publishservice(){
        print("publishService")
        let service = CBMutableService(type: serviceUUID, primary: true)
        self.characteristic = CBMutableCharacteristic(type: characteristicUUID, properties: CBCharacteristicProperties.read, value: nil, permissions: CBAttributePermissions.readable)
        service.characteristics = [characteristic]
        self.peripheralManager.add(service)
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if error != nil{
        print("***Advertising ERROR")
        return
        }
    print("Advertising success")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        if request.characteristic.uuid.isEqual(characteristic.uuid) {
            // CBMutableCharacteristicのvalueをCBATTRequestのvalueにセット
            let data: Data = sendData
            print("data: \(String(describing: data))")
            self.characteristic.value = sendData
            request.value = self.characteristic.value
            // リクエストに応答
            peripheralManager.respond(to: request, withResult: .success)
        }
    }
    
    

}



//MARK : - CBCentralManagerDelegate
extension ReciveViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("CentralManager didUpdateState")

        switch central.state {
            
        //電源ONを待って、スキャンする
        case .poweredOff:
            print("Bluetoothの電源がoff")
        case .poweredOn:
            print("Bluetoothの電源がOn")
            startAdvertise()
            startScan()
        case .resetting:
            print("レスティング状態")
        case .unauthorized:
            print("非認証状態")
        case .unknown:
            print("不明")
        case .unsupported:
            print("非対応")
        @unknown default:
            print("")
        }
    }
    
    /// ペリフェラルを発見すると呼ばれる
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        print("----------------------")
        print("pheripheral.name: \(String(describing: peripheral.name))")
        print("advertisementData:\(advertisementData)")
        print("RSSI: \(RSSI)")
        print("peripheral.identifier.uuidString: \(peripheral.identifier.uuidString)")
        print("----------------------")
        
        let kCBAdvDataLocalName = advertisementData["kCBAdvDataLocalName"] as? String
        if kCBAdvDataLocalName == "Otokake_Right" && Int(truncating: RSSI) > -70 {
            print("スキャン停止")
            
            self.targetPeripheral = peripheral
            self.centralManager.connect(self.targetPeripheral, options: nil)
            self.centralManager.stopScan()
            print("接続開始")
    }
    
    /// 接続されると呼ばれる
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        print("接続成功")
        searchService()
    }
    
    /// 切断されると呼ばれる？
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print(#function)
        if error != nil {
            print(error.debugDescription)
            setup() // ペアリングのリトライ
            return
        }
    }
    }
}

//MARK : - CBPeripheralDelegate
extension ReciveViewController: CBPeripheralDelegate {
    /// キャリアクタリスティク発見時に呼ばれる
   /* func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if error != nil {
            print(error.debugDescription)
            return
        }

        print("service.characteristics.count: \(service.characteristics!.count)")
        for characteristics in service.characteristics! {
            if(characteristics.uuid == CBUUID(string: kRXCharacteristicUUID)) {
                self.kRXCBCharacteristic = characteristics
                print("kTXCBCharacteristic did discovered!")
            }
        }
        
        if(self.kRXCBCharacteristic != nil) {
            startReciving()
        }
        print("  - Characteristic didDiscovered")

    }
    
    private func startReciving() {
        guard let kRXCBCharacteristic = kRXCBCharacteristic else {
            return
        }
        peripheral.setNotifyValue(true, for: kRXCBCharacteristic)
        print("Start monitoring the message from Arduino.\n\n")
    }


   //// データ送信時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print(#function)
        if error != nil {
            print(error.debugDescription)
            return
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        print(#function)
    }
    
    /// データ更新時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print(#function)

        if error != nil {
            print(error.debugDescription)
            return
        }
        updateWithData(data: characteristic.value!)
    }*/
    
   /* func setPeripheral(target: CBPeripheral){
        self.targetPeripheral = target
    }
    
    func setCentralManager(manager: CBCentralManager){
        self.centralManager = manager
    }
    
    func searchService(){
        print("searchService")
        self.targetPeripheral.delegate = self
        self.targetPeripheral.discoverServices([serviceUUID])
    }
    
    func searchCharacteristics(service: CBService){
        print("searchCharacteristic")
        self.targetPeripheral.delegate = self
        self.targetPeripheral.discoverCharacteristics([characteristicUUID], for: service)
    }
    
    //service検索後
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let e = error {
            print("ErrorServices: \(e.localizedDescription)")
            return
        }
        
        print("didDiscoverServices")
        print("P: \(String(describing: peripheral.name)) - Discovered service S:'\(peripheral.services![0].uuid)'")
            searchCharacteristics(service: peripheral.services![0])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        print("didDiscoverCharacteristicsForService")
        
        for characteristic in service.characteristics! {
            characteristics.append(characteristic)
            self.targetPeripheral.readValue(for: characteristic)
        }
    }*/
    func startAdvertise(){
        print("startAdvertise")
        let advertisementData = [CBAdvertisementDataLocalNameKey: "~~~pxc~~~"]
        publishservice()
        peripheralManager.startAdvertising(advertisementData)
    }
    
    func stopAdvertise(){
        print("stopAdvertise")
        peripheralManager.stopAdvertising()
    }
    
    /// Read可能か
    func isRead(characteristic: CBCharacteristic) -> Bool{
        if characteristic.properties.contains(.read) {
            return true
        }
        return false
    }
}

