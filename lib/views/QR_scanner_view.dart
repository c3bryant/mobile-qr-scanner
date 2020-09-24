import 'package:backtoschool/data_provider/barcode_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            color: Colors.black,
            child: QRView(
              key: qrKey,
              onQRViewCreated:
                  Provider.of<BarcodeDataProvider>(context, listen: false)
                      .onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Color.fromRGBO(54, 216, 113, 1.0),
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 260,
              ),
            ),
          ),
          flex: 1,
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.25,
          color: Color.fromRGBO(236, 236, 236, 1.0),
          padding: EdgeInsets.all(24.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Provider.of<BarcodeDataProvider>(context).qrText.isNotEmpty
                    ? Text(Provider.of<BarcodeDataProvider>(context).qrText,
                        style: TextStyle(fontSize: 32))
                    : Text("Please scan a test kit.",
                        style: TextStyle(fontSize: 32)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(24.0),
                      child: FlatButton(
                        padding: EdgeInsets.all(24.0),
                        disabledTextColor: Colors.black,
                        disabledColor: Color.fromRGBO(218, 218, 218, 1.0),
                        onPressed: Provider.of<BarcodeDataProvider>(context)
                                .qrText
                                .isNotEmpty
                            ? () => Provider.of<BarcodeDataProvider>(context,
                                    listen: false)
                                .submitBarcode()
                            : null,
                        child: Text(
                            Provider.of<BarcodeDataProvider>(context)
                                .submitState,
                            style: TextStyle(fontSize: 32)),
                        color: Theme.of(context).buttonColor,
                        textColor: Theme.of(context).textTheme.button.color,
                      ),
                    ),
                  ],
                ),
              ]),
        ),
      ],
    );
  }

  @override
  void dispose() {
    Provider.of<BarcodeDataProvider>(context).dispose();
    super.dispose();
  }
}
