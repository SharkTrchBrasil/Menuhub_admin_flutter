enum PrinterType { bluetooth, desktop }

class PrinterConfig {
  final String identifier; // MAC Address (Bluetooth) ou Nome (Desktop)
  final String displayName;
  final PrinterType type;

  PrinterConfig({
    required this.identifier,
    required this.displayName,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'identifier': identifier,
    'displayName': displayName,
    'type': type.name,
  };

  factory PrinterConfig.fromJson(Map<String, dynamic> json) {
    return PrinterConfig(
      identifier: json['identifier'],
      displayName: json['displayName'] ?? json['identifier'],
      type: PrinterType.values.firstWhere((e) => e.name == json['type']),
    );
  }
}