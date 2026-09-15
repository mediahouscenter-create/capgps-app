/// id : 3
/// name : "oil"
/// value : "Odometer expired"
/// expiring : true

class Services {
  Services({
      num? id, 
      String? name, 
      String? value, 
      bool? expiring,}){
    _id = id;
    _name = name;
    _value = value;
    _expiring = expiring;
}

  Services.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _value = json['value'];
    _expiring = json['expiring'];
  }
  num? _id;
  String? _name;
  String? _value;
  bool? _expiring;
  Services copyWith({  num? id,
  String? name,
  String? value,
  bool? expiring,
}) => Services(  id: id ?? _id,
  name: name ?? _name,
  value: value ?? _value,
  expiring: expiring ?? _expiring,
);
  num? get id => _id;
  String? get name => _name;
  String? get value => _value;
  bool? get expiring => _expiring;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['value'] = _value;
    map['expiring'] = _expiring;
    return map;
  }

}