import 'package:flutter/material.dart';
import 'package:harvestly/components/consumer/offers_page.dart';
import 'package:harvestly/components/consumer/shopping_cart_page.dart';
import 'package:harvestly/core/models/app_user.dart';
import 'package:harvestly/core/models/consumer_user.dart';
import 'package:harvestly/core/services/other/bottom_navigation_notifier.dart';
import 'package:provider/provider.dart';
import '../components/consumer/explore_page.dart';
import '../components/consumer/home_page.dart';
import '../components/consumer/map_page.dart';
import '../components/consumer/orders_page.dart';
import '../core/services/auth/auth_service.dart';
import '../core/services/chat/chat_list_notifier.dart';
import '../components/producer/manage_page.dart';
import '../utils/app_routes.dart';
import '../components/producer/home_page.dart';
import '../components/producer/sell_page.dart';
import '../components/producer/sells_page.dart';
import '../components/producer/store_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'chat_list_page.dart';
import 'new_chat_page.dart';
import 'profile_page.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu>
    with SingleTickerProviderStateMixin {
  bool _isSearching = false;
  String _profileImageUrl = "";
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late AppUser user;

  @override
  void initState() {
    super.initState();
    user = AuthService().currentUser!;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacityAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = Provider.of<ChatListNotifier>(context, listen: false);
      notifier.clearChats();
      notifier.listenToChats();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        Provider.of<ChatListNotifier>(
          context,
          listen: false,
        ).setSearchQuery("");
      }
    });
  }

  void _navigateToPage(String route) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => _getPage(route),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _getPage(String route) {
    switch (route) {
      case AppRoutes.PROFILE_PAGE:
        return ProfilePage();
      case AppRoutes.NEW_CHAT_PAGE:
        return NewChatPage();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isProducer = user.isProducer;
    _profileImageUrl = user.imageUrl;

    final List<Widget> _producerPages = [
      ProducerHomePage(),
      SellsPage(),
      SellPage(),
      ChatListPage(),
      ManagePage(),
      StorePage(),
    ];

    final List<Widget> _consumerPages = [
      ConsumerHomePage(),
      OrdersPage(),
      ExplorePage(),
      ChatListPage(),
      MapPage(),
      OffersPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          children: [
            if (Provider.of<BottomNavigationNotifier>(context).currentIndex ==
                5)
              InkWell(
                onTap:
                    () => Provider.of<BottomNavigationNotifier>(
                      context,
                      listen: false,
                    ).setIndex(0),
                child: const Icon(Icons.arrow_back),
              ),
            if (!_isSearching)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Image.asset(
                  "assets/images/logo_android2.png",
                  height: 50,
                ),
              ),
          ],
        ),
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child:
                _isSearching
                    ? Padding(
                      key: const ValueKey(1),
                      padding: const EdgeInsets.all(8),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.70,
                        child: SearchBar(
                          autoFocus: true,
                          hintText: "Procurar...",
                          onChanged: (query) {
                            Provider.of<ChatListNotifier>(
                              context,
                              listen: false,
                            ).setSearchQuery(query);
                          },
                          trailing: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _isSearching = false;
                                });
                                Provider.of<ChatListNotifier>(
                                  context,
                                  listen: false,
                                ).setSearchQuery("");
                              },
                              icon: const Icon(Icons.close, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                    : IconButton(
                      key: const ValueKey(2),
                      icon: const Icon(Icons.search),
                      onPressed: _toggleSearch,
                    ),
          ),
          PopupMenuButton<String>(
            tooltip: "Opções",
            offset: const Offset(0, 50),
            icon:
                user.imageUrl.isNotEmpty
                    ? CircleAvatar(
                      backgroundImage: NetworkImage(_profileImageUrl),
                    )
                    : const Icon(Icons.account_circle),
            onSelected: (value) async {
              switch (value) {
                case "Notifications":
                  Navigator.of(context).pushNamed(AppRoutes.NOTIFICATION_PAGE);
                  break;
                case "Alt":
                  Provider.of<BottomNavigationNotifier>(
                    context,
                    listen: false,
                  ).setIndex(5);
                  break;
                case "Profile":
                  _navigateToPage(AppRoutes.PROFILE_PAGE);
                  break;
                case "Favorites":
                  Navigator.of(context).pushNamed(AppRoutes.FAVORITES_PAGE);
                  break;
                case "Settings":
                  Navigator.of(context).pushNamed(AppRoutes.SETTINGS_PAGE);
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: "Profile",
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.tertiaryFixed,
                        ),
                        SizedBox(width: 10),
                        Text("Perfil"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: "Alt",
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          FontAwesomeIcons.gift,
                          color: Theme.of(context).colorScheme.tertiaryFixed,
                        ),
                        SizedBox(width: 10),
                        Text(user.isProducer ? "Banca" : "Ofertas"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: "Notifications",
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Badge.count(
                          count: user.notifications!.length,
                          child: Icon(
                            Icons.notifications_none_rounded,
                            color: Theme.of(context).colorScheme.secondaryFixed,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text("Notificações"),
                      ],
                    ),
                  ),
                  if (!user.isProducer)
                    PopupMenuItem(
                      value: "Favorites",
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            FontAwesomeIcons.heart,
                            color: Theme.of(context).colorScheme.tertiaryFixed,
                          ),
                          SizedBox(width: 10),
                          Text("Favoritos"),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: "Settings",
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          Icons.settings,
                          color: Theme.of(context).colorScheme.tertiaryFixed,
                        ),
                        SizedBox(width: 10),
                        Text("Definições"),
                      ],
                    ),
                  ),
                ],
          ),
          if (!user.isProducer)
            InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => ShoppingCartPage())),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Badge.count(
                  count:
                      (user as ConsumerUser).shoppingCart.productsQty?.length ??
                      0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Icon(Icons.shopping_cart_rounded),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _opacityAnimation,
        child:
            isProducer
                ? _producerPages[Provider.of<BottomNavigationNotifier>(
                  context,
                ).currentIndex]
                : _consumerPages[Provider.of<BottomNavigationNotifier>(
                  context,
                ).currentIndex],
      ),
      bottomNavigationBar:
          Provider.of<BottomNavigationNotifier>(context).currentIndex < 5
              ? BottomNavigationBar(
                selectedItemColor: Theme.of(context).bottomAppBarTheme.color,
                unselectedItemColor:
                    Theme.of(context).colorScheme.secondaryFixed,
                currentIndex:
                    Provider.of<BottomNavigationNotifier>(context).currentIndex,
                onTap: (index) {
                  Provider.of<BottomNavigationNotifier>(
                    context,
                    listen: false,
                  ).setIndex(index);
                },
                items:
                    isProducer
                        ? const [
                          BottomNavigationBarItem(
                            icon: Icon(Icons.home),
                            label: "Início",
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(FontAwesomeIcons.fileInvoiceDollar),
                            label: "Vendas",
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.add_circle),
                            label: "Vender",
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.message_rounded),
                            label: "Mensagens",
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.manage_accounts),
                            label: "Gestão",
                          ),
                        ]
                        : const [
                          BottomNavigationBarItem(
                            icon: Icon(Icons.home),
                            label: "Início",
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(FontAwesomeIcons.boxOpen),
                            label: "Encomendas",
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.search),
                            label: "Explorar",
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.message_rounded),
                            label: "Mensagens",
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.map_rounded),
                            label: "Mapa",
                          ),
                        ],
              )
              : null,
    );
  }
}
