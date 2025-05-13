import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/auth/auth_service.dart';
import '../core/services/chat/chat_list_notifier.dart';
import '../components/producer/settings_page.dart';
import '../utils/app_routes.dart';
import '../components/producer/home_page.dart';
import '../components/producer/sell_page.dart';
import '../components/producer/sells_page.dart';
import '../components/producer/store_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isSearching = false;
  // String _profileImageUrl = "";
  // bool _isProducer = AuthService().isProducer;

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isSearching = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // _profileImageUrl = AuthService().currentUser?.imageUrl ?? "";
    _selectedIndex = 0;

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

  // void _navigateToPage(String route) {
  //   Navigator.of(context).push(
  //     PageRouteBuilder(
  //       pageBuilder: (_, __, ___) => _getPage(route),
  //       transitionsBuilder: (_, animation, __, child) {
  //         return FadeTransition(opacity: animation, child: child);
  //       },
  //     ),
  //   );
  // }

  // Widget _getPage(String route) {
  //   switch (route) {
  //     case AppRoutes.PROFILE_PAGE:
  //       return ProfilePage();
  //     case AppRoutes.NEW_CHAT_PAGE:
  //       return NewChatPage();
  //     default:
  //       return Container();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomePage(),
      SellsPage(),
      SellPage(),
      StorePage(),
      SettingsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        // title: Text("Harvestly", style: TextStyle(fontFamily: "Barriecito")),
        title: Image.asset("assets/images/logo_android2.png", height: 45),
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
                        width: MediaQuery.of(context).size.width * 0.7,
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
                              icon: Icon(Icons.close, color: Colors.grey),
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
          IconButton(
            onPressed:
                () => Navigator.of(
                  context,
                ).pushNamed(AppRoutes.NOTIFICATION_PAGE),
            icon: Badge.count(
              count: 1,
              child: Icon(Icons.notifications_none_rounded),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          //   child: InkWell(
          //     onTap: () => _navigateToPage(AppRoutes.PROFILE_PAGE),
          //     child:
          //         AuthService().currentUser != null
          //             ? CircleAvatar(
          //               backgroundImage: NetworkImage(_profileImageUrl),
          //             )
          //             : Container(),
          //   ),
          // ),
          IconButton(
            onPressed: () async {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                final chatNotifier = context.read<ChatListNotifier>();
                chatNotifier.clearChats();
                await AuthService().logout();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.AUTH_OR_APP_PAGE,
                  (route) => false,
                );
              });
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      // floatingActionButton:
      //     _selectedIndex == 0
      //         ? FloatingActionButton(
      //           backgroundColor: Theme.of(context).colorScheme.surface,
      //           foregroundColor:
      //               Theme.of(context).floatingActionButtonTheme.foregroundColor,
      //           onPressed: () => _navigateToPage(AppRoutes.NEW_CHAT_PAGE),
      //           child: const Icon(Icons.add),
      //         )
      //         : null,
      body: FadeTransition(
        opacity: _opacityAnimation,
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).bottomAppBarTheme.color,
        unselectedItemColor: Theme.of(context).colorScheme.secondaryFixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.fileInvoiceDollar),
            label: "Vendas",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: "Vender",
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.buildingUser),
            label: "Banca",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: "Gestão",
          ),
        ],
      ),
    );
  }
}
