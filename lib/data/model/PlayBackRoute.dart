class PlayBackRoute extends Object {
  String? show;
  String? left;
  String? device_id;
  String? latitude;
  String? longitude;
  String? course;
  String? raw_time;
  dynamic speed;
  dynamic time;
  dynamic distance;
  dynamic timeSeconds;
  dynamic engineWork;
  dynamic engineIdle;
  dynamic engineHours;
  dynamic fuelConsumption;
  dynamic topSpeed;
  dynamic averageSpeed;


  PlayBackRoute({
    this.show,
    this.left,
    this.device_id,
    this.latitude,
    this.longitude,
    this.course,
    this.raw_time,
    this.speed,
    dynamic time,
    this.distance,
    this.timeSeconds,
    this.engineWork,
    this.engineIdle,
    this.engineHours,
    this.fuelConsumption,
    this.topSpeed,
    this.averageSpeed,
  });

  PlayBackRoute.fromJson(Map<String, dynamic> json) {
    device_id = json["device_id"];
    latitude = json["latitude"];
    longitude = json["longitude"];
    course = json["course"];
    raw_time = json["raw_time"];
    speed = json["speed"];
  }

  Map<String, dynamic> toJson() => {
        'device_id': device_id,
        'latitude': latitude,
        'longitude': longitude,
        'course': course,
        'raw_time': raw_time,
        'speed': speed
      };
}
