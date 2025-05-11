import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final recomendationsList = [
    {
      "imageUrl": "assets/images/producer/irrigation.jpg",
      "recomendationTitle": "Sistema de Irrigação Inteligente",
      "recomendationSubTitle":
          "Otimize o uso de água com sensores e automação de irrigação.",
    },
    {
      "imageUrl": "assets/images/producer/soil_analysis.jpg",
      "recomendationTitle": "Análise de Solo",
      "recomendationSubTitle":
          "Serviços de análise laboratorial para melhorar a fertilidade do solo.",
    },
    {
      "imageUrl": "assets/images/producer/yara_fertilizantes.jpg",
      "recomendationTitle": "Desconto em Fertilizantes Yara",
      "recomendationSubTitle":
          "Aproveite 15% de desconto exclusivo para produtores da plataforma.",
    },
    {
      "imageUrl": "assets/images/producer/john_deere_tractor.jpg",
      "recomendationTitle": "Tratores John Deere em Promoção",
      "recomendationSubTitle":
          "Condições especiais de leasing para pequenos e médios produtores.",
    },
    {
      "imageUrl": "assets/images/producer/bayer_crop_protection.jpg",
      "recomendationTitle": "Proteção de Culturas Bayer",
      "recomendationSubTitle":
          "Campanha com kits de proteção para milho e soja com 10% off.",
    },
    {
      "imageUrl": "assets/images/producer/fertileasy_logo.jpg",
      "recomendationTitle": "FertilEasy – Fertilizante Ecológico",
      "recomendationSubTitle":
          "Ganhe amostras grátis do novo fertilizante 100% natural.",
    },
    {
      "imageUrl": "assets/images/producer/agro_insurance.jpg",
      "recomendationTitle": "Seguro Agrícola com Cobertura Total",
      "recomendationSubTitle":
          "Proteja sua produção com condições especiais para novos aderentes.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (recomendationsList.length / 3).ceil();
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          const Greetings(),
          const SizedBox(height: 30),
          Row(
            children: [
              Text(
                "Recomendado para si:",
                style: TextStyle(
                  fontSize: 22,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: totalPages,
              itemBuilder: (ctx, pageIndex) {
                final startIndex = pageIndex * 3;
                final endIndex = (startIndex + 3).clamp(
                  0,
                  recomendationsList.length,
                );
                final pageItems = recomendationsList.sublist(
                  startIndex,
                  endIndex,
                );

                return ListView.builder(
                  itemCount: pageItems.length,
                  itemBuilder:
                      (ctx, i) => Recomendation(
                        imageUrl: pageItems[i]["imageUrl"] as String,
                        recomendationTitle:
                            pageItems[i]["recomendationTitle"] as String,
                        recomendationSubTitle:
                            pageItems[i]["recomendationSubTitle"] as String,
                      ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Opacity(
                opacity: (_currentPage > 0) ? 1 : 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
              Opacity(
                opacity: (_currentPage < totalPages - 1) ? 1 : 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ],
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     IconButton(
          //       icon: const Icon(Icons.arrow_back),
          //       onPressed: () {
          //         print(
          //           _pageController.page != null && _pageController.page! > 0,
          //         );
          //         _pageController.previousPage(
          //           duration: const Duration(milliseconds: 300),
          //           curve: Curves.easeInOut,
          //         );
          //       },
          //     ),
          //     IconButton(
          //       icon: const Icon(Icons.arrow_forward),
          //       onPressed: () {
          //         print(
          //           _pageController.page != null &&
          //               _pageController.page! <
          //                   (recomendationsList.length / 3).ceil() - 1,
          //         );
          //         _pageController.nextPage(
          //           duration: const Duration(milliseconds: 300),
          //           curve: Curves.easeInOut,
          //         );
          //       },
          //     ),
          //   ],
          // ),
          const SizedBox(height: 10),
          Column(
            children: [
              Text(
                "Alguma dúvida?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                "Entre em contacto conosco",
                style: TextStyle(
                  fontSize: 18,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class Recomendation extends StatelessWidget {
  final String imageUrl;
  final String recomendationTitle;
  final String recomendationSubTitle;

  const Recomendation({
    required this.imageUrl,
    required this.recomendationTitle,
    required this.recomendationSubTitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 0,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              recomendationTitle,
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Flexible(
                            fit: FlexFit.loose,
                            child: Text(
                              recomendationSubTitle,
                              style: TextStyle(fontSize: 12),
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class Greetings extends StatelessWidget {
  const Greetings({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Olá, Miguel!",
              style: TextStyle(
                fontSize: 34,
                fontFamily: 'Poppins',
                color: Theme.of(context).colorScheme.tertiaryFixed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          "Estes são possíveis fornecedores que te poderão agradar!",
          style: TextStyle(
            fontSize: 22,
            fontFamily: 'Poppins',
            color: Theme.of(context).colorScheme.tertiaryFixed,
          ),
        ),
      ],
    );
  }
}
