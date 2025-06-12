import 'dart:io';

import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:harvestly/core/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../components/user_image_picker.dart';
import '../core/models/chat.dart';
import '../core/services/chat/chat_list_notifier.dart';

class NewChatPage extends StatefulWidget {
  const NewChatPage({super.key});

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  final _formKey = GlobalKey<FormState>();
  final _chatData = ChatData();
  bool _isLoading = false;

  void _handleImagePick(File image) {
    _chatData.imageUrl = image.path;
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() => _isLoading = false);
      return;
    }
    File image;
    if (_chatData.imageUrl != null) {
      image = File(_chatData.imageUrl!);
    } else {
      final byteData = await rootBundle.load('assets/images/group_image.png');
      final buffer = byteData.buffer;
      image = File('${(await getTemporaryDirectory()).path}/avatar.png')
        ..writeAsBytesSync(
          buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        );
    }
    _chatData.imageUrl = image.path;

    await ChatService()
        .createChat(
          _chatData.name!,
          _chatData.description!,
          File(_chatData.imageUrl!),
          AuthService().currentUser!.id,
          "POR DEFINIR"
        )
        .then((chat) {
          setState(() => _isLoading = false);
          Provider.of<ChatListNotifier>(context, listen: false).addChat(chat);
          Navigator.of(context).pop();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Criar Novo Grupo", style: TextStyle(fontSize: 30)),
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    UserImagePicker(
                      onImagePick: _handleImagePick,
                      avatarRadius: 100,
                      isSignup: false
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      onChanged: (name) => _chatData.name = name,
                      decoration: InputDecoration(
                        hintText: "Introduza o nome do grupo",
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'O nome precisa de ser preenchido.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      onChanged:
                          (description) => _chatData.description = description,
                      decoration: InputDecoration(
                        hintText: "Introduza a descrição do grupo",
                      ),
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'A descrição precisa de ser preenchida.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                          onPressed: _submit,
                          child: Text("Criar"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            foregroundColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
