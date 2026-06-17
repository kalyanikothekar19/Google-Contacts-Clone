import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/contact_bloc.dart';
import '../bloc/contact_event.dart';
import '../models/contact.dart';
import '../widgets/contact_avatar.dart';
import '../widgets/delete_dialog.dart';
import 'add_edit_contact_screen.dart';

class ContactProfileScreen extends StatelessWidget {
  final Contact contact;

  const ContactProfileScreen({super.key, required this.contact});

  Future<void> callNumber(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: contact.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not place call')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddEditContactScreen(contact: contact)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDeleteConfirmation(context, contact.name);
              if (confirmed) {
                context.read<ContactBloc>().add(DeleteContact(contact.id!));
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ContactAvatar(name: contact.name, photoPath: contact.photoPath, radius: 60),
            const SizedBox(height: 16),
            Text(contact.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: Text(contact.phone),
                subtitle: const Text('Mobile'),
                trailing: IconButton(
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: () => callNumber(context),
                ),
              ),
            ),
            if (contact.email.isNotEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.email, color: Colors.blue),
                  title: Text(contact.email),
                  subtitle: const Text('Email'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
