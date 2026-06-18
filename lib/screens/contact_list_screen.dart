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

  // Group contacts alphabetically
  Map<String, List<dynamic>> groupContactsByLetter(List<dynamic> contacts) {
    Map<String, List<dynamic>> grouped = {};

    for (var contact in contacts) {
      String letter = contact.name[0].toUpperCase();
      if (!grouped.containsKey(letter)) {
        grouped[letter] = [];
      }
      grouped[letter]!.add(contact);
    }

    // Sort by letter
    var sortedKeys = grouped.keys.toList()..sort();
    Map<String, List<dynamic>> sortedGrouped = {};
    for (var key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }

    return sortedGrouped;
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
                hintStyle: const TextStyle(
                  fontSize: 18,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: const Icon(
                    Icons.search,
                    size: 27,
                  ),
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                    child: const Text(
                      'K',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 241, 235, 235),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
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
                        .where(
                            (c) => c.name.toLowerCase().contains(searchQuery))
                        .toList();
                  }

                  if (contacts.isEmpty) {
                    return const Center(
                        child: Text('No contacts yet. Tap + to add one.'));
                  }

                  var groupedContacts = groupContactsByLetter(contacts);
                  var letters = groupedContacts.keys.toList();

                  List<Widget> listItems = [];
                  for (String letter in letters) {
                    listItems.add(
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          letter,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ),
                    );

                    for (var contact in groupedContacts[letter]!) {
                      listItems.add(
                        Dismissible(
                          key: ValueKey(contact.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (_) =>
                              showDeleteConfirmation(context, contact.name),
                          onDismissed: (_) {
                            context
                                .read<ContactBloc>()
                                .add(DeleteContact(contact.id!));
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: ContactAvatar(
                                name: contact.name,
                                photoPath: contact.photoPath,
                              ),
                              title: Text(
                                contact.name,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                contact.phone,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  contact.isFavorite
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: contact.isFavorite
                                      ? Colors.amber
                                      : Colors.grey,
                                ),
                                onPressed: () {
                                  context
                                      .read<ContactBloc>()
                                      .add(ToggleFavorite(contact));
                                },
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ContactProfileScreen(contact: contact),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    }
                  }
                  return ListView(children: listItems);
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
