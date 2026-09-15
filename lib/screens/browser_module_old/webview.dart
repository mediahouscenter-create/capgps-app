import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class webview extends StatefulWidget {


  webview({Key? key})
      : super(key: key);

  @override
  _BrowserState createState() => _BrowserState();
}

class _BrowserState extends State<webview> with SingleTickerProviderStateMixin {
  String dashboardName = "";
  String dashboardURL = "";
  String returnUrlVal = "";
  static const primary = Color(0xff0540ac);
 // static const primary = Color(0xffD73034);
  final key = new GlobalKey<ScaffoldState>();


  var _isRestored = false;
  bool status = false;

  @override
  void initState() {
//    status = false;

    super.initState();
  }

  @override
  void dispose() {
    returnUrlVal = "";
    super.dispose();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isRestored) {
      _isRestored = true;

    }
    precacheImage(AssetImage("assets/images/app_icon.png"), context);
  }

  var controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {


        },
        onWebResourceError: (WebResourceError error) {},
        // onNavigationRequest: (NavigationRequest request) {
        //   if (request.url.startsWith('https://login.easy-tracking.com.au/authentication/create')) {
        //     return NavigationDecision.prevent;
        //   }
        //   return NavigationDecision.navigate;
        // },
      ),
    )
    ..loadRequest(Uri.parse('https://login.easy-tracking.com.au/authentication/create'));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        //resizeToAvoidBottomPadding: false,
        appBar:PreferredSize(
            preferredSize: Size.fromHeight(0.0), // here the desired height
            child: AppBar(
             // centerTitle: true,
              // title:  Text('WebView ',
              //   style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              // ),
              //elevation: 0,
              backgroundColor:  Colors.white,

              // ...
            )
        ),
        backgroundColor: Colors.white,
        // body: InAppWebView(
        //   initialUrlRequest: URLRequest(url: Uri.parse("https://login.easy-tracking.com.au/authentication/create")), // updated
        // )
       body: Container(

         padding: EdgeInsets.only(bottom: 80),

           child: WebViewWidget(controller: controller)),
    );
  }

 /* Widget _buildBrowser() {




    return WebView(
      initialUrl: dashboardURL,
      javascriptMode: JavascriptMode.unrestricted,
    );
  }*/






}
