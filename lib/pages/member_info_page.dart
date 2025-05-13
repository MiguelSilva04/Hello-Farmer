import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/models/chat_user.dart';
import '../core/models/purchase.dart';

class MemberInfoPage extends StatefulWidget {
  final ClientUser user;

  const MemberInfoPage(this.user, {super.key});

  @override
  State<MemberInfoPage> createState() => _MemberInfoPageState();
}

class _MemberInfoPageState extends State<MemberInfoPage> {
  final curUser = AuthService().currentUser!;
  String? name;

  ImageProvider getBackgroundImage() {
    if (widget.user.backgroundUrl != null &&
        widget.user.backgroundUrl!.trim().isNotEmpty) {
      return NetworkImage(widget.user.backgroundUrl!);
    } else {
      return const AssetImage('assets/images/background_logo.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Purchase> purchases = [
      Purchase(
        productName: 'Tomates Cherry',
        quantity: 35.5,
        unit: 'kg',
        price: 20.5,
        productImage: 'assets/images/producer/soil_analysis.jpg',
        producerId: "YScblT6Hx2RswFie1JKZX5hgn5F2",
      ),
      Purchase(
        productName: 'Alface Romana',
        quantity: 1,
        unit: 'unidade',
        price: 12.2,
        productImage: 'assets/images/producer/soil_analysis.jpg',
        producerId: "pxgE59JoVgaDHsxbOijA9VKMfKL2",
      ),
      Purchase(
        productName: 'Ovos Biológicos',
        quantity: 50,
        unit: 'unidades',
        price: 15,
        productImage: 'assets/images/producer/soil_analysis.jpg',
        producerId: "BABXdZ7vwKVFtpIjQQeri4mC71v2",
      ),
      Purchase(
        productName: 'Cenouras Baby',
        quantity: 30,
        unit: 'kg',
        price: 25.8,
        productImage: 'assets/images/producer/soil_analysis.jpg',
        producerId: "vjjzySrSiIYy1c3QcduZhlKglNh2",
      ),
    ];

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
              '📍Lisboa',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              widget.user.phone.startsWith('+351')
                  ? '+351 ' +
                      widget.user.phone
                          .substring(5)
                          .replaceAllMapped(
                            RegExp(r'.{1,3}'),
                            (match) => '${match.group(0)} ',
                          )
                          .trim()
                  : widget.user.phone
                      .replaceAllMapped(
                        RegExp(r'.{1,3}'),
                        (match) => '${match.group(0)} ',
                      )
                      .trim(),
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
              ],
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sobre mim',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.user.aboutMe != null
                            ? 'Ainda sem descrição...'
                            : widget.user.aboutMe!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Últimas compras',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children:
                        purchases.map((purchase) {
                          final user =
                              AuthService().users
                                  .where((u) => u.id == purchase.producerId)
                                  .first;

                          final producerName =
                              '${user.firstName} ${user.lastName}';
                          final producerImage = user.imageUrl;
                          return Card(
                            color: Theme.of(context).colorScheme.onTertiary,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      purchase.productImage,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          purchase.productName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Quantidade: ${purchase.unit == "kg" ? purchase.quantity.toStringAsFixed(2) : purchase.quantity.toStringAsFixed(0)} ${purchase.unit}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.tertiaryFixed,
                                          ),
                                        ),
                                        Text(
                                          '${purchase.price.toStringAsFixed(2)}€',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.tertiaryFixed,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap:
                                        () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    MemberInfoPage(user),
                                          ),
                                        ),
                                    child: Column(
                                      children: [
                                        const Text(
                                          "Produtor:",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        ClipOval(
                                          child: Image.network(
                                            producerImage,
                                            width: 35,
                                            height: 35,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: Text(
                                            producerName,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.tertiaryFixed,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
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
