import 'dart:io';

import 'package:agenda_de_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Essa página vai servir tanto para criar um contato, quanto para editar um contato
  // Por esse motivo o construtor pode ser inicializado com ou sem parâmetro

class ContactPage extends StatefulWidget {

  final Contact contact;

  // {this.contact} está entre chaves porque é um parâmetro opcional
  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  // Para podermos obter os valores digitados no campo
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  // Ao abrir a página, vai indicar que o usuário não mecheu em nada
  bool _userEdited = false;

  Contact _editedContact;

  @override
  void initState() {
    super.initState();

    // widget.contact -> Para poder acessar o contact nessa classe (_ContactPageState)
    if(widget.contact == null){
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());

     // Quando eu passar um contato, ele já vai pegar os dados do contato e jogar no formulário
      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;

    }
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope = Chama um função antes de eu sair da tela (botão de voltar)
    return WillPopScope(
      onWillPop: _requestPop, 
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(_editedContact.name ?? "Novo Contato"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          if(_editedContact.name != null && _editedContact.name.isNotEmpty){
            // Remova a tela atual e volta para a anterior
            Navigator.pop(context,_editedContact);
          } else {
            // Caso o nome estiver nulo na hora de salvar, vai ser dado um foco no campo name
            FocusScope.of(context).requestFocus(_nameFocus);
          }
        },
        child: Icon(Icons.save),
        backgroundColor: Colors.red,
      ),
      // SingleChildScrollView: Pois o teclado pode ficar por cima dos campos de digitação 
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              // GestureDetector: para poder clicar na imagem
              GestureDetector(
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      // Se imagem do contato difere de nulo  
                      image: _editedContact.img != null ? 
                        // Caso o contato possua uma imagem, carrega a própria
                        FileImage(File(_editedContact.img)) :
                          /// Imagem padrão caso o contato não tenha salvado nenhuma imagem
                          // Importar a imagem no pubspec.yaml
                          AssetImage("images/person.png"),
                          fit: BoxFit.cover
                    ),
                  ),
                ),
                onTap: (){
                  ImagePicker.pickImage(source: ImageSource.gallery).then((file){
                    // Abriu a câmera e não tirou nenhuma foto
                    if(file == null) return;
                    setState(() {
                      // Se não; vai pegar o caminho da foto que o nosso usuário escolheu
                      _editedContact.img = file.path;
                    });
                  });
                },
              ),
              // Parte que insere o icone para tirar uma foto com a câmera
              GestureDetector( 
                child: Container(
                  child: Icon(Icons.photo_camera),
                ),
                onTap: (){
                  ImagePicker.pickImage(source: ImageSource.camera).then((file){
                    // Abriu a câmera e não tirou nenhuma foto
                    if(file == null) return;
                    setState(() {
                      // Se não; vai pegar o caminho da foto que o nosso usuário tirou
                      _editedContact.img = file.path;
                    });
                  });
                },
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (text){
                  _userEdited = true;
                  setState(() {
                    // Atualiza o appBar
                    _editedContact.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                onChanged: (text){
                  _userEdited = true;
                  _editedContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Phone"),
                onChanged: (text){
                  _userEdited = true;
                  _editedContact.phone = text;
                },
                keyboardType: TextInputType.phone,
              )
            ],
          ),
        ),
      ),
    )
    );
  }

  Future<bool> _requestPop(){
    // Se editou um campo (_userEdited)
    if(_userEdited){
      showDialog(context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Descartar alterações?"),
            content: Text("Se sair as alterações serão perdidas."),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: (){
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("Sim"),
                onPressed:(){
                  Navigator.pop(context);
                  // mais um pop ara sair do contact page
                  Navigator.pop(context);
                } ,
              ),
            ],
          );
        }
      );
      return Future.value(false);
      // Se o usuário não digitou
    } else {
      return Future.value(true);
    }
  }

}