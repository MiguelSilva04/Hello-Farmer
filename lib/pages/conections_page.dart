import 'package:harvestly/core/models/app_user.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'profile_page.dart';

class ConectionsPage extends StatefulWidget {
  @override
  State<ConectionsPage> createState() => _ConectionsPageState();
}

class _ConectionsPageState extends State<ConectionsPage> {
  final currentUser = AuthService().currentUser!;
  List<AppUser> allUsers = [];
  List<AppUser> friends = [];
  String searchQuery = '';
  bool _isSearching = false;
  final searchBoxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    allUsers = AuthService().users;
    friends = [];
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers =
        allUsers
            .where(
              (user) =>
                  user.id != currentUser.id &&
                  user.firstName.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ),
            )
            .toList();
    filteredUsers.sort((a, b) => a.firstName.compareTo(b.firstName));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchBoxController,
            decoration: InputDecoration(
              hintText: 'Procurar utilizadores...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffix: InkWell(
                onTap:
                    () => setState(() {
                      _isSearching = false;
                      searchBoxController.clear();
                      FocusScope.of(context).unfocus();
                    }),
                child: Icon(Icons.close),
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
                _isSearching = true;
              });
            },
          ),
        ),
        if (_isSearching)
          Expanded(
            child: ListView(
              children:
                  filteredUsers.map((user) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user.imageUrl),
                        ),
                        title: Text(user.firstName),
                        trailing: Icon(Icons.change_circle),
                      ),
                    );
                  }).toList(),
            ),
          ),
        if (friends.length == 0)
          Center(
            child: Text(
              "Ainda sem conexões! Procura por pessoas na aplicação para formares novas amizades!😄",
              textAlign: TextAlign.center,
            ),
          ),
        if (friends.isNotEmpty && !_isSearching) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Conexões:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                friends.sort((a, b) => a.firstName.compareTo(b.firstName));
                final friend = friends[index];

                return ListTile(
                  onTap:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => ProfilePage(friends[index]),
                        ),
                      ),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(friend.imageUrl),
                  ),
                  title: Text(friend.firstName),
                  subtitle: Row(
                    children: [
                      Icon(FontAwesomeIcons.solidFaceGrinHearts),
                      const SizedBox(width: 5),
                      Text('Amigos'),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
