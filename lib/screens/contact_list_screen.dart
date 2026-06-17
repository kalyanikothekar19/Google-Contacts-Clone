import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/contact_bloc.dart';
import '../bloc/contact_event.dart';
import '../bloc/contact_state.dart';
import '../models/contact.dart';
import '../widgets/contact_avatar.dart';
import '../widgets/delete_dialog.dart';
import 'add_edit_contact_screen.dart';
import 'contact_profile_screen.dart';

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ContactBloc>().add(LoadContacts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search contacts',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() {
                  searchQuery = val.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<ContactBloc, ContactState>(
              builder: (context, state) {
                if (state is ContactLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ContactError) {
                  return Center(child: Text(state.message));
                }

                if (state is ContactLoaded) {
                  var contacts = state.contacts;

                  if (searchQuery.isNotEmpty) {
                    contacts = contacts
                        .where((c) => c.name.toLowerCase().contains(searchQuery))
                        .toList();
                  }

                  if (contacts.isEmpty) {
                    return const Center(child: Text('No contacts yet. Tap + to add one.'));
                  }

                  return ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return Dismissible(
                        key: ValueKey(contact.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) => showDeleteConfirmation(context, contact.name),
                        onDismissed: (_) {
                          context.read<ContactBloc>().add(DeleteContact(contact.id!));
                        },
                        child: ListTile(
                          leading: ContactAvatar(name: contact.name, photoPath: contact.photoPath),
                          title: Text(contact.name),
                          subtitle: Text(contact.phone),
                          trailing: IconButton(
                            icon: Icon(
                              contact.isFavorite ? Icons.star : Icons.star_border,
                              color: contact.isFavorite ? Colors.amber : Colors.grey,
                            ),
                            onPressed: () {
                              context.read<ContactBloc>().add(ToggleFavorite(contact));
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ContactProfileScreen(contact: contact),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditContactScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
