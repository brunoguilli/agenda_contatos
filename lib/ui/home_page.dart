import 'dart:io';

import 'package:agenda_de_contatos/helpers/contact_helper.dart';
import 'package:agenda_de_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// enum = conjundo de constantes 
enum OrderOptions {orderaz, orderza}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // Como é uma classe singleton, só vai deixar eu instanciar apenas 1 objeto
  ContactHelper helper = ContactHelper();

  /*  
  // TESTE PARA MOSTRAR NO DEBUG OS DADOS DO BANCO
  @override
  void initState(){
    super.initState();

    Contact c = Contact();
    c.name = "Thiago";
    c.email = "Thiago@gmail.com";
    c.phone = "24353456";
    

    helper.saveContact(c);

    helper.getAllContacts().then((list){
      print(list);
    });
  } */

  List<Contact> contacts = List();

  // Quando o App iniciar, vamos carregar todos os contatos que já estão salvos
  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold: Biblioteca com alguns layouts prontos. Ex: Barra superior e botões
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          // o PopupMenuButton será do tipo OrderOptions que declaramos no início do código
          PopupMenuButton<OrderOptions>(
            // Vou retornar um PopupMenuEntry do tipo OrderOptions
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de A-Z"),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z-A"),
                value: OrderOptions.orderza,
              )
            ],
            onSelected: _orderList, 
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        // Especifica o tamanho da lista
        itemCount: contacts.length,
        itemBuilder: (context, index){
          return _contactCard(context, index);
        },
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index){
    // Utilizamos o GestureDetector porque o não conseguimos tocar em um card
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          // No Filho do padding vai o conteúdo
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    // Se imagem do contato difere de nulo  
                    image: contacts[index].img != null ? 
                      // Caso o contato possua uma imagem, carrega a própria
                      FileImage(File(contacts[index].img)):
                        /// Imagem padrão caso o contato não tenha salvado nenhuma imagem
                        // Importar a imagem no pubspec.yaml
                        AssetImage("images/person.png "),
                        // fit: BoxFit.cover - Caso a imagem fique retangular e não circular
                        fit: BoxFit.cover
                  ),
                ),
              ),
              // Flexible: Caso o nome ou e-mail retornado seja muito grande, o texto vai quebrar em uma próxima linha 
              Flexible(
                child: Padding(
                  // Espaçamento apenas na esquerda
                  padding: EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // ?? "" : Caso o contato não salve nenhum nome, então retorna um texto vazio
                      Text(contacts[index].name ?? "",
                        style: TextStyle(fontSize: 22.0,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(contacts[index].email ?? "",
                        style: TextStyle(fontSize: 18.0),
                      ),
                      Text(contacts[index].phone ?? "",
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      onTap: (){
        _showOptions(context,index);
      },
    );
  }

  void _showOptions(BuildContext context, int index){
    showModalBottomSheet(
      context: context, 
      builder: (context){
        return BottomSheet(
          onClosing: (){},
          builder: (context){
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text("Ligar",
                        style: TextStyle(color:Colors.red, fontSize: 20.0)
                      ),
                      onPressed: (){
                        // Incluir url_launcher no pubspec.yaml
                        launch("tel:${contacts[index].phone}");
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text("Editar",
                        style: TextStyle(color:Colors.red, fontSize: 20.0)
                      ),
                      onPressed: (){
                        // Fecha a janela de ligar, editar e excluir quando voltar da outra tela
                        Navigator.pop(context);
                        _showContactPage(contact: contacts[index]);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text("Excluir",
                        style: TextStyle(color:Colors.red, fontSize: 20.0)
                      ),
                      onPressed: (){
                        helper.deleteContact(contacts[index].id);
                        setState(() {
                          // Remove da minha lista
                          contacts.removeAt(index);
                          Navigator.pop(context);
                        });
                      },
                    ),
                  )
                ],
              ),
            );
          },
        );
      }
      );
  }

  // Exibe a tela ContactPage, enviando ou não um parâmetro
  // _showContactPage: Envia um contato ou cria um novo na próxima página
  //                   Retorna um contato da outra página que eu estava editando 
  void _showContactPage({Contact contact}) async {
  final recContact =  await Navigator.push(context, 
      MaterialPageRoute(builder: (context) => ContactPage(contact: contact,) )
    );
    if(recContact != null){
      
      // Se o retorno ( recContact ) for um contato que eu enviei ( contact )
      if(contact != null ){
        // Atualiza o contato que eu enviei
        await helper.updateContact(recContact);
      } else {
        // Recebeu um contato que não enviamos anteriormente
        await helper.saveContact(recContact);
      }
      // Atualiza a lista de contatos novamente
      _getAllContacts();
    }
  }  

  void _getAllContacts(){
    // Carrega os contatos e joga na list
    helper.getAllContacts().then((list){ 
      setState(() {
        // contacts recebe list 
        contacts = list;  
      });
    });
  }

  void _orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderaz:
        contacts.sort((a,b){
          // Compara o nome do contato a com o nome do contato b
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
      contacts.sort((a,b){
          // Compara o nome do contato a com o nome do contato b
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;  
    }
    setState(() {

    });
  }

}