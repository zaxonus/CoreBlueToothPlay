# CoreBlueToothPlay
A very simple example to get started with iOS CoreBluetooth.

I decided to create this repository to help people who like me wanted to get started with iOS CoreBluetooth.
I have spent the past two days to create a very simple case of two devices communicating using CoreBluetooth.

Now that it is working, I hope that the code will be useful to other people trying to find their way too.

There are two applications, one (peripheral) implements a CBPeripheralManager object and delivers data.
The other one (central) implements a CBCentralManager object and gets data from the peripheral.

To experiment, take the two apps, install them on two different devices and run them.
Then you can play by taping the unique button (Beep !!) on the peripheral, it will generate random numbers and you should see the same random number displayed on the central as well.

For your information I have been using:
- Xcode 10.1.
- iOS 12.1.2 and 12.1.1
- Swift 4.2
