/// id : 645
/// user_id : 16888
/// group_id : 0
/// active : 1
/// name : "ParkingFence{524271} FDZ-6290\t"
/// coordinates : "[]"
/// polygon_color : "#c191c4"
/// created_at : "2024-07-30 10:21:03"
/// updated_at : "2024-07-30 10:21:03"
/// type : "circle"
/// radius : 50
/// center : {"lat":"31.703619","lng":"74.011864"}
/// device_id : null

class Gefanceparkmodel {
  Gefanceparkmodel({
      num? id, 
      num? userId, 
      num? groupId, 
      num? active, 
      String? name, 
      String? coordinates, 
      String? polygonColor, 
      String? createdAt, 
      String? updatedAt, 
      String? type, 
      num? radius, 
      Centerpark? center,
      dynamic deviceId,}){
    _id = id;
    _userId = userId;
    _groupId = groupId;
    _active = active;
    _name = name;
    _coordinates = coordinates;
    _polygonColor = polygonColor;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _type = type;
    _radius = radius;
    _center = center;
    _deviceId = deviceId;
}

  Gefanceparkmodel.fromJson(dynamic json) {
    _id = json['id'];
    _userId = json['user_id'];
    _groupId = json['group_id'];
    _active = json['active'];
    _name = json['name'];
    _coordinates = json['coordinates'];
    _polygonColor = json['polygon_color'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _type = json['type'];
    _radius = json['radius'];
    _center = json['center'] != null ? Centerpark.fromJson(json['center']) : null;
    _deviceId = json['device_id'];
  }
  num? _id;
  num? _userId;
  num? _groupId;
  num? _active;
  String? _name;
  String? _coordinates;
  String? _polygonColor;
  String? _createdAt;
  String? _updatedAt;
  String? _type;
  num? _radius;
  Centerpark? _center;
  dynamic _deviceId;
Gefanceparkmodel copyWith({  num? id,
  num? userId,
  num? groupId,
  num? active,
  String? name,
  String? coordinates,
  String? polygonColor,
  String? createdAt,
  String? updatedAt,
  String? type,
  num? radius,
  Centerpark? center,
  dynamic deviceId,
}) => Gefanceparkmodel(  id: id ?? _id,
  userId: userId ?? _userId,
  groupId: groupId ?? _groupId,
  active: active ?? _active,
  name: name ?? _name,
  coordinates: coordinates ?? _coordinates,
  polygonColor: polygonColor ?? _polygonColor,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
  type: type ?? _type,
  radius: radius ?? _radius,
  center: center ?? _center,
  deviceId: deviceId ?? _deviceId,
);
  num? get id => _id;
  num? get userId => _userId;
  num? get groupId => _groupId;
  num? get active => _active;
  String? get name => _name;
  String? get coordinates => _coordinates;
  String? get polygonColor => _polygonColor;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  String? get type => _type;
  num? get radius => _radius;
  Centerpark? get center => _center;
  dynamic get deviceId => _deviceId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['user_id'] = _userId;
    map['group_id'] = _groupId;
    map['active'] = _active;
    map['name'] = _name;
    map['coordinates'] = _coordinates;
    map['polygon_color'] = _polygonColor;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    map['type'] = _type;
    map['radius'] = _radius;
    if (_center != null) {
      map['center'] = _center?.toJson();
    }
    map['device_id'] = _deviceId;
    return map;
  }

}

/// lat : "31.703619"
/// lng : "74.011864"

class Centerpark {
  Centerpark({
      String? lat, 
      String? lng,}){
    _lat = lat;
    _lng = lng;
}

  Centerpark.fromJson(dynamic json) {
    _lat = json['lat'];
    _lng = json['lng'];
  }
  String? _lat;
  String? _lng;
  Centerpark copyWith({  String? lat,
  String? lng,
}) => Centerpark(  lat: lat ?? _lat,
  lng: lng ?? _lng,
);
  String? get lat => _lat;
  String? get lng => _lng;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['lat'] = _lat;
    map['lng'] = _lng;
    return map;
  }

}