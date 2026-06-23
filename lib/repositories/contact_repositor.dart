import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get device contacts only when user taps search/discover
  Future<List<Contact>> getDeviceContacts() async {
    if (await FlutterContacts.requestPermission(readonly: true))
      return await FlutterContacts.getContacts(withProperties: true);
    return [];
  }

  // Find registered users from Firestore
  Future<List<Map<String, dynamic>>> findRegisteredUsers(
    List<Contact> contacts,
  ) async {
    final usersSnapshot = await _firestore.collection('users').get();

    final users = usersSnapshot.docs;

    List<Map<String, dynamic>> registeredUsers = [];

    for (final contact in contacts) {
      if (contact.phones.isEmpty) continue;

      final contactNumber = _normalizePhone(contact.phones.first.number);

      for (final user in users) {
        final data = user.data();

        final userPhone = _normalizePhone(data['phoneNumber'] ?? '');

        if (contactNumber == userPhone) {
          registeredUsers.add({
            'uid': user.id,
            'name': data['name'],
            'phoneNumber': data['phoneNumber'],
            'profileImage': data['profileImage'],
            'isRegistered': true,
          });

          break;
        }
      }
    }

    return registeredUsers;
  }

  /// Find contacts not registered in app
  Future<List<Contact>> findUnregisteredContacts(List<Contact> contacts) async {
    final usersSnapshot = await _firestore.collection('users').get();

    final users = usersSnapshot.docs;

    List<String> registeredNumbers = [];

    for (final user in users) {
      registeredNumbers.add(_normalizePhone(user.data()['phoneNumber'] ?? ''));
    }

    return contacts.where((contact) {
      if (contact.phones.isEmpty) return false;

      final number = _normalizePhone(contact.phones.first.number);

      return !registeredNumbers.contains(number);
    }).toList();
  }

  String _normalizePhone(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleaned.startsWith('91') && cleaned.length > 10) {
      cleaned = cleaned.substring(cleaned.length - 10);
    }

    return cleaned;
  }
}
