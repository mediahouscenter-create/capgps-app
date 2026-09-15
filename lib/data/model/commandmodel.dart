class Commandmodel {
  Commandmodel({
      dynamic type,
      dynamic title,
      List<Attributes>? attributes,}){
    _type = type;
    _title = title;
    _attributes = attributes;
}

  Commandmodel.fromJson(dynamic json) {
    _type = json['type'];
    _title = json['title'];
    if (json['attributes'] != null) {
      _attributes = [];
      json['attributes'].forEach((v) {
        _attributes?.add(Attributes.fromJson(v));
      });
    }
  }
  dynamic _type;
  dynamic _title;
  List<Attributes>? _attributes;
Commandmodel copyWith({  dynamic type,
  dynamic title,
  List<Attributes>? attributes,
}) => Commandmodel(  type: type ?? _type,
  title: title ?? _title,
  attributes: attributes ?? _attributes,
);
  dynamic get type => _type;
  dynamic get title => _title;
  List<Attributes>? get attributes => _attributes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['type'] = _type;
    map['title'] = _title;
    if (_attributes != null) {
      map['attributes'] = _attributes?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class Attributes {
  Attributes({
      dynamic title,
      dynamic name,
      dynamic type,
      dynamic description,
      dynamic default1,}){
    _title = title;
    _name = name;
    _type = type;
    _description = description;
    _default = default1;
}

  Attributes.fromJson(dynamic json) {
    _title = json['title'];
    _name = json['name'];
    _type = json['type'];
    _description = json['description'];
    _default = json['default'];
  }
  dynamic _title;
  dynamic _name;
  dynamic _type;
  dynamic _description;
  dynamic _default;
Attributes copyWith({  dynamic title,
  dynamic name,
  dynamic type,
  dynamic description,
  dynamic default1,
}) => Attributes(  title: title ?? _title,
  name: name ?? _name,
  type: type ?? _type,
  description: description ?? _description,
  default1: default1 ?? _default,
);
  dynamic get title => _title;
  dynamic get name => _name;
  dynamic get type => _type;
  dynamic get description => _description;
  dynamic get default1 => _default;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['title'] = _title;
    map['name'] = _name;
    map['type'] = _type;
    map['description'] = _description;
    map['default'] = _default;
    return map;
  }

}