enum ProjectType { main, mini }

class Project {
  final String title;
  final String description;
  final List<String> technologies;
  final String imageUrl;
  final List<String>? galleryImages;
  final String? githubUrl;
  final String? iosUrl;
  final String? androidUrl;
  final String? adminAndroidUrl;
  final String? userAndroidUrl;
  final String? webUrl;
  final ProjectType type;

  const Project({
    required this.title,
    required this.description,
    required this.technologies,
    required this.imageUrl,
    this.galleryImages,
    this.githubUrl,
    this.iosUrl,
    this.androidUrl,
    this.adminAndroidUrl,
    this.userAndroidUrl,
    this.webUrl,
    this.type = ProjectType.main,
  });

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      title: map['title'] as String,
      description: map['description'] as String,
      technologies: List<String>.from(map['technologies'] as List),
      imageUrl: map['imageUrl'] as String,
      galleryImages: map['galleryImages'] != null
          ? List<String>.from(map['galleryImages'] as List)
          : null,
      githubUrl: map['githubUrl'] as String?,
      iosUrl: map['iosUrl'] as String?,
      androidUrl: map['androidUrl'] as String?,
      adminAndroidUrl: map['adminAndroidUrl'] as String?,
      userAndroidUrl: map['userAndroidUrl'] as String?,
      webUrl: map['webUrl'] as String?,
      type: map['type'] == 'mini' ? ProjectType.mini : ProjectType.main,
    );
  }
}

