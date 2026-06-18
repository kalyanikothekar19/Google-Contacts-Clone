import 'package:flutter_bloc/flutter_bloc.dart';
import '../db/db_helper.dart';
import 'contact_event.dart';
import 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final DBHelper dbHelper = DBHelper();

  ContactBloc() : super(ContactLoading()) {
    on<LoadContacts>((event, emit) async {
      emit(ContactLoading());
      try {
        final contacts = await dbHelper.getContacts();
        emit(ContactLoaded(contacts));
      } catch (e) {
        emit(ContactError('Could not load contacts'));
      }
    });

    on<AddContact>((event, emit) async {
      await dbHelper.insertContact(event.contact);
      final contacts = await dbHelper.getContacts();
      emit(ContactLoaded(contacts));
    });

    on<UpdateContact>((event, emit) async {
      await dbHelper.updateContact(event.contact);
      final contacts = await dbHelper.getContacts();
      emit(ContactLoaded(contacts));
    });

    on<DeleteContact>((event, emit) async {
      await dbHelper.deleteContact(event.id);
      final contacts = await dbHelper.getContacts();
      emit(ContactLoaded(contacts));
    });

    on<ToggleFavorite>((event, emit) async {
      event.contact.isFavorite = !event.contact.isFavorite;
      await dbHelper.updateContact(event.contact);
      final contacts = await dbHelper.getContacts();
      emit(ContactLoaded(contacts));
    });
  }
}
