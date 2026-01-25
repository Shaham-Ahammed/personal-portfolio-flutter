class Experience {
  final String title;
  final String company;
  final String location;
  final String period;
  final String description;
  final List<String> technologies;
  final String? website;

  const Experience({
    required this.title,
    required this.company,
    required this.location,
    required this.period,
    required this.description,
    required this.technologies,
    this.website,
  });

  factory Experience.fromMap(Map<String, dynamic> map) {
    return Experience(
      title: map['title'] as String,
      company: map['company'] as String,
      location: map['location'] as String,
      period: map['period'] as String,
      description: map['description'] as String,
      technologies: List<String>.from(map['technologies'] as List),
      website: map['website'] as String?,
    );
  }
}

