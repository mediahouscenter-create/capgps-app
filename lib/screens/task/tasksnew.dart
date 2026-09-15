
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/model/Taskmodel.dart';
import 'package:maktrogps/data/datasources.dart';

class tasksnew extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _tasksState();
}

class _tasksState extends State<tasksnew> {


  TextEditingController invoice_number = TextEditingController();
  TextEditingController title = TextEditingController();
  TextEditingController priority = TextEditingController();
  TextEditingController status = TextEditingController();
  TextEditingController comment = TextEditingController();

  TextEditingController pickup_address = TextEditingController();
  TextEditingController pickup_address_lat = TextEditingController();
  TextEditingController pickup_address_lng = TextEditingController();
  TextEditingController pickup_time_from = TextEditingController();
  TextEditingController pickup_time_to = TextEditingController();
  TextEditingController delivery_address = TextEditingController();
  TextEditingController delivery_address_lat = TextEditingController();
  TextEditingController delivery_address_lng = TextEditingController();
  TextEditingController delivery_time_from = TextEditingController();
  TextEditingController delivery_time_to = TextEditingController();
  //String? type="Business";
  int deviceId=0;
  List<String> _devicesListstr=[];
  String? _chosenValue1;

  List<Data> taskList = [];
  @override
  initState() {
    super.initState();
    getdeviesList();
    gettaskList();
  }

  Future<void> getdeviesList() async {
    _devicesListstr.clear();
    for (int i = 0; i < StaticVarMethod.devicelist.length; i++) {
      _devicesListstr.add(StaticVarMethod.devicelist.elementAt(i).name!);
    }
    setState(() {
    });
  }
  Future<void> gettaskList() async {
    print("notificationlist");
    taskList = [];
    try {
      var list = await gpsapis.getTasks(StaticVarMethod.user_api_hash);

      for (var i = 0; i < list.items!.data!.length; i++) {
        taskList.add(list.items!.data![i]);
        print(list.items!.data![i].title);
        print(list.items!.data![i].comment);
        print(list.items!.data![i].pickupAddress);
        print(list.items!.data![i].deliveryAddress);
      }
      setState(() {});
    }
    catch (e) {
     // Fluttertoast.showToast(msg: 'Not exist', toastLength: Toast.LENGTH_SHORT);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Tasks"),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.home_filled),
                text: "New Task",
              ),
              Tab(
                icon: Icon(Icons.account_box_outlined),
                text: "All Tasks",
              ),
              // Tab(
              //   icon: Icon(Icons.alarm),
              //   text: "Alarm",
              // ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Container(
              child: ListView(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 20, left: 15, right: 15),
                    padding: EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: Colors.white,
                      // border: Border(
                      //     bottom: BorderSide(
                      //       color: Colors.transparent,
                      //       width: 1.0,
                      //     )
                      // ),
                    ),
                    child:Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                        //color: Colors.grey.shade900,
                        //shadowColor: Colors.pink,
                        child: Container(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child:
                            DropdownSearch(
                              items: _devicesListstr,
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  // labelText: "Location",
                                  hintText: "Select Car",
                                ),
                              ),
                              onChanged: (dynamic value) {

                                    for (int i = 0; i < StaticVarMethod.devicelist.length; i++) {
                                      if (value != null) {
                                        if (StaticVarMethod.devicelist.elementAt(i).name!.contains(value)) {
                                          deviceId=StaticVarMethod.devicelist.elementAt(i).id;
                                          print("value: " + value);
                                          break;
                                        }
                                      }
                                    }
                                    setState(() {
                                      //_selectedReport = value;
                                    });


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

                            // DropdownSearch(
                            //   mode: Mode.MENU,
                            //   showSelectedItems: true,
                            //   items: _devicesListstr,
                            //   dropdownSearchDecoration: InputDecoration(
                            //     //labelText: "Location",
                            //     hintText: "Select Vehicle",
                            //   ),
                            //   onChanged: (dynamic value) {
                            //     for (int i = 0; i < StaticVarMethod.devicelist.length; i++) {
                            //       if (value != null) {
                            //         if (StaticVarMethod.devicelist.elementAt(i).name!.contains(value)) {
                            //           deviceId=StaticVarMethod.devicelist.elementAt(i).id;
                            //           print("value: " + value);
                            //           break;
                            //         }
                            //       }
                            //     }
                            //     setState(() {
                            //       //_selectedReport = value;
                            //     });
                            //
                            //   },
                            //   showSearchBox: true,
                            //   searchFieldProps: TextFieldProps(
                            //     cursorColor: Colors.red,
                            //   ),
                            //
                            // )
                        )),
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child:TextField(
                        controller: title,
                        onChanged: (String value) {
                        },

                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade500)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade500),
                          ),
                          labelText: 'Name',
                          labelStyle: TextStyle(color: Colors.grey[500]),
                        ),
                      )
                  ),

                  // Container(
                  //     margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                  //     padding: EdgeInsets.only(left: 10, right: 10),
                  //     child:TextField(
                  //       controller: comment,
                  //       onChanged: (String value) {
                  //       },
                  //
                  //       decoration: InputDecoration(
                  //         focusedBorder: UnderlineInputBorder(
                  //             borderSide: BorderSide(color: Colors.grey.shade500)),
                  //         enabledBorder: UnderlineInputBorder(
                  //           borderSide: BorderSide(color: Colors.grey.shade500),
                  //         ),
                  //         labelText: 'Comment',
                  //         labelStyle: TextStyle(color: Colors.grey[500]),
                  //       ),
                  //     )
                  // ),

                  Container(
                      margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child:TextField(
                        controller: pickup_address,
                        onChanged: (String value) {
                        },

                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade500)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade500),
                          ),
                          labelText: 'Pickup Address',
                          labelStyle: TextStyle(color: Colors.grey[500]),
                        ),
                      )
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child:TextField(
                        controller: delivery_address,
                        onChanged: (String value) {
                        },

                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade500)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade500),
                          ),
                          labelText: 'Delivery Address ',
                          labelStyle: TextStyle(color: Colors.grey[500]),
                        ),
                      )
                  ),
                  // Container(
                  //     margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                  //     padding: EdgeInsets.only(left: 10, right: 10),
                  //     child:TextField(
                  //       controller: _pickupaddresslngFieldController,
                  //       onChanged: (String value) {
                  //       },
                  //
                  //       decoration: InputDecoration(
                  //         focusedBorder: UnderlineInputBorder(
                  //             borderSide: BorderSide(color: Colors.grey.shade500)),
                  //         enabledBorder: UnderlineInputBorder(
                  //           borderSide: BorderSide(color: Colors.grey.shade500),
                  //         ),
                  //         labelText: 'Pickup Address lng',
                  //         labelStyle: TextStyle(color: Colors.grey[500]),
                  //       ),
                  //     )
                  // ),
                  Container(
                    margin: EdgeInsets.only(top: 20, left: 15, right: 15),
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: TextFormField(
                        readOnly: false,
                        style: TextStyle(color: Colors.black),
                        keyboardType: TextInputType.multiline,
                        maxLines: 6,
                        controller: comment,
                        decoration: InputDecoration(
                            isDense: true,
                            labelText: "Comment",
                            border: OutlineInputBorder()),
                        onChanged: (val) {
                          if (val.isNotEmpty) {
                          //  itemsrRemarks = val;
                          } else {
                           // itemsrRemarks = "";
                          }
                        }),
                  ),
                  Container(

                    margin: EdgeInsets.only(top: 20, left: 15, right: 15),
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: ElevatedButton(

                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                          textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      // color: CustomColor.primaryColor,
                      onPressed: () {

                        _savetask();

                      },
                      child: Text("Save",
                          style: TextStyle(
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: listView()
            ),
            // Center(
            //   child: Icon(Icons.alarm),
            // )
          ],
        ),
      ),
    );
  }

  Widget listView(){

    return ListView.builder(
        itemCount: taskList.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
              child: listViewItems( index),
             // onTap: () => onTapped()
          );
        });
  }
  Widget listViewItems(int index){
    return
      GestureDetector(
          onTap: (){
          },
          child:
          Container(
              margin: EdgeInsets.fromLTRB(6, 6, 6, 0),
              child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  color: Colors.white,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //prefix
                        Container(
                          height: 45,
                          width: 45,
                          margin: EdgeInsets.only(top:15,left: 10),
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Image.asset("assets/icon/truck-icon.png", height: 55,width: 55),

                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 8,right: 30,top: 8,bottom: 15),

                            child: Column(
                              children: [
                                //DeleteIcon(index),
                                Container(
                                  padding: EdgeInsets.only(right: 1,top: 10,bottom: 5),
                                  child: RichText(
                                    maxLines: 5,
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                        text:' ' +taskList[index].title.toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.bold
                                        ),
                                        children: [
                                          // TextSpan(
                                          //   text:taskList[index].pickupAddress.toString(),
                                          //   style: TextStyle(
                                          //
                                          //       fontWeight: FontWeight.w400),
                                          // )
                                        ]
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(right: 1,top: 10,bottom: 5),
                                  child: RichText(
                                    maxLines: 5,
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                        text:'Pick Up Address: ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.bold
                                        ),
                                        children: [
                                          TextSpan(
                                            text:taskList[index].pickupAddress.toString(),
                                            style: TextStyle(

                                                fontWeight: FontWeight.w400),
                                          )
                                        ]
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(right: 1,top: 10,bottom: 5),
                                  child: RichText(
                                    maxLines: 5,
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                        text:'Delivery  Address: ',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.bold
                                        ),
                                        children: [
                                          TextSpan(
                                            text:taskList[index].deliveryAddress.toString(),
                                            style: TextStyle(

                                                fontWeight: FontWeight.w400),
                                          )
                                        ]
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(right: 1,top: 10,bottom: 5),
                                  child: RichText(
                                    maxLines: 5,
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                        text:'Comments: ',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.bold
                                        ),
                                        children: [
                                          TextSpan(
                                            text:taskList[index].comment.toString(),
                                            style: TextStyle(

                                                fontWeight: FontWeight.w400),
                                          )
                                        ]
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]
                  )
              )
          )
      );
  }
  void _savetask() async {

    try {

      // Response result = await gpsapis.AddTask(
      //     _titleFieldController.text, _commentFieldController.text,_pickupaddressFieldController.text,_pickupaddresslatFieldController.text,_pickupaddresslngFieldController.text);

      String result = await gpsapis.AddTaskNew(deviceId, title.text, comment.text,pickup_address.text,delivery_address.text);
print(result);

      Fluttertoast.showToast(msg: 'Task Added Successful', toastLength: Toast.LENGTH_SHORT);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Task Added Successful'),
      //     backgroundColor: Colors.green,
      //   ),
      // );
      gettaskList();


    } catch (e) {
      Fluttertoast.showToast(msg: 'Error Occured', toastLength: Toast.LENGTH_SHORT);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Task Added Successful'),
      //     backgroundColor: Colors.green,
      //   ),
      // );
      // Navigator.pop(context);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Something went wrong'),
      //     backgroundColor: Colors.red,
      //   ),
      // );
    }
  }
}