import 'dart:async';

import 'package:flutter/material.dart';
import 'package:harvestly/components/consumer/offers_page.dart';
import 'package:harvestly/components/consumer/shopping_cart_page.dart';
import 'package:harvestly/components/create_store.dart';
import 'package:harvestly/core/models/app_user.dart';
import 'package:harvestly/core/models/consumer_user.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/services/auth/notification_notifier.dart';
import 'package:harvestly/core/services/other/bottom_navigation_notifier.dart';
import 'package:harvestly/core/services/other/manage_section_notifier.dart';
import 'package:harvestly/core/services/other/search_notifier.dart';
import 'package:harvestly/pages/loading_page.dart';
import 'package:harvestly/pages/search_results.dart';
import 'package:provider/provider.dart';
import '../components/consumer/explore_page.dart';
import '../components/consumer/home_page.dart';
import '../components/consumer/map_page.dart';
import '../components/consumer/orders_page.dart';
import '../core/services/auth/auth_notifier.dart';
import '../core/services/auth/store_service.dart';
import '../components/producer/manage_page.dart';
import '../core/services/chat/chat_list_notifier.dart';
import '../core/services/chat/chat_service.dart';
import '../utils/app_routes.dart';
import '../components/producer/home_page.dart';
import '../components/producer/sell_page.dart';
import '../components/producer/orders_page.dart';
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
  late AuthNotifier authProvider;
  String _searchQuery = "";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthNotifier>(context, listen: false);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacityAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSearch(AppUser user) {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        context.read<SearchNotifier>().clear();
        _searchQuery = "";
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
    final List<Widget> _producerPages = [
      ProducerHomePage(),
      OrdersProducerPage(),
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

    Future<AppUser> _initializeApp() async {
      final user = await authProvider.loadUser();

      final storeService = Provider.of<StoreService>(context, listen: false);
      await storeService.loadStores();

      await authProvider.loadAllUsers();

      final notificationNotifier = Provider.of<NotificationNotifier>(
        context,
        listen: false,
      );
      if (user.isProducer) {
        notificationNotifier.setupFCM(
          id: (user as ProducerUser).stores[authProvider.selectedStoreIndex].id,
          isProducer: true,
        );
        notificationNotifier.listenToNotifications(
          id: user.stores[authProvider.selectedStoreIndex].id,
          isProducer: true,
        );
      } else {
        notificationNotifier.setupFCM(id: user.id, isProducer: false);
        notificationNotifier.listenToNotifications(
          id: user.id,
          isProducer: false,
        );
      }

      final chatService = Provider.of<ChatService>(context, listen: false);
      final currentChat = chatService.currentChat;
      if (currentChat != null) {
        chatService.listenToCurrentChatMessages((messages) {
          if (messages.isNotEmpty) {
            final lastMessage = messages.first;
            final notifier = Provider.of<ChatListNotifier>(
              context,
              listen: false,
            );
            notifier.updateLastMessage(currentChat.id, lastMessage);
          }
        });
      }

      return user;
    }

    return FutureBuilder(
      future: _initializeApp(),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) return LoadingPage();

        final user = snapshot.data!;
        _profileImageUrl = user.imageUrl;
        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: Row(
              children: [
                if (Provider.of<BottomNavigationNotifier>(
                      context,
                    ).currentIndex ==
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
              if ((user.isProducer &&
                      (user as ProducerUser).stores.length > 0) ||
                  (!user.isProducer))
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child:
                      _isSearching
                          ? Padding(
                            key: const ValueKey('searchBar'),
                            padding: const EdgeInsets.all(8),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.70,
                              child: TextField(
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: "Procurar...",
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => _toggleSearch(user),
                                  ),
                                ),
                                onChanged: (query) {
                                  _searchQuery = query;

                                  if (_debounce?.isActive ?? false)
                                    _debounce!.cancel();
                                  _debounce = Timer(
                                    const Duration(milliseconds: 300),
                                    () {
                                      context.read<SearchNotifier>().search(
                                        query,
                                        user.isProducer,
                                        context,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          )
                          : IconButton(
                            key: const ValueKey('searchIcon'),
                            icon: const Icon(Icons.search),
                            onPressed: () => _toggleSearch(user),
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
                      Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.NOTIFICATION_PAGE);
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
                              color:
                                  Theme.of(context).colorScheme.tertiaryFixed,
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
                              user.isProducer
                                  ? FontAwesomeIcons.buildingUser
                                  : FontAwesomeIcons.gift,
                              color:
                                  Theme.of(context).colorScheme.tertiaryFixed,
                            ),
                            SizedBox(width: 10),
                            Text(user.isProducer ? "Banca" : "Ofertas"),
                          ],
                        ),
                      ),
                      if (!user.isProducer)
                        PopupMenuItem(
                          value: "Notifications",
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Badge.count(
                                count: user.notifications?.length ?? 0,
                                child: Icon(
                                  Icons.notifications_none_rounded,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.secondaryFixed,
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
                                color:
                                    Theme.of(context).colorScheme.tertiaryFixed,
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
                              color:
                                  Theme.of(context).colorScheme.tertiaryFixed,
                            ),
                            SizedBox(width: 10),
                            Text("Definições"),
                          ],
                        ),
                      ),
                    ],
              ),
              Consumer<AuthNotifier>(
                builder: (context, userProvider, _) {
                  final user = userProvider.currentUser;
                  if (user == null) return SizedBox.shrink();

                  // Se for consumidor, mostra o carrinho
                  if (!user.isProducer) {
                    return InkWell(
                      onTap:
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => ShoppingCartPage(),
                            ),
                          ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Badge.count(
                          count:
                              (user as ConsumerUser)
                                  .shoppingCart
                                  ?.productsQty
                                  ?.length ??
                              0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Icon(Icons.shopping_cart_rounded),
                          ),
                        ),
                      ),
                    );
                  }

                  return Consumer<NotificationNotifier>(
                    builder: (context, notificationProvider, _) {
                      final count = notificationProvider.notifications.length;

                      return InkWell(
                        onTap:
                            () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.NOTIFICATION_PAGE),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Badge.count(
                            count: count,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Icon(Icons.notifications),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          body: FadeTransition(
            opacity: _opacityAnimation,
            child:
                _isSearching
                    ? Consumer<SearchNotifier>(
                      builder: (context, searchNotifier, _) {
                        return GlobalSearchResults(
                          filteredItems: searchNotifier.results,
                          query: _searchQuery,
                          onSelect: (item) {
                            setState(() {
                              _isSearching = false;
                            });
                            item.onTap();
                          },
                        );
                      },
                    )
                    : user is ProducerUser
                    ? user.stores.isEmpty
                        ? CreateStore(isFirstTime: true)
                        : _producerPages[Provider.of<BottomNavigationNotifier>(
                          context,
                        ).currentIndex]
                    : _consumerPages[Provider.of<BottomNavigationNotifier>(
                      context,
                    ).currentIndex],
          ),

          bottomNavigationBar:
              Provider.of<BottomNavigationNotifier>(context).currentIndex < 5
                  ? BottomNavigationBar(
                    selectedItemColor:
                        Theme.of(context).bottomAppBarTheme.color,
                    unselectedItemColor:
                        Theme.of(context).colorScheme.secondaryFixed,
                    currentIndex:
                        Provider.of<BottomNavigationNotifier>(
                          context,
                        ).currentIndex,
                    onTap: (index) {
                      if (index == 4 &&
                          Provider.of<BottomNavigationNotifier>(
                                context,
                                listen: false,
                              ).currentIndex ==
                              4) {
                        final manageNotifier =
                            Provider.of<ManageSectionNotifier>(
                              context,
                              listen: false,
                            );

                        manageNotifier.setIndex(0);

                        Provider.of<BottomNavigationNotifier>(
                          context,
                          listen: false,
                        ).setIndex(index);
                      } else {
                        Provider.of<BottomNavigationNotifier>(
                          context,
                          listen: false,
                        ).setIndex(index);
                      }
                    },
                    items:
                        user is ProducerUser && user.stores.isNotEmpty
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
      },
    );
  }
}
