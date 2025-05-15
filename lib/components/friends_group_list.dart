import 'package:harvestly/core/models/client_user.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:harvestly/pages/profile_page.dart';

class FriendsGroupList extends StatefulWidget {
  final List<ClientUser> users;
  final void Function(ClientUser) inviteUser;
  final void Function(ClientUser)? removeUser;
  final void Function(ClientUser)? makeUserAdmin;
  final bool isJustListingUsers;
  final List<ClientUser>? admins;

  FriendsGroupList({
    required this.inviteUser,
    required this.users,
    required this.isJustListingUsers,
    this.removeUser,
    this.makeUserAdmin,
    this.admins,
    super.key,
  });

  @override
  State<FriendsGroupList> createState() => _FriendsGroupListState();
}

class _FriendsGroupListState extends State<FriendsGroupList> {
  Widget _showChatImage(String? image) {
    ImageProvider? provider;
    final uri = Uri.parse(image!);
    provider = NetworkImage(uri.toString());

    return CircleAvatar(backgroundImage: provider);
  }

  @override
  void initState() {
    super.initState();
    widget.users.sort((a, b) => a.firstName.compareTo(b.firstName));
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin =
        (widget.makeUserAdmin != null) && (widget.removeUser != null);
    final List<ClientUser> usersList = widget.users;
    return SingleChildScrollView(
      child: Card(
        color: Colors.grey[350],
        child: Container(
          constraints: BoxConstraints(maxHeight: widget.users.length * 60.0),
          child: ListView.builder(
            itemCount: usersList.length,
            itemBuilder:
                (ctx, i) => InkWell(
                  onTap:
                      (AuthService().currentUser!.id != usersList[i].id)
                          ? () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => ProfilePage(usersList[i]),
                            ),
                          )
                          : null,
                  child: Card(
                    child: ListTile(
                      leading: _showChatImage(usersList[i].imageUrl),
                      title: Text(
                        "${usersList[i].firstName} ${usersList[i].lastName}",
                      ),
                      trailing:
                          (AuthService().currentUser!.id == usersList[i].id ||
                                  (widget.admins != null &&
                                      widget.admins!
                                          .map((u) => u.id)
                                          .contains(usersList[i].id)))
                              ? Text("Administrador")
                              : (!widget.isJustListingUsers)
                              ? InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "${usersList[i].firstName} ${usersList[i].lastName} foi adicionada com sucesso ao grupo!",
                                      ),
                                    ),
                                  );
                                  widget.inviteUser(usersList[i]);
                                },
                                child: Icon(Icons.add_circle_rounded),
                              )
                              : (widget.isJustListingUsers && isAdmin)
                              ? SizedBox(
                                width: 100,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        widget.makeUserAdmin!(usersList[i]);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "${usersList[i].firstName} ${usersList[i].lastName} tornou se administrador do grupo!",
                                            ),
                                          ),
                                        );
                                      },

                                      icon: Icon(
                                        Icons.add_moderator_outlined,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (ctx) => AlertDialog(
                                                title: Text("Aviso"),
                                                content: Text(
                                                  "Tem a certeza que pretende remover o utilizador do grupo?",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () =>
                                                            Navigator.of(
                                                              context,
                                                            ).pop(),
                                                    child: Text("Não"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      widget.removeUser!(
                                                        usersList[i],
                                                      );
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            "Utilizador removido com sucesso!",
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Text("Sim"),
                                                  ),
                                                ],
                                              ),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : null,
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
