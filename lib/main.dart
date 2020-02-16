/* 

As versões recomendadas para este app são:

sqflite: ^1.1.5
url_launcher: ^5.0.2
image_picker: ^0.6.0+3
Guarde-as que logo você irá utilizá-las!

Mas atenção: caso não utilize as versões sugeridas acima, há o risco do seu app não funcionar, 
e nesse caso não conseguiremos te ajudar. Por isso, utilize as versões sugeridas.

---------------------------------------------------------------------------------------

Recentemente, o plugin ImagePicker começou a exigir que as permissões de Câmera e Galeria no iOS fossem identificadas. Pra fazer isso, basta adicionar apenas 6 linhas ao seu info.plist, que fica localizado na pasta ios/Runner.

Ao final do arquivo, antes do </dict>, cole as 6 linhas, como demonstrado abaixo:

    <key>NSPhotoLibraryUsageDescription</key>        // COLE ESTA E AS OUTRAS 5 LINHAS ABAIXO
    <string>Tirar fotos dos contatos.</string>
    <key>NSCameraUsageDescription</key>
    <string>Selecionar uma foto de contato da galeria.</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>Tirar fotos dos contatos.</string>
</dict>                                              // NÃO COLE ESTA LINHA, ELA ESTÁ APENAS PARA REFERÊNCIA!


*/

import 'package:agenda_de_contatos/ui/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: HomePage(),
    debugShowCheckedModeBanner: false,
  ));
}