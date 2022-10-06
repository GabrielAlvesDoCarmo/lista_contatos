import 'dart:io';

import 'package:flutter/material.dart';
import '../helpers/contact_helper.dart';
import 'package:image_picker/image_picker.dart';

enum Order { orderAz, orderZa }

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key, this.contact, required this.function})
      : super(key: key);
  final Contact? contact;
  final Function(Contact) function;

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  late Contact _editContact;
  bool _userNameEdited = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.contact == null) {
      _editContact = Contact();
    } else {
      _editContact = Contact.fromMap(widget.contact!.toMap());
      _nameController.text = _editContact.name ?? "";
      _emailController.text = _editContact.email ?? "";
      _phoneController.text = _editContact.phone ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: _requestPop,
        child: Scaffold(
          appBar: AppBar(
            title: Text(_editContact.name ?? "Novo contato"),
            centerTitle: true,
            backgroundColor: Colors.red,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                widget.function(_editContact);
                Navigator.pop(context);
              } else {
                FocusScope.of(context).requestFocus(_focus);
              }
            },
            backgroundColor: Colors.red,
            child: const Icon(Icons.save),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                GestureDetector(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(image: defineImage())),
                  ),
                  onTap: () {
                    ImagePicker.platform
                        .pickImage(source: ImageSource.camera)
                        .then((value) {
                      if (value == null) return;
                      setState(() {
                        _editContact.img = value.path;
                      });
                    });
                  },
                ),
                TextField(
                  focusNode: _focus,
                  decoration: const InputDecoration(
                    labelText: "Nome",
                  ),
                  controller: _nameController,
                  onChanged: (text) {
                    _userNameEdited = true;
                    setState(() {
                      _editContact.name = text;
                    });
                  },
                  keyboardType: TextInputType.name,
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Email",
                  ),
                  controller: _emailController,
                  onChanged: (text) {
                    _userNameEdited = true;
                    _editContact.email = text;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Phone",
                  ),
                  controller: _phoneController,
                  onChanged: (text) {
                    _userNameEdited = true;
                    _editContact.phone = text;
                  },
                  keyboardType: TextInputType.phone,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  defineImage() {
    return _editContact.img != null
        ? FileImage(File(_editContact.img!))
        : const AssetImage("images/person.png");
  }

  Future<bool> _requestPop() {
    if (_userNameEdited) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Descartar?"),
            content: const Text("Se sair perde-ra tudo ?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("Sair"),
              )
            ],
          );
        },
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }


}
