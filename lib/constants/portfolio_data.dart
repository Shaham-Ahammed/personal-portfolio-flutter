// Portfolio data - customize this with your own information
class PortfolioData {
  // Personal Information
  static const String name = 'Shaham Ahammed';
  static const String title = 'Software Developer';
  static const String profileImagePath =
      'assets/images/coding_boy.jpeg'; // Replace with your image path
  static const String quote =
      'Code is my canvas, and the screen is my art gallery.';
  static const String bio = '''
I'm a Flutter developer with 2+ years of experience building mobile apps and websites. I currently work at Applab, Qatar, where I enjoy turning ideas into real, usable products with a strong focus on smooth user experiences.

I love problem solving and breaking down complex challenges into simple, practical solutions. I enjoy working both with a team and independently—whether it's collaborating on ideas or quietly wrestling with bugs until they finally give up. Always curious and always learning, I enjoy experimenting with new ideas and building things that genuinely make a difference.
''';

  static const String aboutImage = 'assets/images/profile_image.jpeg';
  // Contact Information
  static const String email = 'shahamahammed66@gmail.com';
  static const String phone = '+91 9961628586';

  // Social Media Links
  static const String githubUrl = 'https://github.com/Shaham-Ahammed';
  static const String linkedinUrl =
      'https://www.linkedin.com/in/shaham-ahammed-p-k-5a126b290/';
  static const String instagramUrl =
      'https://www.instagram.com/___.shaham.___?igsh=MWFpcTZjNXZvbTJxMA%3D%3D';
  static const String leetcodeUrl = 'https://leetcode.com/u/Shaham_Ahammed/';
  static const String whatsappUrl =
      'https://wa.me/919961628586'; // WhatsApp with country code
  
  // CV/Resume URL - Replace with your actual CV link (Google Drive, Dropbox, or hosted PDF)
  static const String cvUrl = 'https://drive.google.com/file/d/1mklDo66pfcfw7_bDep3j7xeN2lSdOH90/view?usp=sharing';

  // Skills
  static const List<Map<String, dynamic>> skills = [
    {'name': 'Flutter'},
    {'name': 'Dart'},
    {'name': 'Firebase'},
    {'name': 'Google Services'},
    {'name': 'Hive'},
    {'name': 'sqflite'},
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
          'Government job application platform for Qatar, featuring dedicated jobseeker and employer portals across web and mobile (iOS & Android)',
      'technologies': [
        'Flutter',
        'REST API',
        'GoRouter',
        'Provider',
        'Localization',
        'Clean Architecture',
        'Theme Management',
      ],
      'imageUrl':
          'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769072603/Screenshot_2026-01-22_at_11.51.34_AM_phojat.png',
      'galleryImages': [
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769072807/Screenshot_2026-01-22_at_11.16.22_AM_lxfri6.png',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769072807/Screenshot_2026-01-22_at_11.20.00_AM_myx8gz.png',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769072807/Screenshot_2026-01-22_at_11.21.36_AM_olrrvn.png',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769072806/Screenshot_2026-01-22_at_11.23.54_AM_bcbrxe.png',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769072806/Screenshot_2026-01-22_at_11.22.46_AM_bsnvsg.png',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769072805/Screenshot_2026-01-22_at_11.25.10_AM_upapwt.png',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769072804/Screenshot_2026-01-22_at_11.26.01_AM_esmd5z.png',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769072804/Screenshot_2026-01-22_at_11.26.56_AM_a8eytl.png',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769072803/Screenshot_2026-01-22_at_11.27.53_AM_d5vtau.png',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769072803/Screenshot_2026-01-22_at_11.28.44_AM_wswfun.png',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769072802/Screenshot_2026-01-22_at_11.29.17_AM_z6tbbp.png',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769072802/Screenshot_2026-01-22_at_11.38.32_AM_twaw7q.png',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769072801/Screenshot_2026-01-22_at_11.39.22_AM_keehyz.png',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769072801/Screenshot_2026-01-22_at_11.38.54_AM_vyok9d.png',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769072801/Screenshot_2026-01-22_at_11.40.34_AM_srn64n.png',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769072801/Screenshot_2026-01-22_at_11.41.21_AM_mrnnzr.png',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769072800/Screenshot_2026-01-22_at_11.41.47_AM_u4z1aj.png',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769072799/Screenshot_2026-01-22_at_11.49.28_AM_o11kvt.png',
      ],
      'webUrl': 'https://www.kawader.gov.qa/',
      'iosUrl': 'https://apps.apple.com/qa/app/kawader-qatar/id6755183682',
      'androidUrl':
          'https://play.google.com/store/apps/details?id=com.cgb.kawader',

      'type': 'main',
    },
    {
      'title': 'Trim Spot',
      'description':
          'TrimSpot is an end-to-end salon booking platform featuring admin, salon and user applications with real-time updates.',
      'technologies': [
        'Flutter',
        'Firebase',
        'Razorpay',
        'Bloc',
        'Google Maps',
        'Google Authentication',
      ],
      'imageUrl': 'https://m.media-amazon.com/images/I/514sByarriL.png',
      'galleryImages': [
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769086895/WhatsApp_Image_2026-01-22_at_15.54.50_rnrkm3.jpg',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769086946/WhatsApp_Image_2026-01-22_at_15.54.53_1_nbqk7c.jpg',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769086895/WhatsApp_Image_2026-01-22_at_15.54.51_qmmroe.jpg',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769086894/WhatsApp_Image_2026-01-22_at_15.54.51_2_gaynx5.jpg',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769086894/WhatsApp_Image_2026-01-22_at_15.54.53_zvm5br.jpg',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769086893/WhatsApp_Image_2026-01-22_at_15.54.52_1_y1k4gg.jpg',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769086892/WhatsApp_Image_2026-01-22_at_15.54.51_3_ebqket.jpg',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769086891/WhatsApp_Image_2026-01-22_at_15.54.52_2_gf6n3h.jpg',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769086890/WhatsApp_Image_2026-01-22_at_15.54.52_3_hgewqj.jpg',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769086889/WhatsApp_Image_2026-01-22_at_15.54.50_1_g0pyzh.jpg',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769086889/WhatsApp_Image_2026-01-22_at_15.54.52_4_fmuxo9.jpg',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769086888/WhatsApp_Image_2026-01-22_at_15.54.52_5_jzewr6.jpg',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769086888/WhatsApp_Image_2026-01-22_at_15.54.50_2_ktucou.jpg',
      ],
      'githubUrl': 'https://github.com/Shaham-Ahammed/trim-spot-user',
      'userAndroidUrl': 'https://www.amazon.com/dp/B0D571DFTK/ref=apps_sf_sta',
      'adminAndroidUrl': 'https://www.amazon.com/dp/B0CY5D6XFL/ref=apps_sf_sta',
      'type': 'main',
    },
    {
      'title': 'Lazits',
      'description':
          'Lazits is an offline music player with playlist management, playback customization, lyrics and recording.',
      'technologies': [
        'Flutter',
        'Hive',
        'Audio Player',
        'Audio Recorder',
        'REST API',
      ],
      'imageUrl': 'https://m.media-amazon.com/images/I/6132jfJf-fL.png',
      'galleryImages': [
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769089224/WhatsApp_Image_2026-01-22_at_16.38.51_4_hvuzyg.jpg',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769089223/WhatsApp_Image_2026-01-22_at_16.38.50_1_kt6xym.jpg',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769089224/WhatsApp_Image_2026-01-22_at_16.38.51_3_pqhsri.jpg',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769089225/WhatsApp_Image_2026-01-22_at_16.38.50_ofiann.jpg',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769089226/WhatsApp_Image_2026-01-22_at_16.38.51_1_gtqbxc.jpg',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769089225/WhatsApp_Image_2026-01-22_at_16.38.51_2_zjhsu7.jpg',
        'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769089227/WhatsApp_Image_2026-01-22_at_16.38.51_kplbvb.jpg',
      ],
      'githubUrl': 'https://github.com/Shaham-Ahammed/flutter-music-player',
      'androidUrl': 'https://www.amazon.com/dp/B0CPYR6D8W/ref=apps_sf_sta',
      'type': 'main',
    },
    // Mini Projects
    {
      'title': 'Netflix Clone',
      'description':
          'A streaming app that mimics Netflix, allowing users to browse movies and TV shows with detailed content views.',
      'technologies': ['TMDB API', 'REST API', 'HTTP'],
      'imageUrl':
          'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769331544/Screenshot_2026-01-25_at_11.58.07_AM_gz5bno.png',
      'githubUrl': 'https://github.com/Shaham-Ahammed/neflix_clone',
      'type': 'mini',
    },
    {
      'title': 'Recipe App',
      'description':
          'A recipe browsing app that lets users explore meals, view details, and save favorites for quick access.',
      'technologies': ['TheMealDB API', 'sqflite', 'debouncer'],
      'imageUrl':
          'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769331335/Screenshot_2026-01-25_at_11.55.16_AM_f7wlig.png',
      'githubUrl':
          'https://github.com/Shaham-Ahammed/LET-HIM-COOK---Recipe-application',
      'type': 'mini',
    },
    {
      'title': 'Student Record',
      'description':
          'An app for managing student records with the ability to add, view, update, and delete details.',
      'technologies': ['sqflite', 'GetX'],
      'imageUrl': '',
      'githubUrl':
          'https://github.com/Shaham-Ahammed/student-management-app-getX-sqflite',
      'type': 'mini',
    },
    {
      'title': 'Weather App',
      'description':
          'A weather app that provides real-time weather information based on user searches.',
      'technologies': ['Bloc', 'HTTP'],
      'imageUrl':
          'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769329926/Screenshot_2026-01-25_at_11.31.41_AM_fb2pps.png',
      'githubUrl': 'https://github.com/Shaham-Ahammed/weather-app-bloc-and-api',
      'type': 'mini',
    },

    {
      'title': 'Tic Tac Toe Game',
      'description': 'A simple and fun Tic Tac Toe game.',
      'technologies': ['2D array'],
      'imageUrl':
          'https://res.cloudinary.com/dilbmyvfv/image/upload/v1769329703/Screenshot_2026-01-25_at_11.25.31_AM_jqxn6s.png',
      'githubUrl':
          'https://github.com/Shaham-Ahammed/tic-tac-toe/blob/main/lib/main.dart',
      'type': 'mini',
    },
  ];

  // Experience
  static const List<Map<String, dynamic>> experiences = [
    {
      'title': 'Flutter Developer',
      'company': 'Applab',
      'location': 'Doha, Qatar',
      'period': '2025 - Present',
      'description':
          'Collaborated cross-functionally to suggest improvements and implement features efficiently. Contributed to multiple projects, including Ejaz (HBKU library app) and Kawader (Qatar government job portal). Involved in pre-release development and post-release production support, including bug fixes and application maintenance. Took ownership of responsibilities and delivered reliably under high-pressure workloads.',
      // 'technologies': ['Flutter', 'Dart', 'Firebase', 'AWS'],
      'website': 'https://applab.qa/',
    },
    {
      'title': 'Associate Flutter Developer',
      'company': 'Appstation Pvt Ltd',
      'location': 'Thiruvananthapuram, Kerala, India',
      'period': '2024 - 2025',
      'description':
          'Contributed to the development of Kawader as part of the Flutter team. Worked on initial project setup, including reusable widgets, localization, and theme configuration. Collaborated by owning specific modules and delivering features aligned with team standards.',
      // 'technologies': ['React', 'Node.js', 'MongoDB', 'Docker'],
      'website': 'https://www.appstation.in/',
    },
    {
      'title': 'Student Flutter Developer',
      'company': 'Brototype',
      'location': 'Calicut, Kerala, India',
      'period': '2023 - 2024',
      'description':
          'Built a strong foundation in C, Java, HTML, CSS, OOP concepts, and programming, and gained mastery in Flutter and Dart. Adapted self-learning methods to independently learn and implement new technologies. Developed multiple Flutter projects, including TrimSpot (salon booking app) and Lazits (music player app), along with several mini projects.',
      // 'technologies': ['React', 'Node.js', 'MongoDB', 'Docker'],
      'website': 'https://www.brototype.com/',
    },
  ];
}
