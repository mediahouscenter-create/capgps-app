class Taskmodel {
  Taskmodel({
      num? status, 
      Items? items,}){
    _status = status;
    _items = items;
}

  Taskmodel.fromJson(dynamic json) {
    _status = json['status'];
    _items = json['items'] != null ? Items.fromJson(json['items']) : null;
  }
  num? _status;
  Items? _items;
Taskmodel copyWith({  num? status,
  Items? items,
}) => Taskmodel(  status: status ?? _status,
  items: items ?? _items,
);
  num? get status => _status;
  Items? get items => _items;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    if (_items != null) {
      map['items'] = _items?.toJson();
    }
    return map;
  }

}

class Items {
  Items({
      String? url, 
      num? currentPage, 
      List<Data>? data,}){
    _url = url;
    _currentPage = currentPage;
    _data = data;
}

  Items.fromJson(dynamic json) {
    _url = json['url'];
    _currentPage = json['current_page'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  String? _url;
  num? _currentPage;
  List<Data>? _data;
Items copyWith({  String? url,
  num? currentPage,
  List<Data>? data,
}) => Items(  url: url ?? _url,
  currentPage: currentPage ?? _currentPage,
  data: data ?? _data,
);
  String? get url => _url;
  num? get currentPage => _currentPage;
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['url'] = _url;
    map['current_page'] = _currentPage;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class Data {
  Data({
      num? id, 
      num? deviceId, 
      num? userId, 
      String? title, 
      String? type, 
      dynamic comment, 
      num? priority, 
      num? status, 
      dynamic invoiceNumber, 
      String? pickupAddress, 
      num? pickupAddressLat, 
      num? pickupAddressLng, 
      String? pickupTimeFrom, 
      String? pickupTimeTo, 
      String? deliveryAddress, 
      num? deliveryAddressLat, 
      num? deliveryAddressLng, 
      String? deliveryTimeFrom, 
      String? deliveryTimeTo, 
      String? createdAt, 
      String? updatedAt,}){
    _id = id;
    _deviceId = deviceId;
    _userId = userId;
    _title = title;
    _type = type;
    _comment = comment;
    _priority = priority;
    _status = status;
    _invoiceNumber = invoiceNumber;
    _pickupAddress = pickupAddress;
    _pickupAddressLat = pickupAddressLat;
    _pickupAddressLng = pickupAddressLng;
    _pickupTimeFrom = pickupTimeFrom;
    _pickupTimeTo = pickupTimeTo;
    _deliveryAddress = deliveryAddress;
    _deliveryAddressLat = deliveryAddressLat;
    _deliveryAddressLng = deliveryAddressLng;
    _deliveryTimeFrom = deliveryTimeFrom;
    _deliveryTimeTo = deliveryTimeTo;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _deviceId = json['device_id'];
    _userId = json['user_id'];
    _title = json['title'];
    _type = json['type'];
    _comment = json['comment'];
    _priority = json['priority'];
    _status = json['status'];
    _invoiceNumber = json['invoice_number'];
    _pickupAddress = json['pickup_address'];
    _pickupAddressLat = json['pickup_address_lat'];
    _pickupAddressLng = json['pickup_address_lng'];
    _pickupTimeFrom = json['pickup_time_from'];
    _pickupTimeTo = json['pickup_time_to'];
    _deliveryAddress = json['delivery_address'];
    _deliveryAddressLat = json['delivery_address_lat'];
    _deliveryAddressLng = json['delivery_address_lng'];
    _deliveryTimeFrom = json['delivery_time_from'];
    _deliveryTimeTo = json['delivery_time_to'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  num? _id;
  num? _deviceId;
  num? _userId;
  String? _title;
  String? _type;
  dynamic _comment;
  num? _priority;
  num? _status;
  dynamic _invoiceNumber;
  String? _pickupAddress;
  num? _pickupAddressLat;
  num? _pickupAddressLng;
  String? _pickupTimeFrom;
  String? _pickupTimeTo;
  String? _deliveryAddress;
  num? _deliveryAddressLat;
  num? _deliveryAddressLng;
  String? _deliveryTimeFrom;
  String? _deliveryTimeTo;
  String? _createdAt;
  String? _updatedAt;
Data copyWith({  num? id,
  num? deviceId,
  num? userId,
  String? title,
  String? type,
  dynamic comment,
  num? priority,
  num? status,
  dynamic invoiceNumber,
  String? pickupAddress,
  num? pickupAddressLat,
  num? pickupAddressLng,
  String? pickupTimeFrom,
  String? pickupTimeTo,
  String? deliveryAddress,
  num? deliveryAddressLat,
  num? deliveryAddressLng,
  String? deliveryTimeFrom,
  String? deliveryTimeTo,
  String? createdAt,
  String? updatedAt,
}) => Data(  id: id ?? _id,
  deviceId: deviceId ?? _deviceId,
  userId: userId ?? _userId,
  title: title ?? _title,
  type: type ?? _type,
  comment: comment ?? _comment,
  priority: priority ?? _priority,
  status: status ?? _status,
  invoiceNumber: invoiceNumber ?? _invoiceNumber,
  pickupAddress: pickupAddress ?? _pickupAddress,
  pickupAddressLat: pickupAddressLat ?? _pickupAddressLat,
  pickupAddressLng: pickupAddressLng ?? _pickupAddressLng,
  pickupTimeFrom: pickupTimeFrom ?? _pickupTimeFrom,
  pickupTimeTo: pickupTimeTo ?? _pickupTimeTo,
  deliveryAddress: deliveryAddress ?? _deliveryAddress,
  deliveryAddressLat: deliveryAddressLat ?? _deliveryAddressLat,
  deliveryAddressLng: deliveryAddressLng ?? _deliveryAddressLng,
  deliveryTimeFrom: deliveryTimeFrom ?? _deliveryTimeFrom,
  deliveryTimeTo: deliveryTimeTo ?? _deliveryTimeTo,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
);
  num? get id => _id;
  num? get deviceId => _deviceId;
  num? get userId => _userId;
  String? get title => _title;
  String? get type => _type;
  dynamic get comment => _comment;
  num? get priority => _priority;
  num? get status => _status;
  dynamic get invoiceNumber => _invoiceNumber;
  String? get pickupAddress => _pickupAddress;
  num? get pickupAddressLat => _pickupAddressLat;
  num? get pickupAddressLng => _pickupAddressLng;
  String? get pickupTimeFrom => _pickupTimeFrom;
  String? get pickupTimeTo => _pickupTimeTo;
  String? get deliveryAddress => _deliveryAddress;
  num? get deliveryAddressLat => _deliveryAddressLat;
  num? get deliveryAddressLng => _deliveryAddressLng;
  String? get deliveryTimeFrom => _deliveryTimeFrom;
  String? get deliveryTimeTo => _deliveryTimeTo;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['device_id'] = _deviceId;
    map['user_id'] = _userId;
    map['title'] = _title;
    map['type'] = _type;
    map['comment'] = _comment;
    map['priority'] = _priority;
    map['status'] = _status;
    map['invoice_number'] = _invoiceNumber;
    map['pickup_address'] = _pickupAddress;
    map['pickup_address_lat'] = _pickupAddressLat;
    map['pickup_address_lng'] = _pickupAddressLng;
    map['pickup_time_from'] = _pickupTimeFrom;
    map['pickup_time_to'] = _pickupTimeTo;
    map['delivery_address'] = _deliveryAddress;
    map['delivery_address_lat'] = _deliveryAddressLat;
    map['delivery_address_lng'] = _deliveryAddressLng;
    map['delivery_time_from'] = _deliveryTimeFrom;
    map['delivery_time_to'] = _deliveryTimeTo;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }

}