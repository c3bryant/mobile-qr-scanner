import 'package:backtoschool/app_theme.dart';
import 'package:backtoschool/data_provider/user_data_provider.dart';
import 'package:backtoschool/data_provider/scanner_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scandit_plugin/flutter_scandit_plugin.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:backtoschool/navigation/route_paths.dart';

class ScanditScanner extends StatelessWidget {
  ScannerDataProvider _scannerDataProvider;
  UserDataProvider _userDataProvider;
  set userDataProvider(UserDataProvider value) => _userDataProvider = value;

  @override
  Widget build(BuildContext context) {
    _userDataProvider = Provider.of<UserDataProvider>(context);
    _scannerDataProvider = Provider.of<ScannerDataProvider>(context);
    _scannerDataProvider.requestCameraPermissions();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(42),
        child: AppBar(
          centerTitle: true,
          title: const Text("Scanner"),
        ),
      ),
      body: !_scannerDataProvider.hasScanned
          ? renderScanner(context)
          : renderSubmissionView(context),
      floatingActionButton: IconButton(
        onPressed: () {},
        icon: Container(),
      ),
    );
  }

  Widget renderScanner(BuildContext context) {
    if (_scannerDataProvider.cameraPermissionsStatus ==
        PermissionStatus.granted) {
      return (Stack(
        children: [
          Scandit(
              scanned: _scannerDataProvider.verifyBarcodeScanning,
              onError: (e) => (_scannerDataProvider.message = e.message),
              symbologies: [Symbology.CODE128, Symbology.DATA_MATRIX],
              onScanditCreated: (controller) =>
                  _scannerDataProvider.controller = controller,
              licenseKey: _scannerDataProvider.licenseKey),
          Center(
            child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.white),
                )),
          ),
          Center(child: Text(_scannerDataProvider.message)),
        ],
      ));
    } else {
      return (Center(
        child: Text("Please allow camera permissions to scan your test kit."),
      ));
    }
  }

  Widget renderSubmissionView(BuildContext context) {
    if (_scannerDataProvider.isLoading) {
      return (Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: SizedBox(
                height: 40, width: 40, child: CircularProgressIndicator()),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text("Submitting...please wait",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ));
    } else if (_scannerDataProvider.successfulSubmission) {
      return (renderSuccessScreen(context));
    } else if (_scannerDataProvider.didError) {
      return (renderFailureScreen(context));
    } else {
      return (renderFailureScreen(context));
    }
  }

  Widget renderFailureScreen(BuildContext context) {
    return (Column(
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: (Column(children: <Widget>[
              ClipOval(
                child: Container(
                  color: (!_scannerDataProvider.isValidBarcode ||
                          _scannerDataProvider.isDuplicate)
                      ? Colors.orange
                      : Colors.red,
                  height: 75,
                  width: 75,
                  child: Icon(Icons.clear, color: Colors.white, size: 60),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Submission Failed!",
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(_scannerDataProvider.errorText,
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                    "If this issue persists, please contact a healthcare professional.",
                    style: TextStyle(fontSize: 15)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: FlatButton(
                  padding: EdgeInsets.only(left: 32.0, right: 32.0),
                  onPressed: () {
                    _scannerDataProvider.setDefaultStates();
                  },
                  child: Text(
                    "Try again",
                    style: TextStyle(fontSize: 18.0),
                  ),
                  color: lightButtonColor,
                  textColor: Colors.white,
                ),
              ),
            ])),
          ),
        )
      ],
    ));
  }

  void timeout(BuildContext context) async {
    // delay for 5s and then navigate back to login
    // logout
    Timer(Duration(seconds: 5), () {
      _userDataProvider.logout();
      Navigator.pushNamedAndRemoveUntil(
          context, RoutePaths.Home, (route) => false);
    });
  }

  Widget renderSuccessScreen(BuildContext context) {
    final dateFormat = new DateFormat('dd-MM-yyyy hh:mm:ss a');
    final String scanTime = dateFormat.format(new DateTime.now());
    timeout(context);

    return Column(
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: (Column(children: <Widget>[
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Scan Submitted",
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              ),
              Text("Scan sent at: " + scanTime,
                  style: TextStyle(color: Theme.of(context).iconTheme.color)),
              Text("Scanned value: " + _scannerDataProvider.barcode,
                  style: TextStyle(color: Theme.of(context).iconTheme.color)),
            ])),
          ),
        ),
        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                "Next Steps:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            )),
        ListView(
          shrinkWrap: true,
          children: <Widget>[
            ListTile(
                title: Text(String.fromCharCode(0x2022) +
                    " Proceed to the next step in the testing process")),
            ListTile(
                title: Text(String.fromCharCode(0x2022) +
                    " Results are usually available within 24-36 hours.")),
            ListTile(title: buildChartText(context)),
            ListTile(
                title: Text(String.fromCharCode(0x2022) +
                    " If you are experiencing symptoms of COVID-19, stay in your residence and seek guidance from a healthcare provider.")),
            ListTile(
              title: Text(
                  String.fromCharCode(0x2022) +
                      " Help fight COVID-19. Add CA COVID Notify to your phone.",
                  style: TextStyle(
                      color: Colors.blueAccent,
                      decoration: TextDecoration.underline)),
              onTap: () {
                openLink("https://en.ucsd.edu");
              },
            ),
          ],
        ),
      ],
    );
  }

  Text buildChartText(BuildContext context) {
    final studentPattern = RegExp('[BGJMU]');
    final staffPattern = RegExp('[E]');

    if ((_userDataProvider.authenticationModel.ucsdaffiliation ?? "")
        .contains(studentPattern)) {
      // is a student
      return Text(String.fromCharCode(0x2022) +
          " You can view your results by logging in to MyStudentChart.");
    } else if ((_userDataProvider.authenticationModel.ucsdaffiliation ?? "")
        .contains(staffPattern)) {
      // is staff
      return Text(String.fromCharCode(0x2022) +
          " You can view your results by logging in to MyUCSDChart.");
    } else {
      /// is not staff or student
      return Text(String.fromCharCode(0x2022) +
          " You can view your results by logging in to MyUCSDChart.");
    }
  }

  openLink(String url) async {
    try {
      launch(url, forceSafariVC: true);
    } catch (e) {
      // an error occurred, do nothing
    }
  }
}
