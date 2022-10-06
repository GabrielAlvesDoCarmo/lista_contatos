import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lista_contatos/helpers/contact_helper.dart';
import 'package:lista_contatos/ui/contact_page.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  List<Contact> listContact = [];

  @override
  void initState() {
    super.initState();
    searchAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Contatos"),
          backgroundColor: Colors.red,
          centerTitle: true,
          actions: [
            PopupMenuButton<Order>(
              itemBuilder: (context) => <PopupMenuEntry<Order>>[
                const PopupMenuItem(
                  child: Text("ordenar de a-z"),
                  value: Order.orderAz,
                ),
                const PopupMenuItem(
                  child: Text("ordenar de z-a"),
                  value: Order.orderZa,
                ),
              ],
              onSelected: _orderList,
            )
          ],
        ),
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showContactPage();
          },
          backgroundColor: Colors.red,
          child: const Icon(Icons.add),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemBuilder: (context, index) {
            return _contactCard(context, index);
          },
          itemCount: listContact.length,
        ),
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: defineImage(index)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 10.0,
                ),
                child: Column(
                  children: [
                    Text(
                      listContact[index].name ?? "",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      listContact[index].email ?? "",
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      listContact[index].phone ?? "",
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  void searchAllContacts() {
    helper.getAllContact().then((list) {
      setState(() {
        listContact = list;
      });
    });
  }

  void _showContactPage({Contact? contact}) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return contact != null
          ? ContactPage(
              contact: contact,
              function: updateContact,
            )
          : ContactPage(
              function: saveContact,
            );
    }));
  }

  defineImage(int index) {
    var contact = listContact[index];
    return contact.img != null
        ? FileImage(File(contact.img!))
        : const AssetImage("images/person.png");
  }

  saveContact(Contact contact) async {
    await helper.saveContact(contact);
    searchAllContacts();
  }

  updateContact(Contact contact) async {
    await helper.updateContact(contact);
    searchAllContacts();
  }

  void _orderList(Order value) {
    switch (value) {
      case Order.orderAz:
        listContact.sort((a, b) {
          return a.name!.toLowerCase().compareTo(b.name!.toLowerCase());
        });
        break;
      case Order.orderZa:
        listContact.sort((a, b) {
          return b.name!.toLowerCase().compareTo(a.name!.toLowerCase());
        });
        break;
    }
    setState(() {

    });
  }

  void _showOptions(BuildContext context, int index) {
    Contact itemActual = listContact[index];
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextButton(
                    onPressed: () {
                      launch("tel:${itemActual.phone}");
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Ligar",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showContactPage(contact: itemActual);
                    },
                    child: const Text(
                      "Editar",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextButton(
                    onPressed: () {
                      helper.deleteContact(itemActual.id!);
                      setState(() {
                        listContact.remove(itemActual);
                        Navigator.pop(context);
                      });
                    },
                    child: const Text(
                      "Excluir",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }
}
