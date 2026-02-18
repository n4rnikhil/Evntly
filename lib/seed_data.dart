import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/event.dart';

// Use this to populate your Firestore with some initial data.
// Just call seedEvents() from your main.dart once.
Future<void> seedEvents() async {
  final db = FirebaseFirestore.instance;
  
  final events = [
    Event(
      id: 'hack-srm-5',
      title: 'HackSRM 5.0',
      description: 'The biggest hackathon in North India is back! Join us for 36 hours of innovation, coding, and pizza.',
      category: 'Hackathons',
      date: DateTime.now().add(const Duration(days: 2)),
      registrationDeadline: DateTime.now().add(const Duration(hours: 12)),
      location: 'SRM University, Main Campus',
      registrationLink: 'https://hacksrm.tech',
      imageUrl: 'https://picsum.photos/seed/hackathon/800/450',
      isFeatured: true,
      submittedBy: 'admin',
      organizerName: 'SRM Hackers Club',
      createdAt: DateTime.now(),
    ),
    Event(
      id: 'ai-summit',
      title: 'AI Summit 2026',
      description: 'Explore the future of Artificial Intelligence with speakers from Google, Meta, and OpenAI.',
      category: 'AI & ML',
      date: DateTime.now().add(const Duration(days: 5)),
      registrationDeadline: DateTime.now().add(const Duration(days: 3)),
      location: 'Tech Auditorium',
      registrationLink: 'https://aisummit.app',
      imageUrl: 'https://picsum.photos/seed/ai/800/450',
      submittedBy: 'admin',
      organizerName: 'AI Society',
      createdAt: DateTime.now(),
    ),
    Event(
      id: 'cipher-ctf',
      title: 'Cipher CTF',
      description: 'Capture the flag competition. Test your cybersecurity skills in this 24-hour challenge.',
      category: 'Cybersecurity',
      date: DateTime.now().add(const Duration(days: 7)),
      registrationDeadline: DateTime.now().add(const Duration(days: 5)),
      location: 'Lab 402',
      registrationLink: 'https://cipher.io',
      imageUrl: 'https://picsum.photos/seed/security/800/450',
      submittedBy: 'admin',
      organizerName: 'CyberSec Squad',
      createdAt: DateTime.now(),
    ),
    Event(
      id: 'designathon',
      title: 'UI Designathon',
      description: 'A 12-hour design sprint for creative minds. Build the best mobile UI and win prizes.',
      category: 'Design',
      date: DateTime.now().add(const Duration(days: 3)),
      registrationDeadline: DateTime.now().add(const Duration(days: 2)),
      location: 'Design Studio',
      registrationLink: 'https://design.ly',
      imageUrl: 'https://picsum.photos/seed/design/800/450',
      submittedBy: 'admin',
      organizerName: 'Creative Collective',
      createdAt: DateTime.now(),
    ),
  ];

  for (var event in events) {
    await db.collection('events').doc(event.id).set(event.toMap());
  }
  
  print('Seed data uploaded successfully!');
}
