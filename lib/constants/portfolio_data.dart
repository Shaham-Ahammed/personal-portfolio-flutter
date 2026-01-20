// Portfolio data - customize this with your own information
class PortfolioData {
  // Personal Information
  static const String name = 'Shaham Ahammed';
  static const String title = 'Software Developer';
  static const String profileImagePath = 'assets/images/profile_image.jpeg'; // Replace with your image path
  static const String quote = 'Code is my canvas, and the screen is my art gallery.';
  static const String bio = 'Passionate developer creating amazing digital experiences.';
  
  // Contact Information
  static const String email = 'your.email@example.com';
  static const String phone = '+1 (555) 123-4567';
  static const String location = 'Your City, Country';
  
  // Social Media Links
  static const String githubUrl = 'https://github.com/yourusername';
  static const String linkedinUrl = 'https://linkedin.com/in/yourusername';
  static const String twitterUrl = 'https://twitter.com/yourusername';
  static const String instagramUrl = 'https://instagram.com/yourusername';
  
  // Skills
  static const List<Map<String, dynamic>> skills = [
    {'name': 'Flutter', 'level': 90, 'icon': '💙'},
    {'name': 'Dart', 'level': 85, 'icon': '💙'},
    {'name': 'JavaScript', 'level': 80, 'icon': '🟨'},
    {'name': 'React', 'level': 75, 'icon': '⚛️'},
    {'name': 'Node.js', 'level': 70, 'icon': '🟢'},
    {'name': 'Python', 'level': 75, 'icon': '🐍'},
    {'name': 'UI/UX Design', 'level': 80, 'icon': '🎨'},
    {'name': 'Git', 'level': 85, 'icon': '📦'},
  ];
  
  // Projects
  static const List<Map<String, dynamic>> projects = [
    {
      'title': 'E-Commerce App',
      'description': 'A full-featured e-commerce mobile application with payment integration and real-time inventory management.',
      'technologies': ['Flutter', 'Firebase', 'Stripe'],
      'imageUrl': 'https://via.placeholder.com/400x250',
      'githubUrl': 'https://github.com/yourusername/project1',
      'liveUrl': 'https://project1-demo.com',
    },
    {
      'title': 'Task Management System',
      'description': 'Collaborative task management platform with real-time updates and team collaboration features.',
      'technologies': ['React', 'Node.js', 'MongoDB'],
      'imageUrl': 'https://via.placeholder.com/400x250',
      'githubUrl': 'https://github.com/yourusername/project2',
      'liveUrl': 'https://project2-demo.com',
    },
    {
      'title': 'Weather App',
      'description': 'Beautiful weather application with location-based forecasts and detailed weather analytics.',
      'technologies': ['Flutter', 'REST API', 'Location Services'],
      'imageUrl': 'https://via.placeholder.com/400x250',
      'githubUrl': 'https://github.com/yourusername/project3',
      'liveUrl': 'https://project3-demo.com',
    },
    {
      'title': 'Social Media Dashboard',
      'description': 'Comprehensive dashboard for managing multiple social media accounts with analytics and scheduling.',
      'technologies': ['React', 'Express', 'PostgreSQL'],
      'imageUrl': 'https://via.placeholder.com/400x250',
      'githubUrl': 'https://github.com/yourusername/project4',
      'liveUrl': 'https://project4-demo.com',
    },
  ];
  
  // Experience
  static const List<Map<String, dynamic>> experiences = [
    {
      'title': 'Senior Software Developer',
      'company': 'Tech Company Inc.',
      'location': 'San Francisco, CA',
      'period': '2022 - Present',
      'description': 'Leading development of mobile applications using Flutter. Mentoring junior developers and architecting scalable solutions.',
      'technologies': ['Flutter', 'Dart', 'Firebase', 'AWS'],
    },
    {
      'title': 'Software Developer',
      'company': 'Startup XYZ',
      'location': 'Remote',
      'period': '2020 - 2022',
      'description': 'Developed full-stack web applications using React and Node.js. Collaborated with cross-functional teams to deliver high-quality products.',
      'technologies': ['React', 'Node.js', 'MongoDB', 'Docker'],
    },
    {
      'title': 'Junior Developer',
      'company': 'Digital Agency',
      'location': 'New York, NY',
      'period': '2018 - 2020',
      'description': 'Built responsive websites and mobile applications. Gained experience in various technologies and frameworks.',
      'technologies': ['JavaScript', 'React', 'Python', 'SQL'],
    },
  ];
}

