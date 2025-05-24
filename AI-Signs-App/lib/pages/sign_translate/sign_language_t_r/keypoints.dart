class Keypoint {
  final String name;
  final double x;
  final double y;
  final double z;

  Keypoint({required this.name, required this.x, required this.y, required this.z});

  factory Keypoint.fromJson(Map<String, dynamic> json) {
    return Keypoint(
      name: json['name'],
      x: json['x'],
      y: json['y'],
      z: json['z'],
    );
  }
}
