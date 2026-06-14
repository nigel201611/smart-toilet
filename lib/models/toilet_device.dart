class ToiletDevice {
  final String id;
  final String name;
  final String mqttTopic;
  bool isOnline;
  int seatTemperature;
  int waterTemperature;
  int ambientTemperature;
  bool isOccupied;
  bool isFlushing;
  bool nightLight;
  bool deodorizer;
  DateTime lastSeen;

  ToiletDevice({
    required this.id,
    required this.name,
    required this.mqttTopic,
    this.isOnline = false,
    this.seatTemperature = 25,
    this.waterTemperature = 30,
    this.ambientTemperature = 20,
    this.isOccupied = false,
    this.isFlushing = false,
    this.nightLight = false,
    this.deodorizer = false,
    DateTime? lastSeen,
  }) : lastSeen = lastSeen ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'mqttTopic': mqttTopic,
    'isOnline': isOnline,
    'seatTemperature': seatTemperature,
    'waterTemperature': waterTemperature,
    'ambientTemperature': ambientTemperature,
    'isOccupied': isOccupied,
    'nightLight': nightLight,
    'deodorizer': deodorizer,
  };

  factory ToiletDevice.fromJson(Map<String, dynamic> json) => ToiletDevice(
    id: json['id'] as String,
    name: json['name'] as String,
    mqttTopic: json['mqttTopic'] as String,
    isOnline: json['isOnline'] as bool? ?? false,
    seatTemperature: json['seatTemperature'] as int? ?? 25,
    waterTemperature: json['waterTemperature'] as int? ?? 30,
    ambientTemperature: json['ambientTemperature'] as int? ?? 20,
    isOccupied: json['isOccupied'] as bool? ?? false,
    nightLight: json['nightLight'] as bool? ?? false,
    deodorizer: json['deodorizer'] as bool? ?? false,
  );
}
