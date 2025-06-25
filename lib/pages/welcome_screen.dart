// import 'package:flutter/material.dart';
// import 'package:harvestly/core/services/auth/auth_service.dart';

// import '../utils/app_routes.dart';

// class WelcomeScreen extends StatelessWidget {
//   const WelcomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.primary,
//       body: Padding(
//         padding: const EdgeInsets.all(14),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Bem vindo!',
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//                 Text(
//                   'Ajude-nos a conhecê-lo melhor, como pretende juntar-se a nós?',
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 InkWell(
//                   onTap: () {
//                     AuthService().setLoggingInState(false);
//                     AuthService().setProducerState(true);
//                     Navigator.of(context).pushNamed(AppRoutes.AUTH_PAGE);
//                   },
//                   child: Card(
//                     elevation: 1,
//                     color: Theme.of(context).colorScheme.surface,
//                     child: SizedBox(
//                       width: MediaQuery.of(context).size.width * 0.4,
//                       height: MediaQuery.of(context).size.height * 0.3,
//                       child: Column(
//                         children: [
//                           Expanded(
//                             child: Image.asset(
//                               'assets/images/produtor.png',
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: () {},
//                             child: Text(
//                               "Produtor",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 22,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 InkWell(
//                   onTap: () {
//                     AuthService().setLoggingInState(false);
//                     AuthService().setProducerState(false);
//                     Navigator.of(context).pushNamed(AppRoutes.AUTH_PAGE);
//                   },
//                   child: Card(
//                     elevation: 1,
//                     color: Theme.of(context).colorScheme.surface,
//                     child: SizedBox(
//                       width: MediaQuery.of(context).size.width * 0.4,
//                       height: MediaQuery.of(context).size.height * 0.3,
//                       child: Column(
//                         children: [
//                           Expanded(
//                             child: Image.asset(
//                               'assets/images/consumidor.png',
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: () {},
//                             child: Text(
//                               "Consumidor",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 22,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Stack(
//               alignment: Alignment.center,
//               children: [
//                 Divider(
//                   color: Theme.of(context).colorScheme.secondary,
//                   thickness: 2,
//                 ),
//                 Center(
//                   child: SizedBox(
//                     width: MediaQuery.of(context).size.width * 0.3,
//                     child: Image.asset(
//                       'assets/images/simpleLogo.png',
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   "Já tem conta?",
//                   style: TextStyle(
//                     color: Theme.of(context).colorScheme.secondary,
//                     fontSize: 18,
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     AuthService().setLoggingInState(true);
//                     Navigator.of(context).pushNamed(AppRoutes.AUTH_PAGE);
//                   },
//                   child: Text(
//                     "Entre aqui.",
//                     style: TextStyle(
//                       color: Theme.of(context).colorScheme.secondary,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w900,
//                       decoration: TextDecoration.underline,
//                       decorationColor: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../core/services/auth/auth_service.dart';
import '../utils/app_routes.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  bool _animating = false;
  final Set<int> clickedIndexes = {};

  bool _backgroundChanged = false;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _animating = false;
        });
      }
    });
  }

  void onFeatureClicked(int index) {
    setState(() {
      clickedIndexes.add(index);

      if (clickedIndexes.length == 3) {
        _animating = true;
        _controller.forward();
        clickedIndexes.clear();

        _backgroundChanged = !_backgroundChanged;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    final Gradient backgroundGradient =
        _backgroundChanged
            ? const LinearGradient(
              colors: [Color(0xFF8E24AA), Color(0xFFCE93D8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
            : const LinearGradient(
              colors: [Color(0xFF2E8B57), Color(0xFF43A047)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            ClipPath(
              clipper: WaveClipper(),
              child: Container(
                constraints: BoxConstraints(minHeight: size.height * 0.4),
                width: double.infinity,
                decoration: BoxDecoration(gradient: backgroundGradient),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 90,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double maxTitleFont = constraints.maxHeight * 0.4;
                    double maxSubtitleFont = constraints.maxHeight * 0.07;
                    double maxDescFont = constraints.maxHeight * 0.045;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              'Hello Farmer',
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              minFontSize: 30,
                              maxFontSize: maxTitleFont.clamp(30, 70),
                            ),
                            AutoSizeText(
                              'O futuro do agricultor',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              minFontSize: 25,
                              maxFontSize: maxSubtitleFont.clamp(25, 34),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        AutoSizeText(
                          'Registe-se agora e descubra produtos ou venda na sua zona!',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          minFontSize: 14,
                          maxFontSize: maxDescFont.clamp(14, 22),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: size.height * 0.40),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:
                          List.generate(3, (index) {
                            final iconsData = [
                              Icons.shopping_cart_outlined,
                              Icons.eco_outlined,
                              Icons.emoji_nature_outlined,
                            ];
                            final texts = [
                              'Venda de produtos',
                              'Produtores e consumidores',
                              'Produtos biológicos',
                            ];

                            return Expanded(
                              child: GestureDetector(
                                onTap: () => onFeatureClicked(index),
                                child: ScaleTransition(
                                  scale:
                                      _animating
                                          ? _scaleAnimation
                                          : const AlwaysStoppedAnimation(1.0),
                                  child: FeatureIcon(
                                    icon: iconsData[index],
                                    text: texts[index],
                                  ),
                                ),
                              ),
                            );
                          }).expand((widget) sync* {
                            yield widget;
                            if (widget != 2) yield const SizedBox(width: 8);
                          }).toList(),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: size.height * 0.45,
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(36),
                          topRight: Radius.circular(36),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: BigOptionCard(
                                  image: 'assets/images/produtor.png',
                                  title: 'Produtor',
                                  subtitle: 'Venda o que cultiva da sua quinta',
                                  color: theme.colorScheme.surface,
                                  isProducer: true,
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: BigOptionCard(
                                  image: 'assets/images/consumidor.png',
                                  title: 'Consumidor',
                                  subtitle:
                                      'Encontre os melhores produtos locais',
                                  color: theme.colorScheme.surface,
                                  isProducer: false,
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Divider(thickness: 1.5),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: SizedBox(
                                      width: 60,
                                      child: Image.asset(
                                        'assets/images/logo_green2.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    child: Divider(thickness: 1.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: AutoSizeText(
                                    "Já tem conta?",
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.tertiaryFixed,
                                      fontSize: 17,
                                    ),
                                    maxLines: 1,
                                    minFontSize: 12,
                                    maxFontSize: 18,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    AuthService().setLoggingInState(true);
                                    Navigator.of(
                                      context,
                                    ).pushNamed(AppRoutes.AUTH_PAGE);
                                  },
                                  child: AutoSizeText(
                                    "Entre aqui.",
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.tertiaryFixed,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      decoration: TextDecoration.underline,
                                    ),
                                    maxLines: 1,
                                    minFontSize: 12,
                                    maxFontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BigOptionCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final Color color;
  final bool isProducer;

  const BigOptionCard({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isProducer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        AuthService().setLoggingInState(false);
        AuthService().setProducerState(isProducer);
        Navigator.of(context).pushNamed(AppRoutes.AUTH_PAGE);
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: color,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(image, width: 80, height: 80, fit: BoxFit.contain),
              const SizedBox(height: 10),
              AutoSizeText(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
                maxLines: 1,
                minFontSize: 14,
                maxFontSize: 22,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              AutoSizeText(
                subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
                maxLines: 2,
                minFontSize: 10,
                maxFontSize: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureIcon extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureIcon({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          radius: 32,
          child: Icon(icon, color: theme.colorScheme.primary, size: 34),
        ),
        const SizedBox(height: 7),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            textAlign: TextAlign.center,
            softWrap: true,
          ),
        ),
      ],
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 30,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
