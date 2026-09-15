import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class ReportStopPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ReportStopPageState();
}

class _ReportStopPageState extends State<ReportStopPage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  late StreamController<int> _postsController;
  late Timer _timer;
  bool isLoading = true;
  static var httpClient = new HttpClient();
  late File file;

  @override
  void initState() {
    _postsController = new StreamController();
    getReport();
    super.initState();
  }

  Future<File?> _downloadFile(String? url, String filename) async {
    Random random = new Random();
    int randomNumber = random.nextInt(100);
    print(url);
    if (url != null) {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      String dir = (await getApplicationDocumentsDirectory()).path;
      File pdffile = new File('$dir/$filename-$randomNumber.html');
      //Navigator.pop(context); // Load from assets
      file = pdffile;
      _postsController.add(1);
      await file.writeAsBytes(bytes);
      return file;
    } else {
      isLoading = false;
      _postsController.add(0);
      setState(() {});
    }
  }

  getReport() {
    _timer = new Timer.periodic(Duration(seconds: 1), (timer) {
      timer.cancel();

      gpsapis
          .getReport(StaticVarMethod.deviceId, StaticVarMethod.fromdate,
              StaticVarMethod.todate, StaticVarMethod.reportType)
          .then((value) => {_downloadFile(value?.url, "stop")});
/*        APIService.getReport(
                args.id.toString(), args.fromDate, args.toDate, args.type)
            .then((value) => {_downloadFile(value.url, "stop")});*/
    });
  }

  @override
  Widget build(BuildContext context) {
    //args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
        appBar: AppBar(
          title: Text(StaticVarMethod.deviceName,
              style: TextStyle(color: Colors.black)),
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
        ),
        body: Stack(children: [
          StreamBuilder<int>(
              stream: _postsController.stream,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                if (snapshot.data == 1) {
                  return SfPdfViewer.file(
                    file,
                    key: _pdfViewerKey,
                  );
                } else if (isLoading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.data == 0) {
                  return Center(
                    child: Text('No Data'),
                  );
                } else {
                  return Center(
                    child: Text('No Data'),
                  );
                }
              }),
          Positioned(
            bottom: 20,
            right: 16,
            child: GestureDetector(
              onTap: () async {
                //launchWhatsApp();
                // share();
                shareFile();
              },
              child: Container(
                padding: EdgeInsets.all(6),
                width: 40,
                height: 40,
                decoration: new BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.rectangle,
                  // borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: const Offset(0.0, 10.0),
                    ),
                  ],
                ),
                // color: Colors.white,
                //color: Color(0x99FFFFFF),
                child: Icon(
                  Icons.share,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ]));
  }

  launchWhatsApp() async {
    final link = WhatsAppUnilink(
      phoneNumber: '',
      text:
          "Hey! this is report link please click on this link and open report automatically:  " +
              StaticVarMethod.reporturl,
    );
    await launch('$link');
  }

  Future<void> shareFile() async {
    //Share.shareFiles(['${file.path}'], text: 'Gps Reports');
    // Share.shareXFiles([XFile(file.path)], text: 'Great picture');
    // await WhatsappShare.shareFile(
    //   phone: '911234567890',
    //   filePath: [file.path],
    // );
  }
}
