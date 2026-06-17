import '../models/contact.dart';

abstract class ContactEvent {}

class LoadContacts extends ContactEvent {}

class AddContact extends ContactEvent {
  final Contact contact;
  AddContact(this.contact);
}

class UpdateContact extends ContactEvent {
  final Contact contact;
  UpdateContact(this.contact);
}

class DeleteContact extends ContactEvent {
  final int id;
  DeleteContact(this.id);
}

class ToggleFavorite extends ContactEvent {
  final Contact contact;
  ToggleFavorite(this.contact);
}
