//import 'dart:ffi';
//import 'package:flutter/gestures.dart';
import 'package:path/path.dart';
//import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
//import 'package:async/async.dart';


/* Helper: Classes que ajudarão a obter o meu contato */

// Definição das colunas da tabela
// O "final" garante que eu não vou poder modificar o valor das strings

//contactTable: Nome da minha tabela
final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

/*
 SINGLETON: Utilizando padrão sigleton, só podemos instanciar apenas um objeto dessa classe
 1 - Ter um contrutor privado: Nenhuma outra classe do sistema consegue instanciar a classe do singleton 
 2 - Ter um método público (getInstance): Garantimos que temos apenas um ponto global de acesso a classe, é aqui que colocamos a lógica para garantir que vai existir apenas um objeto intanciado
 3 - Ter um atributo estático da própria classe: Para podermos acesso o metodo getInstance estaticamente
 */
class ContactHelper {

  // Static: Essa é uma variável que só temos apenas uma na classe inteira, é uma variável da classe, e não do objeto
  // Final: A variável não vai ser alteravel
  // ContactHelper: Declarando um objeto da minha classe, dentro da minha própria classe
  // _instance: Nome da variável
  // ContactHelper.internal(): Estamos chamando um construtor interno

  // Quando eu declaro minha classe eu crio um objeto dela mesma: _instance
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  // Declarando o meu banco de dados
  // _db: O underline foi colocado porque eu não quero acesso o banco de fora da minha classe
  Database _db;

  // Inicializando o banco de dados
  Future<Database> get db async {
    // Se já tivermos inicializado o banco de dados
    if(_db != null){
      return _db;
    } else {
      // Então teremos que inicializar o banco de dados
      _db = await initDb();
      return _db;
    }
  }

  // Função para abrir um conexão com o banco de dados
  // async: Para podermos utilizar o comando await
  Future<Database> initDb() async {
    // Busca o local aonde o banco de dados é armazenado
    // O getDatabasesPath() não retorna o local instantâneamente, por isso utilizamos o await
    final databasesPath = await getDatabasesPath();
    // Pegar o arquivo do banco de dados 
    // contacts.db : nome do arquivo
    final path = join(databasesPath, "contactsnew.db");
    // Abrindo o banco de dados
    // onCreate: Função responsável por criar o banco na primeira vez que estamos abrindo ele
    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async {
      // Executar o código responsável por criar a nossa tabela de dados
      await db.execute(
        "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT,"
            "$phoneColumn TEXT, $imgColumn TEXT)"
      );
    });
  }

  // Salvar um contato
  Future<Contact> saveContact(Contact contact) async {
    // Obtendo o meu banco de dados
    Database dbContact = await db; 
    // Retorna o id quand eu salvar o contato
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  // Obtendo os dados do contato: Retorna um contato no futuro
  Future<Contact> getContact(int id) async {
    // Obtendo o meu banco de dados
    Database dbContact = await db; 
    // Retornando uma lista de mapas chamada "maps"
    List<Map> maps = await dbContact.query(contactTable,
      // Listando as colunas que eu quero receber
      columns: [idColumn,nameColumn,emailColumn,phoneColumn,imgColumn],
      // Regra para obter o contato
      // ? = O argumento será definido no where args
      where: "$idColumn = ?",
      whereArgs: [id]);
    // Verificando se me retornou realmente um contato
    if(maps.length > 0){
      // Retornando 1 mapa
      return Contact.fromMap(maps.first);
    } else {
      // Caso não encontrar um contato
      return null;
    }
  }

  // Retorna um future do tipo inteiro, pois o delete retorna um inteiro indicando se foi um sucesso ou não
  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(contactTable, 
        contact.toMap(), 
        where: "$idColumn = ?", 
        whereArgs: [contact.id]);
  }

  Future<List> getAllContacts() async {
    Database dbContact = await db;
    // Retorna uma lista de mapas
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    // Declarando uma lista de contatos
    List<Contact> listContact = List();
    // Para cada mapa, eu transformo em um contato e adiciono na lista de contatos
    for(Map m in listMap){
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  // Retorna quantidade de elementos da minha tabela
  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable "));
  }

  // Fecha a conexão com o banco de dados
  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }

}

// Essa classe define tudo o que o contato vai armazenar
class Contact {

  int id;
  String name;
  String email;
  String phone;
  // Local aonde a imagem estiver salva no dispositivo
  String img;

  // Contact com construtor
  Contact();

  // Construtor: Armazenamento de dados em formato de mapa
  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  // Função que retorna um mapa
  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    if(id != null){
      map[idColumn] = id;
    }
    return map;
  }

  // Quando eu der um print contato irá me retornar todas as infos do meu contato
  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img )";
  }

}