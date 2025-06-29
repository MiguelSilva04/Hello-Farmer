import 'dart:async';
import 'package:flutter/material.dart';
import 'package:harvestly/components/consumer/offers_page.dart';
import 'package:harvestly/components/consumer/shopping_cart_page.dart';
import 'package:harvestly/core/models/app_user.dart';
import 'package:harvestly/core/models/consumer_user.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:harvestly/core/services/auth/notification_notifier.dart';
import 'package:harvestly/core/services/other/bottom_navigation_notifier.dart';
import 'package:harvestly/core/services/other/manage_section_notifier.dart';
import 'package:harvestly/core/services/other/search_notifier.dart';
import 'package:harvestly/pages/loading_page.dart';
import 'package:harvestly/pages/notification_page.dart';
import 'package:harvestly/pages/search_results.dart';
import 'package:provider/provider.dart';
import '../components/consumer/explore_page.dart';
import '../components/consumer/home_page.dart';
import '../components/consumer/map_page.dart';
import '../components/consumer/orders_page.dart';
import '../core/models/notification.dart';
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
import '../utils/presence_service.dart';
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
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late AppUser user;
  late AuthNotifier authNotifier;
  String _searchQuery = "";
  Timer? _debounce;
  bool _isLoading = false;
  bool _showLogo = true;

  @override
  void initState() {
    super.initState();
    authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    _initializeApp(false);
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

  Future<AppUser> _initializeApp(bool isRefreshing) async {
    if (!isRefreshing)
      setState(() {
        _isLoading = true;
      });
    user = await authNotifier.loadUser();
    final presenceService = PresenceService(user.id);
    presenceService.initializePresence();

    if (user.isProducer) {
      await authNotifier.updateSelectedStoreIndex();
    }

    final storeService = Provider.of<StoreService>(context, listen: false);
    await storeService.loadStores();

    await authNotifier.loadAllUsers();

    final notificationNotifier = Provider.of<NotificationNotifier>(
      context,
      listen: false,
    );

    if (user.isProducer) {
      final selectedStoreId =
          (authNotifier.currentUser as ProducerUser)
              .stores[authNotifier.selectedStoreIndex!]
              .id;

      await notificationNotifier.setupFCM(
        id: selectedStoreId,
        isProducer: true,
      );

      notificationNotifier.listenToNotifications(
        id: selectedStoreId,
        isProducer: true,
      );
    } else {
      await notificationNotifier.setupFCM(
        id: authNotifier.currentUser!.id,
        isProducer: false,
      );

      notificationNotifier.listenToNotifications(
        id: authNotifier.currentUser!.id,
        isProducer: false,
      );
    }
    final chatService = Provider.of<ChatService>(context, listen: false);
    final chatNotifier = Provider.of<ChatListNotifier>(context, listen: false);
    final currentChat = chatService.currentChat;
    chatNotifier.listenToChats();
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

    if (!isRefreshing)
      setState(() {
        _isLoading = false;
      });
    return user;
  }

  void _toggleSearch(AppUser user) async {
    if (_isSearching) {
      FocusScope.of(context).unfocus();

      await Future.delayed(const Duration(milliseconds: 350));
    }

    if (mounted) {
      setState(() {
        _isSearching = !_isSearching;

        if (_isSearching) {
          _showLogo = false;
        } else {
          Future.delayed(const Duration(milliseconds: 350), () {
            if (mounted) {
              setState(() {
                _showLogo = true;
              });
            }
          });
          context.read<SearchNotifier>().clear();
          _searchQuery = "";
        }
      });
    }
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
    ];

    final List<Widget> _consumerPages = [
      ConsumerHomePage(initializeApp: _initializeApp),
      OrdersPage(),
      ExplorePage(),
      ChatListPage(),
      MapPage(),
    ];

    return _isLoading
        ? const LoadingPage()
        : Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: Row(
              children: [
                if (!_isSearching && _showLogo)
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
              if ((user.isProducer) || (!user.isProducer)) ...[
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 200),
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child:
                        _isSearching
                            ? Padding(
                              key: const ValueKey('searchBar'),
                              padding: const EdgeInsets.all(8),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
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
                                      Duration(milliseconds: 300),
                                      () {
                                        if (mounted) {
                                          context.read<SearchNotifier>().search(
                                            query,
                                            user.isProducer,
                                            context,
                                          );
                                        }
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
                ),
                PopupMenuButton<String>(
                  tooltip: "Opções",
                  offset: const Offset(0, 50),
                  icon:
                      user.imageUrl.isNotEmpty
                          ? CircleAvatar(
                            backgroundImage: NetworkImage(user.imageUrl),
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (ctx) =>
                                    (user.isProducer)
                                        ? StorePage()
                                        : OffersPage(),
                          ),
                        );
                        break;
                      case "Profile":
                        _navigateToPage(AppRoutes.PROFILE_PAGE);
                        break;
                      case "Favorites":
                        Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.FAVORITES_PAGE);
                        break;
                      case "Settings":
                        Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.SETTINGS_PAGE);
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
                              user.isProducer
                                  ? Icon(
                                    FontAwesomeIcons.buildingUser,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.tertiaryFixed,
                                  )
                                  : StreamBuilder<List>(
                                    stream: AuthService().getUserOffersStream(
                                      user.id,
                                    ),
                                    builder: (context, snapshot) {
                                      final offersCount =
                                          snapshot.hasData
                                              ? snapshot.data!.length
                                              : 0;
                                      return Badge.count(
                                        count: offersCount,
                                        child: Icon(
                                          FontAwesomeIcons.gift,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.tertiaryFixed,
                                        ),
                                      );
                                    },
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
                                StreamBuilder<List<NotificationItem>>(
                                  stream: AuthService()
                                      .getUserNotificationsStream(user.id),
                                  builder: (context, snapshot) {
                                    final notificationsCount =
                                        snapshot.hasData
                                            ? snapshot.data!.length
                                            : 0;
                                    return Badge.count(
                                      count: notificationsCount,
                                      child: Icon(
                                        Icons.notifications_none_rounded,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondaryFixed,
                                      ),
                                    );
                                  },
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
                                Consumer<AuthNotifier>(
                                  builder: (context, auth, _) {
                                    final count = auth.favorites.length;

                                    return InkWell(
                                      onTap:
                                          () => Navigator.of(context).pushNamed(
                                            AppRoutes.NOTIFICATION_PAGE,
                                          ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Badge.count(
                                          count: count,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                            child: Icon(
                                              FontAwesomeIcons.heart,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.tertiaryFixed,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
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
              ],

              Consumer<AuthNotifier>(
                builder: (context, userProvider, _) {
                  final user = userProvider.currentUser;
                  if (user == null) return SizedBox.shrink();
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
                  if (user.isProducer)
                    return StreamBuilder<List<NotificationItem>>(
                      stream: AuthService().getUserNotificationsStream(
                        (user as ProducerUser)
                            .stores[authNotifier.selectedStoreIndex!]
                            .id,
                      ),
                      builder: (context, snapshot) {
                        final notificationsCount =
                            snapshot.hasData ? snapshot.data!.length : 0;
                        return InkWell(
                          onTap:
                              () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => NotificationsPage(),
                                ),
                              ),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Badge.count(
                              count: notificationsCount,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Icon(Icons.notifications),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  return Container();
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
                            FocusScope.of(context).unfocus();
                            setState(() {
                              _isSearching = false;
                            });
                            Future.microtask(() {
                              item.onTap();
                            });
                          },
                        );
                      },
                    )
                    : Consumer<AuthNotifier>(
                      builder: (context, authNotifier, _) {
                        final user = authNotifier.currentUser;

                        return user is ProducerUser
                            ? _producerPages[Provider.of<
                              BottomNavigationNotifier
                            >(context).currentIndex]
                            : _consumerPages[Provider.of<
                              BottomNavigationNotifier
                            >(context).currentIndex];
                      },
                    ),
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
                        user.isProducer
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
