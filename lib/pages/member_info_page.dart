import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/models/chat_user.dart';

class MemberInfoPage extends StatefulWidget {
  final ClientUser user;

  const MemberInfoPage(this.user, {super.key});

  @override
  State<MemberInfoPage> createState() => _MemberInfoPageState();
}

class _MemberInfoPageState extends State<MemberInfoPage> {
  final curUser = AuthService().currentUser!;
  bool _isFriend = false;
  bool _isFriendsWithCurUser = false;
  String nickname = "Ainda sem nickname...";
  String status = "Sem status...";
  String? name;

  ImageProvider getBackgroundImage() {
    if (widget.user.backgroundUrl != null &&
        widget.user.backgroundUrl!.trim().isNotEmpty) {
      return NetworkImage(widget.user.backgroundUrl!);
    } else {
      return const AssetImage('assets/images/background_logo.png');
    }
  }

  Future<void> switchFriendState(BuildContext context) async {
    try {
      (_isFriend)
          ? await AuthService().removeFriend(widget.user.id)
          : await AuthService().addFriend(widget.user.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFriend
                ? "Tu e $name deixaram de ser amigos!😪"
                : "Tu e $name são agora amigos!😄",
          ),
        ),
      );
      setState(() => _isFriend = !_isFriend);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Ocorreu um erro!")));
    }
  }

  @override
  void initState() {
    super.initState();
    name =
        widget.user.nickname!.isNotEmpty
            ? widget.user.nickname
            : ("${widget.user.firstName} ${widget.user.lastName}");
    final userFriends = widget.user.friendsIds;
    if (userFriends != null)
      _isFriendsWithCurUser = userFriends.contains(
        AuthService().currentUser!.id,
      );

    _isFriend =
        (curUser.friendsIds != null &&
            curUser.friendsIds!.contains(widget.user.id));
    if (widget.user.nickname!.isNotEmpty)
      nickname = "~${widget.user.nickname!}";
    if (widget.user.status!.isNotEmpty) status = widget.user.status!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: getBackgroundImage(),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -60,
                  left: MediaQuery.of(context).size.width / 2 - 60,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => Scaffold(
                                backgroundColor: Colors.black,
                                appBar: AppBar(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                ),
                                body: Center(
                                  child: Hero(
                                    tag:
                                        'profile-image-${widget.user.imageUrl}',
                                    child: ClipOval(
                                      child: Image.network(
                                        widget.user.imageUrl,
                                        width: 400,
                                        height: 400,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: 'profile-image-${widget.user.imageUrl}',
                      child: ClipOval(
                        child: Image.network(
                          widget.user.imageUrl,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),
            Text(
              "${widget.user.firstName} ${widget.user.lastName}",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              '$nickname',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              status,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.message, color: Colors.white),
                  label: const Text('Enviar mensagem'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    if (_isFriend) {
                      showDialog(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              title: Text("Aviso"),
                              content: Text(
                                "Tem a certeza que pretende deixar de seguir $name?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text("Não"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    switchFriendState(context);
                                  },
                                  child: Text("Sim"),
                                ),
                              ],
                            ),
                      );
                    } else
                      switchFriendState(context);
                  },
                  icon: Icon(
                    (_isFriend && !_isFriendsWithCurUser)
                        ? FontAwesomeIcons.personHiking
                        : (_isFriend && _isFriendsWithCurUser)
                        ? FontAwesomeIcons.solidFaceGrinHearts
                        : FontAwesomeIcons.userPlus,
                  ),
                  label: Text(
                    (_isFriend && !_isFriendsWithCurUser)
                        ? 'A seguir'
                        : (_isFriend && _isFriendsWithCurUser)
                        ? 'Amigos'
                        : 'Adicionar',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sobre mim',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.user.aboutMe != null
                        ? 'Este utilizador ainda não escreveu nada sobre si... 😪'
                        : widget.user.aboutMe!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
