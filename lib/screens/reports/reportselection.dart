import 'dart:async';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:maktrogps/mapconfig/CommonMethod.dart';

import 'ReportEvent.dart';
import 'ReportStop.dart';

class reportselection extends StatefulWidget {
  const reportselection({super.key});

  @override
  _reportselection createState() => _reportselection();
}

class _reportselection extends State<reportselection> {
  int _selectedperiod = 0;

  final List<String> _reportliststr = [
    "Select Report",
    "Events Report",
    "Temprature Report",
    "Fuel Report",
    "Distance Report",
    "Trips Report",
    "Daily Travel Report",
    "Travel Summary Bulk",
    "General information",
    "Drives and stops",
    "Work hours daily"
  ];

  final List<String> _devicesListstr = [];
  String _selectedReport = "Select Report";

  DateTime _selectedFromDate = DateTime.now();
  DateTime _selectedToDate = DateTime.now();

  var selectedToTime = TimeOfDay.fromDateTime(DateTime.now());
  var selectedTripInfoToTime = TimeOfDay.fromDateTime(DateTime.now());
  var selectedFromTime = TimeOfDay.fromDateTime(DateTime.now());
  var selectedFromTimeequel = TimeOfDay.fromDateTime(DateTime.now());
  var selectedTripInfoFromTime = TimeOfDay.fromDateTime(DateTime.now());

  var fromTime = "00:05";
  var fromTripInfoTime = DateFormat("HH:mm:ss").format(DateTime.now());
  var toTime = DateFormat("HH:mm").format(DateTime.now());
  var toTripInfoTime = DateFormat("HH:mm:ss").format(DateTime.now());

  String? _chosenValue = "30 min";

  @override
  void initState() {
    super.initState();
    getdeviesList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getdeviesList() async {
    _devicesListstr.clear();
    for (int i = 0; i < StaticVarMethod.devicelist.length; i++) {
      if (StaticVarMethod.devicelist.elementAt(i).name != null) {
        _devicesListstr.add(StaticVarMethod.devicelist.elementAt(i).name!);
      }
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2563EB), size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Reports".tr,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Card 1: Report, Vehicle & Interval Selection
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Report Type
                  Text(
                    "ReportType".tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.4) : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.assignment_outlined,
                            color: Color(0xFF3B82F6),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownSearch<String>(
                            popupProps: const PopupProps.menu(
                              showSearchBox: true,
                            ),
                            selectedItem: _selectedReport.isNotEmpty ? _selectedReport : "Select Report",
                            items: _reportliststr,
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                hintText: "Sélectionner un rapport".tr,
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                            onChanged: (dynamic value) {
                              if (value != null) {
                                setState(() {
                                  _selectedReport = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Vehicle Selector
                  Text(
                    "Vehicle".tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.4) : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.directions_car_filled_rounded,
                            color: Color(0xFF3B82F6),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownSearch<String>(
                            popupProps: const PopupProps.menu(
                              showSearchBox: true,
                            ),
                            selectedItem: StaticVarMethod.deviceName.isNotEmpty ? StaticVarMethod.deviceName : null,
                            items: _devicesListstr,
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                hintText: "Sélectionner un véhicule".tr,
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                            onChanged: (dynamic value) {
                              if (value != null) {
                                for (int i = 0; i < StaticVarMethod.devicelist.length; i++) {
                                  if (StaticVarMethod.devicelist.elementAt(i).name!.contains(value)) {
                                    StaticVarMethod.deviceId = StaticVarMethod.devicelist.elementAt(i).id.toString();
                                    StaticVarMethod.deviceName = StaticVarMethod.devicelist.elementAt(i).name.toString();
                                    break;
                                  }
                                }
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Interval
                  Text(
                    "Intervalle".tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.4) : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.timer_outlined,
                            color: Color(0xFF3B82F6),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _chosenValue,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                              items: <String>[
                                '1 min',
                                '2 min',
                                '5 min',
                                '10 min',
                                '30 min',
                                '1 Hours',
                                '5 Hours',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                if (value != null) {
                                  setState(() {
                                    _chosenValue = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Card 2: Quick Period Selection
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Périodes prédéfinies".tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildPeriodPill(0, "Last Hours", isDark),
                      const SizedBox(width: 8),
                      _buildPeriodPill(1, "Today", isDark),
                      const SizedBox(width: 8),
                      _buildPeriodPill(2, "Yesterday", isDark),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildPeriodPill(3, "Before 2 days", isDark),
                      const SizedBox(width: 8),
                      _buildPeriodPill(4, "Last 7 days", isDark),
                      const SizedBox(width: 8),
                      _buildPeriodPill(5, "Last Week", isDark),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Card 3: Custom Date & Time Selection
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select Custom Date & Time".tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // From Date & Time Row
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectFromDate(context, setState),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, color: Color(0xFF3B82F6), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    formatReportDate(_selectedFromDate),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _fromTime(context);
                            });
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_rounded, color: Color(0xFF3B82F6), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    (selectedFromTimeequel == selectedFromTime) ? "00:00" : formatReportTime(selectedFromTime),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // To Date & Time Row
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectToDate(context, setState),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, color: Color(0xFF3B82F6), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    formatReportDate(_selectedToDate),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _toTime(context);
                            });
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_rounded, color: Color(0xFF3B82F6), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    formatReportTime(selectedToTime),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  elevation: 4,
                  shadowColor: const Color(0xFF2563EB).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  showReport();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.insert_chart_outlined_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "ShowReport".tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodPill(int periodId, String label, bool isDark) {
    final isSelected = _selectedperiod == periodId;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedperiod = periodId;
            showReport();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 40,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2563EB)
                : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
          ),
          child: Text(
            label.tr,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Future<void> _selectFromDate(BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedFromDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedFromDate) {
      setState(() {
        _selectedFromDate = picked;
      });
    }
  }

  Future<void> _selectToDate(BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedToDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedToDate) {
      setState(() {
        _selectedToDate = picked;
      });
    }
  }

  Future<Null> _fromTime(BuildContext context) async {
    var picked = await showTimePicker(
      context: context,
      initialTime: selectedFromTime,
    );
    if (picked != null && picked != selectedFromTime) {
      setState(() {
        selectedFromTime = picked;
        var hour = selectedFromTime.hour;
        var minute = selectedFromTime.minute;
        if (hour.toString().length == 1 && minute.toString().length == 1) {
          fromTime = "0$hour:0$minute";
        } else if (hour.toString().length == 1) {
          fromTime = "0$hour:$minute";
        } else if (minute.toString().length == 1) {
          fromTime = "$hour:0$minute";
        } else {
          fromTime = "$hour:$minute";
        }
      });
    }
  }

  Future<Null> _toTime(BuildContext context) async {
    var picked = await showTimePicker(
      context: context,
      initialTime: selectedToTime,
    );
    if (picked != null && picked != selectedToTime) {
      setState(() {
        selectedToTime = picked;
        var hour = selectedToTime.hour;
        var minute = selectedToTime.minute;
        if (hour.toString().length == 1 && minute.toString().length == 1) {
          toTime = "0$hour:0$minute";
        } else if (hour.toString().length == 1) {
          toTime = "0$hour:$minute";
        } else if (minute.toString().length == 1) {
          toTime = "$hour:0$minute";
        } else {
          toTime = "$hour:$minute";
        }
      });
    }
  }

  void showReport() {
    String fromDate;
    String toDate;
    String fromTime;
    String toTime;

    DateTime current = DateTime.now();

    String month;
    String day;
    if (current.month < 10) {
      month = "0${current.month}";
    } else {
      month = current.month.toString();
    }

    if (current.day < 10) {
      day = "0${current.day}";
    } else {
      day = current.day.toString();
    }

    if (_selectedperiod == 1) {
      String today;
      int dayCon = current.day + 1;
      if (dayCon <= 10) {
        today = "0$dayCon";
      } else {
        today = dayCon.toString();
      }

      var date = DateTime.parse("${current.year}-$month-$today 00:00:00");
      fromDate = formatDateReport(DateTime.now().toString());
      toDate = formatDateReport(date.toString());
      fromTime = "00:00:00";
      toTime = "00:00:00";

      StaticVarMethod.fromdate = formatDateReport(DateTime.now().toString());
      StaticVarMethod.todate = formatDateReport(date.toString());
      StaticVarMethod.fromtime = "00:00";
      StaticVarMethod.totime = "00:00";
    } else if (_selectedperiod == 2) {
      String yesterday;
      int dayCon = current.day - 1;
      if (current.day <= 10) {
        yesterday = "0$dayCon";
      } else {
        yesterday = dayCon.toString();
      }

      var start = DateTime.parse("${current.year}-$month-$yesterday 00:00:00");
      var end = DateTime.parse("${current.year}-$month-$yesterday 24:00:00");

      fromDate = formatDateReport(start.toString());
      toDate = formatDateReport(end.toString());
      fromTime = "00:00:00";
      toTime = "00:00:00";
      StaticVarMethod.fromdate = formatDateReport(start.toString());
      StaticVarMethod.todate = formatDateReport(end.toString());
      StaticVarMethod.fromtime = "00:00";
      StaticVarMethod.totime = "00:00";
    } else if (_selectedperiod == 3) {
      String sevenDay, currentDayString;
      int dayCon = current.day - current.weekday;
      int currentDay = current.day;
      if (dayCon < 10) {
        sevenDay = "0${dayCon.abs()}";
      } else {
        sevenDay = dayCon.toString();
      }
      if (currentDay < 10) {
        currentDayString = "0$currentDay";
      } else {
        currentDayString = currentDay.toString();
      }

      var start = DateTime.parse("${current.year}-$month-$sevenDay 00:00:00");
      var end = DateTime.parse("${current.year}-$month-$currentDayString 24:00:00");

      fromDate = formatDateReport(start.toString());
      toDate = formatDateReport(end.toString());
      fromTime = "00:00:00";
      toTime = "00:00:00";
      StaticVarMethod.fromdate = formatDateReport(start.toString());
      StaticVarMethod.todate = formatDateReport(end.toString());
      StaticVarMethod.fromtime = "00:00";
      StaticVarMethod.totime = "00:00";
    } else if (_selectedperiod == 4) {
      StaticVarMethod.fromdate = formatDateReport(DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 7)));
      StaticVarMethod.todate = formatDateReport(DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)));
      StaticVarMethod.fromtime = "00:00";
      StaticVarMethod.totime = "11:59";
    } else if (_selectedperiod == 5) {
      StaticVarMethod.fromdate = formatDateReport(DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 14)));
      StaticVarMethod.todate = formatDateReport(DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 7)));
      StaticVarMethod.fromtime = "00:00";
      StaticVarMethod.totime = "11:59";
    } else {
      String startMonth, endMoth;
      if (_selectedFromDate.month < 10) {
        startMonth = "0${_selectedFromDate.month}";
      } else {
        startMonth = _selectedFromDate.month.toString();
      }

      if (_selectedToDate.month < 10) {
        endMoth = "0${_selectedToDate.month}";
      } else {
        endMoth = _selectedToDate.month.toString();
      }

      String startHour, endHour;
      if (selectedFromTime.hour < 10) {
        startHour = "0${selectedFromTime.hour}";
      } else {
        startHour = selectedFromTime.hour.toString();
      }

      String startMin, endMin;
      if (selectedFromTime.minute < 10) {
        startMin = "0${selectedFromTime.minute}";
      } else {
        startMin = selectedFromTime.minute.toString();
      }

      if (selectedToTime.minute < 10) {
        endMin = "0${selectedToTime.minute}";
      } else {
        endMin = selectedToTime.minute.toString();
      }

      if (selectedToTime.hour < 10) {
        endHour = "0${selectedToTime.hour}";
      } else {
        endHour = selectedToTime.hour.toString();
      }

      String startDay, endDay;
      if (_selectedFromDate.day <= 10) {
        if (_selectedFromDate.day == 10) {
          startDay = _selectedFromDate.day.toString();
        } else {
          startDay = "0${_selectedFromDate.day}";
        }
      } else {
        startDay = _selectedFromDate.day.toString();
      }

      if (_selectedToDate.day <= 10) {
        if (_selectedToDate.day == 10) {
          endDay = _selectedToDate.day.toString();
        } else {
          endDay = "0${_selectedToDate.day}";
        }
      } else {
        endDay = _selectedToDate.day.toString();
      }

      var start = DateTime.parse("${_selectedFromDate.year}-$startMonth-$startDay $startHour:$startMin:00");
      var end = DateTime.parse("${_selectedToDate.year}-$endMoth-$endDay $endHour:$endMin:00");

      fromDate = formatDateReport(start.toString());
      toDate = formatDateReport(end.toString());
      fromTime = formatTimeReport(start.toString());
      toTime = formatTimeReport(end.toString());

      StaticVarMethod.fromdate = formatDateReport(start.toString());
      StaticVarMethod.todate = formatDateReport(end.toString());
      StaticVarMethod.fromtime = formatTimeReport(start.toString());
      StaticVarMethod.totime = formatTimeReport(end.toString());
    }

    if (_selectedReport.contains("General information")) {
      StaticVarMethod.reportType = 1;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReportEventPage()),
      );
    } else if (_selectedReport.contains("Trips Report")) {
      StaticVarMethod.reportType = 3;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReportEventPage()),
      );
    } else if (_selectedReport.contains("Drives and stops")) {
      StaticVarMethod.reportType = 3;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReportEventPage()),
      );
    } else if (_selectedReport.contains("Distance Report")) {
      StaticVarMethod.reportType = 4;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReportEventPage()),
      );
    } else if (_selectedReport.contains("Daily Travel Report")) {
      StaticVarMethod.reportType = 48;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReportEventPage()),
      );
    } else if (_selectedReport.contains("Travel Summary Bulk")) {
      StaticVarMethod.reportType = 2;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReportEventPage()),
      );
    } else if (_selectedReport.contains("Task Report")) {
      StaticVarMethod.reportType = 27;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReportEventPage()),
      );
    } else if (_selectedReport.contains("Vehicle History")) {
      StaticVarMethod.reportType = 25;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReportEventPage()),
      );
    } else if (_selectedReport.contains("Traval Summary with Playback Image")) {
      StaticVarMethod.reportType = 43;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReportEventPage()),
      );
    } else if (_selectedReport.contains("Temprature Report")) {
      StaticVarMethod.reportType = 13;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReportEventPage()),
      );
    } else if (_selectedReport.contains("Fuel Report")) {
      StaticVarMethod.reportType = 10;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReportEventPage()),
      );
    } else if (_selectedReport.contains("Events Report")) {
      StaticVarMethod.reportType = 8;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReportEventPage()),
      );
    } else if (_selectedReport.contains("Geofence in/out")) {
      StaticVarMethod.reportType = 7;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReportStopPage()),
      );
    } else if (_selectedReport.contains("Work hours daily")) {
      StaticVarMethod.reportType = 48;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReportEventPage()),
      );
    }
  }
}
