import 'package:url_launcher/url_launcher.dart';

class MapUtils {

  MapUtils._();

  static Future<void> openMap(url) async {
    String googleUrl = url;

    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl));
    } else {
      throw 'Could not launch $googleUrl';
    }
    // if (await canLaunch(googleUrl)) {
    //   await launch(googleUrl);
    // } else {
    //   throw 'Could not open the map.';
    // }
  }
  // static Future<void> openMap(double latitude, double longitude,url) async {
  //   String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  //   if (await canLaunch(googleUrl)) {
  //     await launch(googleUrl);
  //   } else {
  //     throw 'Could not open the map.';
  //   }
  // }
}