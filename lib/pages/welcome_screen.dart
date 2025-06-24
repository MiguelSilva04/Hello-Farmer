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

import 'package:flutter/material.dart';

import '../core/services/auth/auth_service.dart';
import '../utils/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.47,
              width: double.infinity,
              color: const Color(0xFF2E8B57),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello Farmer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'O futuro do agricultor',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Registe-se agora e descrubra produtos ou venda na sua zona!',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.40,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Expanded(
                        child: FeatureIcon(
                          icon: Icons.shopping_cart_outlined,
                          text: 'Venda de produtos',
                        ),
                      ),
                      Expanded(
                        child: FeatureIcon(
                          icon: Icons.eco_outlined,
                          text: 'Produtores e consumidores',
                        ),
                      ),
                      Expanded(
                        child: FeatureIcon(
                          icon: Icons.emoji_nature_outlined,
                          text: 'Compra de produtos biológicos',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    padding: const EdgeInsets.all(30),
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
                                subtitle:
                                    'Seja produtor e venda o que cultiva diretamente da sua quinta',
                                color: Theme.of(context).colorScheme.surface,
                                isProducer: true,
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: BigOptionCard(
                                image: 'assets/images/consumidor.png',
                                title: 'Consumidor',
                                subtitle:
                                    'Encontre os melhores produtos na sua zona',
                                color: Theme.of(context).colorScheme.surface,
                                isProducer: false,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Já tem conta?",
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.tertiaryFixed,
                                fontSize: 18,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                AuthService().setLoggingInState(true);
                                Navigator.of(
                                  context,
                                ).pushNamed(AppRoutes.AUTH_PAGE);
                              },
                              child: Text(
                                "Entre aqui.",
                                style: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.tertiaryFixed,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  decoration: TextDecoration.underline,
                                  decorationColor:
                                      Theme.of(
                                        context,
                                      ).colorScheme.tertiaryFixed,
                                ),
                              ),
                            ),
                          ],
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
    return InkWell(
      onTap: () {
        AuthService().setLoggingInState(false);
        AuthService().setProducerState(isProducer);
        Navigator.of(context).pushNamed(AppRoutes.AUTH_PAGE);
      },
      child: Card(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          height: MediaQuery.of(context).size.height * 0.25,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(image, width: 100, height: 100, fit: BoxFit.contain),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Center(
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
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
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          radius: 40,
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 50,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.visible,
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
      size.height,
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
