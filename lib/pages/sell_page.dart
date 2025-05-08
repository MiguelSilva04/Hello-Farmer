import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class SellPage extends StatefulWidget {
  const SellPage({super.key});

  @override
  State<SellPage> createState() => SellPageState();
}

class SellPageState extends State<SellPage> {
  final _formKey = GlobalKey<FormState>();
  String? title;
  String? description;
  String? location;
  List<String> deliveryOptions = [];
  String? unit = 'Kg';
  String? qty;
  String? price;
  String? name;
  String? phone;
  List<ImageProvider?> images = List.generate(6, (index) => null, growable: true);

  void toggleDelivery(String option, bool selected) {
    setState(() {
      if (selected) {
        deliveryOptions.add(option);
      } else {
        deliveryOptions.remove(option);
      }
    });
  }

  Widget imageBox(int index){
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${index + 1}ª imagem selecionada')),
        );
        //Selecionar imagem da galeria
        ImagePicker().pickImage(source: ImageSource.gallery).then((pickedFile) {
          if (pickedFile != null) {
            setState(() {
              images[index] = FileImage(File(pickedFile.path));
            });
          }
        });
      },
      child: Container(
        key: ValueKey(index),
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.grey[200],
        ),
        child: images[index] != null
            ? Image(image: images[index]!, fit: BoxFit.cover)
            : Icon(Icons.add_a_photo, color: Colors.grey[600]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Publicar Anúncio")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Quanto mais detalhado melhor!", style: TextStyle(fontSize: 14, color: Colors.grey)),

              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: "Título do anúncio"),
                onSaved: (val) => title = val,
              ),

              TextFormField(
                decoration: InputDecoration(labelText: "Descrição"),
                maxLines: 4,
                onSaved: (val) => description = val,
              ),

              SizedBox(height: 16),
              Text("Selecione:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("A primeira iamgem é a principal do anúncio, arrasta e larga as imagens para mudar as posições das mesmas"),
              ReorderableGridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                physics: NeverScrollableScrollPhysics(),
                onReorder: (oldIndex,newIndex) {
                  setState(() {
                    print('Reordering from $oldIndex to $newIndex');
                    if (newIndex > oldIndex) newIndex--;
                    final image = images.removeAt(oldIndex);
                    images.insert(newIndex, image);
                    print('Updated images list: $images');
                  });
                },
                children: List.generate(6, (index) => KeyedSubtree(
                  key: ValueKey(index),
                  child: imageBox(index),
                )),
              ),
              SizedBox(height: 16),
              Text("Categoria:", style: TextStyle(fontWeight: FontWeight.bold)),
              
              DropdownButtonFormField<String>(
                value: title,
                items: [
                  DropdownMenuItem(value: "Fruta", child: Text("Fruta")),
                  DropdownMenuItem(value: "Legumes", child: Text("Legumes")),
                  DropdownMenuItem(value: "Ervas", child: Text("Ervas")),
                  DropdownMenuItem(value: "Flores", child: Text("Flores")),
                ],
                onChanged: (val) => setState(() => title = val),
                decoration: InputDecoration(labelText: "Selecione uma categoria"),
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                dropdownColor: Colors.white,
              ),


              SizedBox(height: 16),
              Text("Localização:", style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                decoration: InputDecoration(labelText: "Freguesia ou código postal"),
                onSaved: (val) => location = val,
              ),


              SizedBox(height: 16),
              Text("Opções de entrega:", style: TextStyle(fontWeight: FontWeight.bold)),
              CheckboxListTile(
                title: Text("Entrega ao domicílio"),
                value: deliveryOptions.contains("domicilio"),
                onChanged: (val) => toggleDelivery("domicilio", val!),
              ),
              CheckboxListTile(
                title: Text("Recolha num local à escolha"),
                value: deliveryOptions.contains("recolha"),
                onChanged: (val) => toggleDelivery("recolha", val!),
              ),
              CheckboxListTile(
                title: Text("Entrega por transportadora"),
                value: deliveryOptions.contains("transportadora"),
                onChanged: (val) => toggleDelivery("transportadora", val!),
              ),

              SizedBox(height: 16),
              Text("Detalhes de Venda:", style: TextStyle(fontWeight: FontWeight.bold)),

              TextFormField(
                decoration: InputDecoration(labelText: "Quantidade mínima"),
                keyboardType: TextInputType.number,
                onSaved: (val) => qty = val,
              ),

              SizedBox(height: 16),
              Text("Unidade de medida:", style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text("Kg"),
                      value: "Kg",
                      groupValue: unit,
                      onChanged: (val) => setState(() => unit = val),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text("Unidade"),
                      value: "Unidade",
                      groupValue: unit,
                      onChanged: (val) => setState(() => unit = val),
                    ),
                  ),
                ],
              ),

              TextFormField(
                decoration: InputDecoration(labelText: "Preço"),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSaved: (val) => price = val,
              ),

              TextFormField(
                decoration: InputDecoration(labelText: "Nome"),
                onSaved: (val) => name = val,
              ),

              TextFormField(
                decoration: InputDecoration(labelText: "Número de telefone"),
                keyboardType: TextInputType.phone,
                onSaved: (val) => phone = val,
              ),

              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _formKey.currentState!.save();
                      //Pre visualizar
                    },
                    child: Text("Pré-visualizar"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(55, 164, 120, 1)),
                    onPressed: () {
                      _formKey.currentState!.save();
                      print("Publicar anúncio...");
                      // Publicar
                    },
                    child: Text("Publicar", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
