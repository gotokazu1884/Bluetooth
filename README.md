# Bluetooth
##成果物名

Bluetooth機能

##開発環境

Swift 5.4.2

Xcode12.5.1

##機能

Bluetoothを使って足裏のデバイスから圧力値を受け取り表示する．
https://drive.google.com/file/d/1SGg1N0KJWNfHE8NsMwvXiF_v6DZqrZkg/view?usp=sharing

##開発背景

歩調のテンポと聴いている音楽のテンポを合わせるアプリを開発した際に実装したBluetooth機能です。
Swiftでの開発は未経験であったため１からのスタートだったが無事機能実装をすることができた。

##工夫点・苦労した点

工夫した点は一歩を判別するための圧力値の範囲を実際に靴を履いてテストしたことです。また、受け取った圧力値を別の変数に入れてBPMを割り出す際に扱いやすくしました。

苦労した点はBluetooth機能の実装は一人で担当していたので詰まったときに相談する人がいなくて精神的にもつらかったです。解決策として、大学のBluetoothに詳しい教授や先輩に進んで質問をして、分からないところを自分の中で整理しながら開発を進めていきました。

##注意点

Bluetoothを使うためエミュレータでの実行はできず，実機で行う必要がある．
また，圧力検知にArduinoを用いているためそちらの用意も必要である．
![iOS の画像](https://user-images.githubusercontent.com/87361636/150347933-5d1c9f01-4bb4-4fa6-a60f-cdc14893700d.jpg)

