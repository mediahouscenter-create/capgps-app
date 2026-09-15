import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/Services.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maktrogps/config/size_config.dart';

Future<BitmapDescriptor> getMarkerIconWithInfo(String imagePath, String infoText, TextSpan rightInfoText, Color color, double rotateDegree) async {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);

  //marker size
  /// Modify => Size
  Size markerSize = Size(15 /*/** SizeConfig.heightMultiplier!*/*/, 15 /** SizeConfig.heightMultiplier!*/);

  // Add info text
  TextPainter infoTextPainter = TextPainter(textDirection: TextDirection.ltr, textAlign: TextAlign.center);
  infoTextPainter.text = TextSpan(
    text: infoText,
    style: TextStyle(fontFamily: 'Poppins', fontSize: 3.2 /** SizeConfig.heightMultiplier!*/, fontWeight: FontWeight.w600, color: color),
  );
  infoTextPainter.layout();

  //Add left info text
  // TextPainter rightInfoTextPainter = TextPainter(
  //   textDirection: TextDirection.ltr,
  //   textAlign: TextAlign.center,
  // );
  // rightInfoTextPainter.text = rightInfoText;
  // rightInfoTextPainter.layout();

  final double infoHeight = 5 /** SizeConfig.heightMultiplier!*/;
  final double infoTextWidth =
      (infoText.length * 2 /** SizeConfig.heightMultiplier!*/) > 19 /** SizeConfig.heightMultiplier!*/ ? (infoText.length * 2 /** SizeConfig.heightMultiplier!*/) + 3 : 19 /** SizeConfig.heightMultiplier!*/;
  // final double rightInfoWidth = rightInfoTextPainter.width > infoHeight
  //     ? rightInfoTextPainter.width
  //     : infoHeight;
  final double rightInfoWidth = 0;
  final double infoBorder = 1.3 /** SizeConfig.heightMultiplier!*/;
  final gapBetweenInfoAndMarker = 5 /** SizeConfig.heightMultiplier!*/;

  //canvas size
  Size canvasSize = Size(infoTextWidth + rightInfoWidth + infoBorder + 5, infoHeight + markerSize.height + gapBetweenInfoAndMarker - 20);

  final Paint infoPaint = Paint()..color = Colors.white;
  final Paint rightInfoStrokePaint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  final Paint infoShadowPaint = Paint()
    ..color = Colors.black.withOpacity(.5)
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, gapBetweenInfoAndMarker / 4);
  final Paint infoStrokePaint = Paint()..color = color;

  final Paint markerPaint = Paint()..color = color.withOpacity(.5);
  final double shadowWidth = 2.5 /** SizeConfig.heightMultiplier!*/;

  final Paint borderPaint = Paint()
    ..color = color
    ..strokeWidth = 2.0
    ..style = PaintingStyle.stroke;

  final double imageOffset = shadowWidth * .5;

  canvas.translate(canvasSize.width / 2, canvasSize.height / 2 + infoHeight / 2 + gapBetweenInfoAndMarker / 2);

  // Add shadow circle
  // canvas.drawOval(
  //     Rect.fromLTWH(-markerSize.width / 2, -markerSize.height / 2,
  //         markerSize.width, markerSize.height),
  //     markerPaint);
  // // Add border circle
  // canvas.drawOval(
  //     Rect.fromLTWH(
  //         -markerSize.width / 2 + shadowWidth,
  //         -markerSize.height / 2 + shadowWidth,
  //         markerSize.width - 2 * shadowWidth,
  //         markerSize.height - 2 * shadowWidth),
  //     borderPaint);

  // rect for middle image
  Rect rectMiddle = Rect.fromLTWH(-markerSize.width / 2 + .5 * shadowWidth, -markerSize.height / 2 + .5 * shadowWidth, markerSize.width - shadowWidth, markerSize.height - shadowWidth);

  //save canvas before rotate
  canvas.save();

  double rotateRadian = (pi / 180.0) * rotateDegree;

  //Rotate Image
  canvas.rotate(rotateRadian);

  /*// Add path for middle image
  canvas.clipPath(Path()
    ..addRect(rectMiddle));*/

  // Add image
  ui.Image image = await getImageFromPath(imagePath);
  paintImage(canvas: canvas, image: image, rect: rectMiddle, fit: BoxFit.fitHeight);

  canvas.restore();

  //shadow
  canvas.drawRRect(
      RRect.fromLTRBR(-infoTextWidth / 2 - rightInfoWidth / 2 - infoBorder / 2, -canvasSize.height / 2 - infoHeight / 2 / 4 + 1, infoTextWidth / 2 + rightInfoWidth / 2 + infoBorder / 2,
          -canvasSize.height / 2 + infoHeight / 2 + 1, Radius.circular(1.875 /** SizeConfig.heightMultiplier!*/)),
      infoShadowPaint);
  // Add info box
  canvas.drawRRect(
      RRect.fromLTRBR(-infoTextWidth / 2 - rightInfoWidth / 2 - infoBorder, -canvasSize.height / 2 - infoHeight / 2 - gapBetweenInfoAndMarker / 2 + 1, infoTextWidth / 2 + rightInfoWidth / 2 + infoBorder,
          -canvasSize.height / 2 + infoHeight / 2 + 1, Radius.circular(1.875 /** SizeConfig.heightMultiplier!*/)),
      infoPaint);
  //left info box
  // canvas.drawRRect(
  //     RRect.fromLTRBR(
  //         infoTextWidth / 2 - rightInfoWidth / 2 + infoBorder / 2,
  //         -canvasSize.height / 2 -
  //             infoHeight / 2 -
  //             gapBetweenInfoAndMarker / 2 +
  //             1 +
  //             infoBorder,
  //         infoTextWidth / 2 + rightInfoWidth / 2,
  //         -canvasSize.height / 2 + infoHeight / 2 + 1 - 2 * infoBorder,
  //         Radius.circular(1.875 * SizeConfig.heightMultiplier)),
  //     rightInfoStrokePaint);

  //info text paint
  infoTextPainter.paint(canvas, Offset(-infoTextPainter.width / 2 - rightInfoWidth / 2, -canvasSize.height / 2 - gapBetweenInfoAndMarker / 2 - infoHeight / 2 + infoBorder));

  //left info text paint
  // rightInfoTextPainter.paint(
  //     canvas,
  //     Offset(
  //         infoTextWidth / 2 - rightInfoTextPainter.width / 2 + infoBorder / 4,
  //         -canvasSize.height / 2 -
  //             infoHeight / 2 -
  //             rightInfoTextPainter.height / 4 +
  //             infoBorder / 2));
//rectForMotorImage
  // Rect rectForMotorImage = Rect.fromLTWH(
  //     -12.5 * SizeConfig.heightMultiplier,
  //     -canvasSize.height / 2,
  //     3.125 * SizeConfig.heightMultiplier,
  //     3.125 * SizeConfig.heightMultiplier);

  /*// Add path for Motor image
  canvas.clipPath(Path()
    ..addRect(rectForMotorImage));*/

  // Add motor image
  // ui.Image motorImage = await getImageFromPath('images/motor_.png');
  // paintImage(
  //     canvas: canvas,
  //     image: motorImage,
  //     rect: rectForMotorImage,
  //     fit: BoxFit.fitWidth,
  //     colorFilter: ColorFilter.mode(
  //         isIgnitionOn ? Color(0xFF0C8E44) : Colors.grey, BlendMode.srcATop));

  // //rectForGPSImage
  // Rect rectForGPSImage = Rect.fromLTWH(
  //     -5.625 * SizeConfig.heightMultiplier,
  //     -canvasSize.height / 2,
  //     3.125 * SizeConfig.heightMultiplier,
  //     3.125 * SizeConfig.heightMultiplier);

  // /*// Add path for Motor image
  // canvas.clipPath(Path()
  //   ..addRect(rectForGPSImage));*/

  // // Add gps image
  // ui.Image gpsImage = await getImageFromPath('images/gps.png');
  // paintImage(
  //     canvas: canvas,
  //     image: gpsImage,
  //     rect: rectForGPSImage,
  //     fit: BoxFit.fitHeight,
  //     colorFilter: ColorFilter.mode(
  //         isGpsOn ? Color(0xFF0C8E44) : Colors.grey, BlendMode.srcATop));

  // //rectForWifiImage
  // Rect rectForWifiImage = Rect.fromLTWH(
  //     1.25 * SizeConfig.heightMultiplier,
  //     -canvasSize.height / 2,
  //     3.125 * SizeConfig.heightMultiplier,
  //     3.125 * SizeConfig.heightMultiplier);

  /*// Add path for wifi image
  canvas.clipPath(Path()
    ..addRect(rectForWifiImage));*/

  // Add wifi image
  // ui.Image wifiImage = await getImageFromPath('images/wifi_.png');
  // paintImage(
  //     canvas: canvas,
  //     image: wifiImage,
  //     rect: rectForWifiImage,
  //     fit: BoxFit.fitWidth,
  //     colorFilter: ColorFilter.mode(
  //         isWifiOn ? Color(0xFF0C8E44) : Colors.grey, BlendMode.srcATop));

  canvas.restore();

  // Convert canvas to image
  final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(canvasSize.width.toInt(), canvasSize.height.toInt());

  // Convert image to bytes
  final ByteData? byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List uint8List = byteData!.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(uint8List);
}

Future<BitmapDescriptor> getMarkerIcon(String imagePath, double rotateDegree) async {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);

  Size markerSize = Size(13 /** SizeConfig.heightMultiplier!*/, 13 /** SizeConfig.heightMultiplier!*/);
  final double shadowWidth = 30.0;

  canvas.translate(markerSize.width / 2, markerSize.height / 2);

  // rect for middle image
  Rect rectMiddle = Rect.fromLTWH(
    -markerSize.width / 2 + .5 * shadowWidth,
    -markerSize.height / 2 + .5 * shadowWidth,
    markerSize.width - shadowWidth,
    markerSize.height - shadowWidth,
  );

  //save canvas before rotate
  canvas.save();

  double rotateRadian = (pi / 180.0) * rotateDegree;

  //Rotate Image
  canvas.rotate(rotateRadian);

  /*// Add path for middle image
  canvas.clipPath(Path()
    ..addRect(rectMiddle));*/

  // Add image
  ui.Image image = await getImageFromPath(imagePath);
  paintImage(canvas: canvas, image: image, rect: rectMiddle, fit: BoxFit.fitHeight);

  canvas.restore();

  // Convert canvas to image
  final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(markerSize.width.toInt(), markerSize.height.toInt());

  // Convert image to bytes
  final ByteData? byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List uint8List = byteData!.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(uint8List);
}

Future<ui.Image> getImageFromPath(String imagePath) async {
  //File imageFile = File(imagePath);
  var bd = await rootBundle.load(imagePath);
  Uint8List imageBytes = Uint8List.view(bd.buffer);

  final Completer<ui.Image> completer = new Completer();

  ui.decodeImageFromList(imageBytes, (ui.Image img) {
    return completer.complete(img);
  });

  return completer.future;
}

//custom icon from image

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
}
