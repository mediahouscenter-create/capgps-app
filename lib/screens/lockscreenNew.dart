

import 'dart:async';
import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/model/commandmodel.dart';


import 'package:maktrogps/data/datasources.dart';
import 'package:maktrogps/data/model/devices.dart';
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/global_style.dart';
import '../data/model/Command.dart';


class lockscreenNew extends StatefulWidget {
  @override
  _lockscreenNewState createState() => _lockscreenNewState();
}

class _lockscreenNewState extends State<lockscreenNew> {


  List<Command> commands = [];

  List<String> commandsstr = [];

  String selectedcommands="";
  String selectedcommandsTitle="";
  Timer? _timer;
  var _isLoading = false;



  @override
  void initState() {
    getCommands();
    super.initState();
  }


  void getCommands() {
    _timer = new Timer.periodic(Duration(seconds: 1), (timer) {
      _timer!.cancel();
      Iterable list;
      commandsstr.clear();
      Commandmodel list1;
      gpsapis.getSavedCommands(StaticVarMethod.deviceId).then((value) => {
        if (value?.body != null)
          {



            // gpswox original code
            list = json.decode(value!.body),

/*            print(list.length),
            list.forEach((element) {
              Command command = new Command();
              command.id = element["id"];
              command.value = element["type"];
              command.title = element["title"];
             var attributes= element["attributes"].toString();
              if(element["attributes"].toString() != "null"){
                List data = element["attributes"].toList();
                var locdata= data[0];
                var locdata1= data[0].toString();
                if(locdata1.contains("default")){
                  command.command = locdata["default"].toString();
                  print(command.command );
                  commandsstr.add(command.title!);
                }
                print(locdata);
              }
              commands.add(command);
            }),*/
// gpswox original code end



         // auto track code
            list = json.decode(value!.body),
            list.forEach((element) {
              Command command = new Command();
              command.value = element["type"];
              command.title = element["title"];
              commandsstr.add(command.title!);
              commands.add(command);
            }),
            // auto track code end




            setState(() {
              _isLoading=true;
            })
          }
      });

    });
  }

  void sendCommand(type) async {
    final cmdLower = type.toString().toLowerCase();
    final titleLower = selectedcommandsTitle.toLowerCase();
    
    final isStart = titleLower.contains("desactiver") || titleLower.contains("désactiver") ||
                    titleLower.contains("resume") || titleLower.contains("restaurer") || titleLower.contains("unlock") || titleLower.contains("start") || titleLower.contains("démarrer") ||
                    cmdLower.contains("resume") || cmdLower.contains("restore") || cmdLower.contains("relay,0#");

    final isStop = !isStart && (cmdLower.contains("stop") || cmdLower.contains("cut") || cmdLower.contains("relay,1#") ||
                   titleLower.contains("stop") || titleLower.contains("couper") || titleLower.contains("lock") ||
                   titleLower.contains("activer") || titleLower.contains("blocage"));

    if (isStop || isStart) {
      String sim = StaticVarMethod.simno;
      if (sim.isEmpty) {
        final dev = StaticVarMethod.devicelist.cast<deviceItems?>().firstWhere(
          (d) => d?.id.toString() == StaticVarMethod.deviceId,
          orElse: () => null,
        );
        if (dev != null && dev.deviceData != null) {
          sim = dev.deviceData!.simNumber.toString();
        }
      }
      
      if (sim.isNotEmpty) {
        String smsBody = type;
        if (isStop) {
          smsBody = "cap 2022 setdigout 1";
        } else if (isStart) {
          smsBody = "cap 2022 setdigout 0";
        }

        final String bodyEncoded = Uri.encodeComponent(smsBody);
        String uriString = "sms:$sim?body=$bodyEncoded";
        if (Platform.isIOS) {
          uriString = "sms:$sim&body=$bodyEncoded";
        }

        final Uri smsUri = Uri.parse(uriString);
        
        try {
          if (await canLaunchUrl(smsUri)) {
            await launchUrl(smsUri);
            Fluttertoast.showToast(
                msg: "Redirection vers SMS...",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0);
            return;
          }
        } catch (e) {
          print("Error launching SMS url: $e");
        }
      }
    }

    Map<String, String> requestBody;

    requestBody = <String, String>{
      'id': "",
      'device_id': StaticVarMethod.deviceId,
      'type': type
    };


    try{
      gpsapis.sendCommands(requestBody).then((res) => {
        if (res.statusCode == 200)
          {

            Fluttertoast.showToast(
                msg: "Command Sent Successfully",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0),
            // Navigator.of(context).pop()
          }
        else
          {

            Fluttertoast.showToast(
                msg: "Error",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black54,
                textColor: Colors.white,
                fontSize: 16.0),
            /// Navigator.of(context).pop()
          }
      });
    }catch(ex){
      print(ex);
      print(ex);
      print(ex);
    }

  }




  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.grey[300],
      appBar: AppBar(
        //automaticallyImplyLeading: false,
        elevation: 0,
         iconTheme: IconThemeData(
          color: GlobalStyle.appBarIconThemeColor,
        ),
        systemOverlayStyle: GlobalStyle.appBarSystemOverlayStyle,
        centerTitle: true,
        title: Text('Lock Screen', style: GlobalStyle.appBarTitle),
        backgroundColor: GlobalStyle.appBarBackgroundColor,
        //bottom: _reusableWidget.bottomAppBar(),
      ),
      body: ListView(
        children: [
          _deviceStatus(),
          _createAccountInformation(),
          _buildmoreswitch(),
          //_buildmoreManues(),
          (_isLoading)?commandControls():Center(child: CircularProgressIndicator()),
         // _Commandhistory(),
          //listView(),

        ],
      ),

    );
  }

  Widget _deviceStatus(){
    final double profilePictureSize = MediaQuery.of(context).size.width/4;
    return Container(
        margin: EdgeInsets.all(5),
        //  padding: EdgeInsets.all(10),
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 2,
            color: Colors.white,
            child: Container(
              margin: EdgeInsets.all(5),
              padding: EdgeInsets.only(left: 8,right: 8,top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Device Status', style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold
                        )),
                        SizedBox(
                          height: 8,
                        ),
                        GestureDetector(
                          onTap: (){
                            Fluttertoast.showToast(msg: 'Click account information / user profile', toastLength: Toast.LENGTH_SHORT);
                          },
                          child: Row(
                            children: [
                              /* Text(''+expiration_date, style: TextStyle(
                          fontSize: 14, color: Colors.grey
                      )),
                      SizedBox(
                        width: 8,
                      ),
                      Icon(Icons.chevron_right, size: 20, color: SOFT_GREY)*/
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(''+StaticVarMethod.devicestatus +'   ', style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold,color: StaticVarMethod.devicestatuscolor
                        )),
                        SizedBox(
                          height: 8,
                        ),
                        GestureDetector(
                          onTap: (){
                            Fluttertoast.showToast(msg: 'Click account information / user profile', toastLength: Toast.LENGTH_SHORT);
                          },
                          child: Row(
                            children: [
                              /* Text(''+expiration_date, style: TextStyle(
                          fontSize: 14, color: Colors.grey
                      )),
                      SizedBox(
                        width: 8,
                      ),
                      Icon(Icons.chevron_right, size: 20, color: SOFT_GREY)*/
                            ],
                          ),
                        )
                      ],
                    ),
                  ) ,
                ],
              ),
            )
        )
    );
  }
  Widget _createAccountInformation(){
    final double profilePictureSize = MediaQuery.of(context).size.width/4;
    return Container(
        margin: EdgeInsets.all(5),
        //  padding: EdgeInsets.all(10),
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 2,
            color: Colors.white,
            child: Container(
              margin: EdgeInsets.all(5),
                padding: EdgeInsets.only(left: 8,right: 8,top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(''+StaticVarMethod.deviceName, style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold
                        )),
                        SizedBox(
                          height: 8,
                        ),
                        GestureDetector(
                          onTap: (){
                            Fluttertoast.showToast(msg: 'Click account information / user profile', toastLength: Toast.LENGTH_SHORT);
                          },
                          child: Row(
                            children: [
                              /* Text(''+expiration_date, style: TextStyle(
                          fontSize: 14, color: Colors.grey
                      )),
                      SizedBox(
                        width: 8,
                      ),
                      Icon(Icons.chevron_right, size: 20, color: SOFT_GREY)*/
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(''+StaticVarMethod.imei, style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold
                        )),
                        SizedBox(
                          height: 8,
                        ),
                        GestureDetector(
                          onTap: (){
                            Fluttertoast.showToast(msg: 'Click account information / user profile', toastLength: Toast.LENGTH_SHORT);
                          },
                          child: Row(
                            children: [
                              /* Text(''+expiration_date, style: TextStyle(
                          fontSize: 14, color: Colors.grey
                      )),
                      SizedBox(
                        width: 8,
                      ),
                      Icon(Icons.chevron_right, size: 20, color: SOFT_GREY)*/
                            ],
                          ),
                        )
                      ],
                    ),
                  ) ,
                ],
              ),
            )
        )
    );
  }

  Widget _buildmoreswitch(){
    return Container(
        margin: EdgeInsets.all(10),
        child:     Center(child:
        Text('   Control Vehicle Engine',  style: TextStyle(
            fontSize: 15,height: 1.5,fontWeight: FontWeight.bold)),
        )
    );
  }


  Widget _buildmoreManues(){
    return Container(
        margin: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () async {




                      String lock="RELAY,1#";


                      sendCommand(lock);
                      //_launchURL("www.maktro.com/mgt/pay");
                    },
                    child: Container(
                        padding: EdgeInsets.only(top:15,bottom: 15,left: 10, right: 5),

                        decoration: new BoxDecoration(
                          color: Colors.blueGrey.shade900,
                          shape: BoxShape.rectangle,
                          borderRadius:BorderRadius.all(Radius.circular(30)),
                          // borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              //offset: const Offset(0.0, 10.0),
                            ),
                          ],
                        ),
                        // color: Colors.white,
                        //color: Color(0x99FFFFFF),
                        child:   Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.lock, size: 30, color: Colors.white),
                              SizedBox(
                                width: 10,
                              ),
                            //  Image.asset("assets/settingicon/payment.png", height: 40,width: 40),
                              Text('Lock',  style: TextStyle(
                                  fontSize: 16, color: Colors.white)),


                            ]
                        )
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 25),
            Expanded(
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {

                      String unlock="RELAY,0#";


                      sendCommand(unlock);
                    //  _launchURL("www.maktro.com/mgt/price");
                    },
                    child: Container(
                        padding: EdgeInsets.only(top:15,bottom: 15,left: 10, right: 5),

                        decoration: new BoxDecoration(
                          color: Colors.blueGrey.shade900,
                          shape: BoxShape.rectangle,
                          borderRadius:BorderRadius.all(Radius.circular(30)),
                          // borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              //offset: const Offset(0.0, 10.0),
                            ),
                          ],
                        ),
                        // color: Colors.white,
                        //color: Color(0x99FFFFFF),
                        child:   Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              //Image.asset("assets/settingicon/pricing.png", height: 40,width: 40),
                              Icon(Icons.lock_open, size: 30, color: Colors.white),
                              SizedBox(
                                width: 10,
                              ),
                              Text('Unlock',  style: TextStyle(
                                  fontSize: 16, color: Colors.white)),

                            ]
                        )
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }



  Widget commandControls() {

    return  Container(
      padding: EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 30),

      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                blurRadius: 20,
                offset: Offset.zero,
                color: Colors.grey.withOpacity(0.5))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(top: 10, left: 15, right: 15),
              padding: EdgeInsets.only(left: 10, right: 10),


              child:Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
                //color: Colors.grey.shade900,
                //shadowColor: Colors.pink,
                child: Container(

                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: DropdownSearch(
                      items: commandsstr,
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          // labelText: "Location",
                          hintText: "Select Command",
                        ),
                      ),
                      onChanged: (dynamic value) {

                        for (int i = 0; i < commands.length; i++) {
                          if (value != null) {
                            if (commands.elementAt(i).title!.contains(value)) {
                              String command=commands.elementAt(i).value!.toString();
                              String devicename=commands.elementAt(i).title.toString();
                              // String id=commands.elementAt(i).id.toString();
                              print("value: " + value);

                              setState(() {
                                selectedcommands = command;
                                selectedcommandsTitle = devicename;
                              });
                              break;
                            }
                          }
                        }

                      },
                      // selectedItem: "Tunisia",
                      // validator: (String? item) {
                      //   if (item == null)
                      //     return "Required field";
                      //   else if (item == "Brazil")
                      //     return "Invalid item";
                      //   else
                      //     return null;
                      // },
                    )
                   /*
                    DropdownSearch(
                      mode: Mode.MENU,
                      showSelectedItems: true,
                      items: commandsstr,
                      dropdownSearchDecoration: InputDecoration(
                        //labelText: "Location",
                        hintText: "Select Command",
                      ),
                      onChanged: (dynamic value) {
                        for (int i = 0; i < commands.length; i++) {
                          if (value != null) {
                            if (commands.elementAt(i).title!.contains(value)) {
                             String command=commands.elementAt(i).value!.toString();
                             String devicename=commands.elementAt(i).title.toString();
                            // String id=commands.elementAt(i).id.toString();
                              print("value: " + value);

                              setState(() {
                                selectedcommands = command;
                              });
                              break;
                            }
                          }
                        }


                      },
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        cursorColor: Colors.red,
                      ),

                    )*/
                ),
              )
          ),

          Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              child:ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                onPressed: () {

                  sendCommand(selectedcommands);
                },
                child: Text('Send Command'.tr),
              )),
          //   OutlinedButton.icon(
          //     onPressed: () {
          //       sendCommand(selectedcommands);
          //       // Fluttertoast.showToast(msg: 'Press Outline Button', toastLength: Toast.LENGTH_SHORT);
          //     },
          //     style: ButtonStyle(
          //         overlayColor: MaterialStateProperty.all(Colors.grey),
          //         shape: MaterialStateProperty.all(
          //             RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(26),
          //             )
          //         ),
          //         side: MaterialStateProperty.all(
          //           BorderSide(
          //               color: Colors.grey,
          //               width: 1.0
          //           ),
          //         )
          //     ),
          //     icon: Icon(
          //       Icons.file_copy_outlined,
          //       size: 24.0,color: Colors.grey,
          //     ),
          //     label: Text('Send Commands      ',style: TextStyle(
          //         color: Colors.grey)),
          //   ),
          // ),

        ],
      ),
    );

  }
//   Widget _Commandhistory(){
//     return Container(
//         margin: EdgeInsets.all(10),
//        // child:     Center(
//           child:
//         Text('Command History',  style: TextStyle(
//             fontSize: 17,height: 1.5,fontWeight: FontWeight.bold)),
//      //   )
//     );
//   }
//
//   Widget listView(){
//
//     return   Container(
//       height: MediaQuery.of(context).size.height / 1.5,
//       width: MediaQuery.of(context).size.width,
//       child: _isLoading == true
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//         padding: EdgeInsets.only(bottom: 70),
//           itemCount: commandList.length,
//           itemBuilder: (BuildContext context, int index) {
//             return GestureDetector(
//                 child: listViewItems( index),
//                 onTap: () => onTapped());
//           }),
//     );
//     /*return ListView.builder(itemBuilder:(context,index){
//       return listViewItems(index);
//     },separatorBuilder: (context,index){
//       return Divider(height: 0);
//     }, itemCount: eventList.length);*/
//   }
//
//   onTapped() async {
//     /* Consts.DocId=approvalModel.DocId;
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//           builder: (context) => GetApproval(loginModel: loginModel)),
//     );*/
//   }
//
//
//   Widget listViewItems(int index){
//     return Container(
//         margin: EdgeInsets.fromLTRB(6, 6, 6, 0),
//         child: Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             elevation: 2,
//             color: Colors.white,
//             child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: Container(
//                       margin: EdgeInsets.only(left: 8,right: 5,top: 8,bottom: 15),
//
//                       child: Column(
//                         children: [
//                           //DeleteIcon(index),
//                           message(index),
//                           commandtext(index),
//                           timeAndDate(index),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ]
//             )
//         )
//     );
//   }
//
// /*  Widget listViewItems(int index){
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           prefixIcon(index),
//           Expanded(
//             child: Container(
//               margin: EdgeInsets.only(left: 10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   message(index),
//                   timeAndDate(index),
//                 ],
//               ),
//             ),
//           ),
//           DeleteIcon(index),
//         ],
//       ),
//     );
//   }*/
//
//   Widget prefixIconinfo(){
//     return
//       Container(
//         height: 55,
//         width: 55,
//         margin: EdgeInsets.only(top:15,left: 10),
//         padding: EdgeInsets.all(5),
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.white,
//         ),
//         child: Image.asset("assets/settingicon/aboutus.png", height: 55,width: 55),
//         /* child: Icon(Icons.notifications,
//           size: 25,
//           color:Colors.grey.shade700),*/
//       );
//   }
//
//
//
//   Widget message(int index){
//     double textsize=12;
//     return Container(
//       padding: EdgeInsets.only(right: 1,top: 10,bottom: 5),
//       child: RichText(
//         maxLines: 5,
//         textAlign: TextAlign.left,
//         overflow: TextOverflow.ellipsis,
//         text: TextSpan(
//             text:'Command send On ' +commandList[index].imei.toString() + ' Command Type ('+ commandList[index].commandtype.toString()+')',
//             style: TextStyle(
//               fontSize: textsize,
//               color: Colors.grey.shade700,
//               //fontWeight: FontWeight.bold
//             ),
//             children: [
//               /* TextSpan(
//                 text:eventList[index].message.toString() == "null" ? "" : eventList[index].message.toString(),
//                 style: TextStyle(
//
//                     fontWeight: FontWeight.w400),
//               )*/
//             ]
//         ),
//       ),
//     );
//   }
//
//   Widget commandtext(int index){
//     return Container(
//       //margin: EdgeInsets.only(top: 5),
//       padding: EdgeInsets.only(right: 10,bottom: 2),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(commandList[index].command.toString(),style: TextStyle(
//             fontSize: 11,
//             color: Colors.grey.shade700,
//           ),
//           ),
//
//         ],
//       ),
//     );
//   }
//   Widget timeAndDate(int index){
//     return Container(
//       //margin: EdgeInsets.only(top: 5),
//       padding: EdgeInsets.only(right: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(formatTime(commandList[index].time.toString()),style: TextStyle(
//             fontSize: 11,
//             color: Colors.grey.shade700,
//           ),
//           ),
//           (commandList[index].status!.contains("green"))?
//           Image.asset("assets/images/cmddoubletickgreen.png", height: 20): Image.asset("assets/images/cmddoubletickred.png", height: 20),
//         ],
//       ),
//     );
//   }
//
//




}








