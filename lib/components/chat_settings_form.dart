import 'dart:io';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/models/chat.dart';
import '../core/models/app_user.dart';
import '../core/services/chat/chat_service.dart';
import 'friends_group_list.dart';
import 'user_image_picker.dart';

class ChatSettingsForm extends StatefulWidget {
  final bool isAdmin;

  const ChatSettingsForm({required this.isAdmin, super.key});

  @override
  State<ChatSettingsForm> createState() => _ChatSettingsFormState();
}

class _ChatSettingsFormState extends State<ChatSettingsForm> {
  final _formKey = GlobalKey<FormState>();
  final _chatData = Chat();
  late Chat currentChat;
  late List<AppUser> users;
  List<AppUser> usersInTheChat = [];
  List<AppUser> usersNotInTheChat = [];
  List<AppUser> usersAdmins = [];

  bool _showInviteUsers = false;
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

  void inviteFriend(AppUser user) {
    provider!.addMemberToChat(user.id);
    setState(() {
      usersInTheChat.add(user);
      usersNotInTheChat.remove(user);
    });
    provider!.updateCurrentUsers(usersInTheChat);
  }

  void removeUser(AppUser user) {
    provider!.removeMemberFromChat(user.id, currentChat.id);
    setState(() {
      usersInTheChat.remove(user);
      usersNotInTheChat.add(user);
    });
    provider!.updateCurrentUsers(usersInTheChat);
  }

  void makeUserAdmin(AppUser user) async {
    await provider!.makeUserAdmin(user.id);
    setState(() {
      usersAdmins.add(user);
    });
  }

  Future<void> loadData() async {
    setState(() => _isLoading = true);

    try {
      users = await AuthService().users;
      await provider!.loadCurrentChatMembersAndAdmins();
      setState(() {
        usersInTheChat =
            provider!.currentChat!.membersIds
                .map((id) => users.firstWhere((user) => user.id == id))
                .toList();
        usersAdmins =
            provider!.currentChat!.adminIds!
                .map((id) => users.firstWhere((user) => user.id == id))
                .toList();
        // final curUserFriendsList = AuthService().currentUser?.friendsIds ?? [];
        final curUserFriendsList = [];

        if (curUserFriendsList != null) {
          usersNotInTheChat =
              users
                  .where(
                    (u) =>
                        curUserFriendsList.contains(u.id) &&
                        !usersInTheChat.any(
                          (userInChat) => userInChat.id == u.id,
                        ),
                  )
                  .toList();
        } else {
          usersNotInTheChat = [];
        }
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
        ? _showInviteUsers
            ? Column(
              children: [
                Text(
                  usersNotInTheChat.isEmpty
                      ? "Não há mais pessoas para adicionar!"
                      : "Adicionar pessoas:",
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                FriendsGroupList(
                  users: usersNotInTheChat,
                  inviteUser: inviteFriend,
                  isJustListingUsers: false,
                ),
                TextButton(
                  onPressed: () => setState(() => _showInviteUsers = false),
                  child: const Text("Voltar"),
                ),
              ],
            )
            : Form(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Participantes do grupo:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (usersNotInTheChat.isNotEmpty)
                            TextButton.icon(
                              onPressed:
                                  () => setState(() => _showInviteUsers = true),
                              icon: const Icon(Icons.person_add),
                              label: const Text("Adicionar"),
                            ),
                        ],
                      ),
                      FriendsGroupList(
                        users: usersInTheChat,
                        isJustListingUsers: true,
                        inviteUser: inviteFriend,
                        removeUser: widget.isAdmin ? removeUser : null,
                        makeUserAdmin: widget.isAdmin ? makeUserAdmin : null,
                        admins: usersAdmins,
                      ),
                    ],
                  ),
                ),
              ),
            )
        : Center(child: CircularProgressIndicator());
  }
}
