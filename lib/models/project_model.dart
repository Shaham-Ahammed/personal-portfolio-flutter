enum ProjectType { main, mini }

class Project {
  final String title;
  final String description;
  final List<String> technologies;
  final String imageUrl;
  final String? githubUrl;
  final String? liveUrl;
  final ProjectType type;

  const Project({
    required this.title,
    required this.description,
    required this.technologies,
    required this.imageUrl,
    this.githubUrl,
    this.liveUrl,
    this.type = ProjectType.main,
  });

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      title: map['title'] as String,
      description: map['description'] as String,
      technologies: List<String>.from(map['technologies'] as List),
      imageUrl: map['imageUrl'] as String,
      githubUrl: map['githubUrl'] as String?,
      liveUrl: map['liveUrl'] as String?,
      type: map['type'] == 'mini' ? ProjectType.mini : ProjectType.main,
    );
  }
}

