import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import 'package:smart_waste_web/screens/login_screen.dart';
import 'package:smart_waste_web/screens/tabs/items_tab.dart';
import 'package:smart_waste_web/screens/tabs/records_tab.dart';

import '../utlis/colors.dart';
import '../widgets/text_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool inrecords = true;
  bool initems = false;

  bool inqrcode = false;
  bool intickets = false;

  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  String? code;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Card(
              child: SizedBox(
                width: 300,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      child: Image.asset(
                        'assets/images/logos.png',
                        height: 200,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 90.0),
                      child: TextWidget(
                        text: 'Administrator',
                        fontFamily: 'Bold',
                        fontSize: 16,
                        color: Colors.black, // Adjust color as needed
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildMenuTile('Logs', inrecords, () {
                      setState(() {
                        inrecords = true;
                        initems = false;
                        inqrcode = false;
                        intickets = false;
                      });
                    }),
                    const SizedBox(height: 20),
                    _buildMenuTile('Items', initems, () {
                      setState(() {
                        inrecords = false;
                        initems = true;
                        inqrcode = false;
                        intickets = false;
                      });
                    }),
                    const SizedBox(height: 20),
                    _buildMenuTile('QR Code', inqrcode, () async {
                      _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
                        context: context,
                        onCode: (code) async {
                          await FirebaseFirestore.instance
                              .collection('Records')
                              .doc(code!.split('= ')[1])
                              .get()
                              .then((DocumentSnapshot documentSnapshot) async {
                            print('My code ${code.split('= ')[1]}');
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return AlertDialog(
                                  content: TextWidget(
                                    text: 'QR Code Scanned Successfully!',
                                    fontSize: 48,
                                    fontFamily: 'Bold',
                                  ),
                                  actions: <Widget>[
                                    MaterialButton(
                                      onPressed: () async {
                                        showReceipt(documentSnapshot.data());
                                      },
                                      child: const Text(
                                        'Generate Receipt',
                                        style: TextStyle(
                                            fontFamily: 'QRegular',
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          }).catchError((error) {
                            print('Error fetching data: $error');
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 20),
                    ListTile(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text(
                              'Logout Confirmation',
                              style: TextStyle(
                                  fontFamily: 'QBold',
                                  fontWeight: FontWeight.bold),
                            ),
                            content: const Text(
                              'Are you sure you want to Logout?',
                              style: TextStyle(fontFamily: 'QRegular'),
                            ),
                            actions: <Widget>[
                              MaterialButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text(
                                  'Close',
                                  style: TextStyle(
                                      fontFamily: 'QRegular',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              MaterialButton(
                                onPressed: () async {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Continue',
                                  style: TextStyle(
                                      fontFamily: 'QRegular',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      title: TextWidget(
                        text: 'Logout',
                        fontSize: 18,
                        color: Colors.grey,
                        fontFamily: 'Bold',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 50),
                      Align(
                        alignment: Alignment.topRight,
                        child: TextWidget(
                          text: DateFormat('MMMM dd, yyyy | hh:mm a')
                              .format(DateTime.now()),
                          fontSize: 14,
                          fontFamily: 'Bold',
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: inrecords ? const RecordsTab() : const ItemsTab(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListTile _buildMenuTile(String text, bool selected, VoidCallback onTap) {
    return ListTile(
      tileColor: selected ? primary : Colors.transparent,
      onTap: onTap,
      title: TextWidget(
        text: text,
        fontSize: 18,
        color: selected ? Colors.white : Colors.grey,
        fontFamily: 'Bold',
      ),
    );
  }

  showReceipt(data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextWidget(
                  text: 'User name: ${data['myname']}',
                  fontSize: 18,
                ),
                TextWidget(
                  text: 'Item name: ${data['name']}',
                  fontSize: 18,
                ),
                TextWidget(
                  text: 'Equivalent Points: ${data['pts']} pts',
                  fontSize: 18,
                ),
                TextWidget(
                  text:
                      'Date and Time: ${DateFormat.yMMMd().add_jm().format(data['dateTime'].toDate())}',
                  fontSize: 18,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            MaterialButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              child: const Text(
                'Close',
                style: TextStyle(
                    fontFamily: 'QRegular', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
