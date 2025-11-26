class University {
  final String name;
  final String country;
  final List<String> webPages;
  final String?
      stateProvince; // if the university's state/province is available

  University({
    required this.name,
    required this.country,
    required this.webPages,
    this.stateProvince,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      webPages: List<String>.from(json['web_pages'] ?? []),
      stateProvince: json[
          'state-province'], // if the university's state/province is available
    );
  }
}
