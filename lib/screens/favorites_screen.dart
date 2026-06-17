import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/contact_bloc.dart';
import '../bloc/contact_state.dart';
import '../widgets/contact_avatar.dart';
import 'contact_profile_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: BlocBuilder<ContactBloc, ContactState>(
        builder: (context, state) {
          if (state is! ContactLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final favs = state.favorites;

          if (favs.isEmpty) {
            return const Center(
              child: Text('No favorites yet.\nTap the star on a contact to add one.', textAlign: TextAlign.center),
            );
          }

          return ListView.builder(
            itemCount: favs.length,
            itemBuilder: (context, index) {
              final contact = favs[index];
              return ListTile(
                leading: ContactAvatar(name: contact.name, photoPath: contact.photoPath),
                title: Text(contact.name),
                subtitle: Text(contact.phone),
                trailing: const Icon(Icons.star, color: Colors.amber),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ContactProfileScreen(contact: contact)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
