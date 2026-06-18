import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/contact_repository.dart';
import '../repository/storage_helper.dart';
import 'contact_event.dart';
import 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final ContactRepository repo = ContactRepository();
  final StorageHelper storageHelper = StorageHelper();

  ContactBloc() : super(ContactLoading()) {
    on<LoadContacts>((event, emit) async {
      emit(ContactLoading());
      try {
        final contacts = await repo.getContacts();
        emit(ContactLoaded(contacts));
      } catch (e) {
        emit(ContactError('Could not load contacts'));
      }
    });

    on<AddContact>((event, emit) async {
      final newId = await repo.insertContact(event.contact);

      if (event.photoFile != null) {
        final url = await storageHelper.uploadPhoto(event.photoFile!, newId);
        event.contact.id = newId;
        event.contact.photoPath = url;
        await repo.updateContact(event.contact);
      }

      final contacts = await repo.getContacts();
      emit(ContactLoaded(contacts));
    });

    on<UpdateContact>((event, emit) async {
      await repo.updateContact(event.contact);
      final contacts = await repo.getContacts();
      emit(ContactLoaded(contacts));
    });

    on<DeleteContact>((event, emit) async {
      await repo.deleteContact(event.id);
      final contacts = await repo.getContacts();
      emit(ContactLoaded(contacts));
    });

    on<ToggleFavorite>((event, emit) async {
      event.contact.isFavorite = !event.contact.isFavorite;
      await repo.updateContact(event.contact);
      final contacts = await repo.getContacts();
      emit(ContactLoaded(contacts));
    });
  }
}
