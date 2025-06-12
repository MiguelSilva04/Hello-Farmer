import 'dart:io';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/models/chat.dart';
import '../core/models/app_user.dart';
import '../core/services/chat/chat_service.dart';
import 'user_image_picker.dart';

class ChatSettingsForm extends StatefulWidget {
  final bool isAdmin;

  const ChatSettingsForm({required this.isAdmin, super.key});

  @override
  State<ChatSettingsForm> createState() => _ChatSettingsFormState();
}

class _ChatSettingsFormState extends State<ChatSettingsForm> {
  final _formKey = GlobalKey<FormState>();
  final _chatData = ChatData();
  late Chat currentChat;
  late List<AppUser> users;
  AppUser? consumer;
  AppUser? producer;

  bool _isLoading = false;
  bool _buttonAvailable = false;
  bool _isDataLoaded = false;

  ChatService? provider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of(context, listen: false);
    currentChat = provider!.currentChat!;
    loadData();
  }

  void _handleImagePick(File image) {
    _chatData.imageUrl = image.path;
    setState(() => _buttonAvailable = true);
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    if (!_formKey.currentState!.validate()) {
      setState(() => _isLoading = false);
      return;
    }

    _chatData.localImageFile =
        _chatData.imageUrl != null ? File(_chatData.imageUrl!) : null;

    await provider!.updateChatInfo(_chatData);

    if (_chatData.name != null) currentChat.setName(_chatData.name!);
    if (_chatData.description != null)
      currentChat.setDescription(_chatData.description!);

    setState(() => _isLoading = false);
    Navigator.of(context).pop();
  }

  Future<void> loadData() async {
    setState(() => _isLoading = true);

    try {
      users = await AuthService().users;
      await provider!.loadCurrentChatMembersAndAdmins();
      setState(() {
        consumer = users.firstWhere(
          (user) => user.id == provider!.currentChat!.consumerId,
        );
        producer = users.firstWhere(
          (user) => user.id == provider!.currentChat!.producerId,
        );

        _isDataLoaded = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar dados: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isDataLoaded
        ? Form(
          key: _formKey,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  UserImagePicker(
                    onImagePick: _handleImagePick,
                    avatarRadius: 80,
                    image: File(currentChat.imageUrl!),
                    isSignup: true,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: currentChat.name,
                    decoration: const InputDecoration(
                      labelText: "Nome do grupo",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (name) {
                      _chatData.name = name;
                      setState(() => _buttonAvailable = true);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: currentChat.description,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Descrição do grupo",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (description) {
                      _chatData.description = description;
                      setState(() => _buttonAvailable = true);
                    },
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                        onPressed: _buttonAvailable ? _submit : null,
                        icon: const Icon(Icons.save),
                        label: const Text("Atualizar"),
                      ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        )
        : Center(child: CircularProgressIndicator());
  }
}
