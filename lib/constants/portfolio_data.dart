// Portfolio data - customize this with your own information
class PortfolioData {
  // Personal Information
  static const String name = 'Shaham Ahammed';
  static const String title = 'Software Developer';
  static const String profileImagePath =
      'assets/images/profile_image.jpeg'; // Replace with your image path
  static const String quote =
      'Code is my canvas, and the screen is my art gallery.';
  static const String bio = '''
I'm a Flutter developer with 2+ years of experience building mobile apps and websites. I currently work at Applab, Qatar, where I enjoy turning ideas into real, usable products with a strong focus on smooth user experiences.

I love problem solving and breaking down complex challenges into simple, practical solutions. I enjoy working both with a team and independently—whether it's collaborating on ideas or quietly wrestling with bugs until they finally give up. Always curious and always learning, I enjoy experimenting with new ideas and building things that genuinely make a difference.
''';

  static const String aboutGifPath =
      'https://user-images.githubusercontent.com/74038190/241765440-80728820-e06b-4f96-9c9e-9df46f0cc0a5.gif';
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
    {'name': 'Flutter'},
    {'name': 'Dart'},
    {'name': 'Firebase'},
    {'name': 'Google Services'},
    {'name': 'Hive'},
    {'name': 'REST API'},
    {'name': 'Figma'},
    {'name': 'Git'},
    {'name': 'Bloc'},
    {'name': 'GetX'},
    {'name': 'Provider'},
    {'name': 'Clean Architecture'},
  ];

  // Projects
  static const List<Map<String, dynamic>> projects = [
    // Main Projects
    {
      'title': 'Kawader',
      'description':
          'Government job application platform for Qatar, featuring dedicated jobseeker and employer portals across web and mobile (iOS & Android), enabling job posting, CV creation, interview management and AI-powered assistance.',
      'technologies': [
        'Flutter',
        'REST API',
        'GoRouter',
        'Provider',
        'Localization',
        'Clean Architecture',
        'Theme Management',
      ],
      'imageUrl': 'https://via.placeholder.com/400x250',
      'webUrl': 'https://www.kawader.gov.qa/',
      'iosUrl': 'https://apps.apple.com/qa/app/kawader-qatar/id6755183682',
      'androidUrl':
          'https://play.google.com/store/apps/details?id=com.cgb.kawader',

      'type': 'main',
    },
    {
      'title': 'Task Management System',
      'description':
          'Collaborative task management platform with real-time updates and team collaboration features.',
      'technologies': ['React', 'Node.js', 'MongoDB'],
      'imageUrl': 'https://via.placeholder.com/400x250',
      'githubUrl': 'https://github.com/yourusername/project2',

      'type': 'main',
    },
    {
      'title': 'AI Travel Planner',
      'description':
          'An AI-assisted trip planning tool with itinerary drafts, budget tracking, and live recommendations.',
      'technologies': ['Flutter', 'Firebase', 'OpenAI API'],
      'imageUrl': 'https://via.placeholder.com/400x250',
      'githubUrl': 'https://github.com/yourusername/ai-travel-planner',

      'type': 'main',
    },
    // Mini Projects
    {
      'title': 'Weather App',
      'description':
          'Beautiful weather application with location-based forecasts and detailed weather analytics.',
      'technologies': ['Flutter', 'REST API', 'Location Services'],
      'imageUrl': 'https://via.placeholder.com/400x250',
      'githubUrl': 'https://github.com/yourusername/project3',
      'type': 'mini',
    },
    {
      'title': 'Social Media Dashboard',
      'description':
          'Comprehensive dashboard for managing multiple social media accounts with analytics and scheduling.',
      'technologies': ['React', 'Express', 'PostgreSQL'],
      'imageUrl': 'https://via.placeholder.com/400x250',
      'githubUrl': 'https://github.com/yourusername/project4',
      'type': 'mini',
    },
    {
      'title': 'Calculator App',
      'description':
          'A modern calculator app with scientific functions and beautiful UI.',
      'technologies': ['Flutter', 'Dart'],
      'imageUrl': 'https://via.placeholder.com/400x250',
      'githubUrl': 'https://github.com/yourusername/calculator',
      'type': 'mini',
    },
    {
      'title': 'Todo App',
      'description':
          'Simple and elegant todo application with local storage and reminders.',
      'technologies': ['Flutter', 'Hive'],
      'imageUrl': 'https://via.placeholder.com/400x250',
      'githubUrl': 'https://github.com/yourusername/todo',
      'type': 'mini',
    },
  ];

  // Experience
  static const List<Map<String, dynamic>> experiences = [
    {
      'title': 'Senior Software Developer',
      'company': 'Tech Company Inc.',
      'location': 'San Francisco, CA',
      'period': '2022 - Present',
      'description':
          'Leading development of mobile applications using Flutter. Mentoring junior developers and architecting scalable solutions.',
      'technologies': ['Flutter', 'Dart', 'Firebase', 'AWS'],
    },
    {
      'title': 'Software Developer',
      'company': 'Startup XYZ',
      'location': 'Remote',
      'period': '2020 - 2022',
      'description':
          'Developed full-stack web applications using React and Node.js. Collaborated with cross-functional teams to deliver high-quality products.',
      'technologies': ['React', 'Node.js', 'MongoDB', 'Docker'],
    },
    {
      'title': 'Junior Developer',
      'company': 'Digital Agency',
      'location': 'New York, NY',
      'period': '2018 - 2020',
      'description':
          'Built responsive websites and mobile applications. Gained experience in various technologies and frameworks.',
      'technologies': ['JavaScript', 'React', 'Python', 'SQL'],
    },
  ];
}
