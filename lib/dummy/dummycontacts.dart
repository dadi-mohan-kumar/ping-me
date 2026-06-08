class ContactModel {
  final String name;
  final String message;
  final String time;
  final String imageUrl;

  ContactModel({
    required this.name,
    required this.message,
    required this.time,
    required this.imageUrl,
  });
}

// import 'package:pingme/models/contact_model.dart';

final List<ContactModel> dummyContacts = [

  ContactModel(
    name: 'Akshay',
    message: 'Where are you bro?',
    time: '10:30 AM',
    imageUrl:
        'https://i.pravatar.cc/150?img=1',
  ),

  ContactModel(
    name: 'Rahul',
    message: 'Send the project file',
    time: '09:45 AM',
    imageUrl:
        'https://i.pravatar.cc/150?img=2',
  ),

  ContactModel(
    name: 'Priya',
    message: 'Okay done 👍',
    time: 'Yesterday',
    imageUrl:
        'https://i.pravatar.cc/150?img=20',
  ),

  ContactModel(
    name: 'Kiran',
    message: 'Call me later',
    time: 'Yesterday',
    imageUrl:
        'https://i.pravatar.cc/150?img=4',
  ),

  ContactModel(
    name: 'Sneha',
    message: 'Typing...',
    time: '08:10 AM',
    imageUrl:
        'https://i.pravatar.cc/150?img=19',
  ),

  ContactModel(
    name: 'Arjun',
    message: 'Meeting at 5 PM',
    time: 'Monday',
    imageUrl:
        'https://i.pravatar.cc/150?img=21',
  ),

  ContactModel(
    name: 'Varun',
    message: 'Let’s play tonight',
    time: 'Monday',
    imageUrl:
        'https://i.pravatar.cc/150?img=7',
  ),

  ContactModel(
    name: 'sai',
    message: 'Photo received',
    time: 'Sunday',
    imageUrl:
        'https://i.pravatar.cc/150?img=10',
  ),
];