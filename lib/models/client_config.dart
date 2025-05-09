class ClientConfig {
  final String? clientId;
  final String? serverUrl;
  final String? selectedGender;
  
  const ClientConfig({
    this.clientId,
    this.serverUrl,
    this.selectedGender,
  });
  
  factory ClientConfig.fromJson(Map<String, dynamic> json) {
    return ClientConfig(
      clientId: json['clientId'] as String?,
      serverUrl: json['serverUrl'] as String?,
      selectedGender: json['selectedGender'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'serverUrl': serverUrl,
      'selectedGender': selectedGender,
    };
  }
  
  ClientConfig copyWith({
    String? clientId,
    String? serverUrl,
    String? selectedGender,
  }) {
    return ClientConfig(
      clientId: clientId ?? this.clientId,
      serverUrl: serverUrl ?? this.serverUrl,
      selectedGender: selectedGender ?? this.selectedGender,
    );
  }
}