import 'package:flutter/material.dart';

void main() {
  runApp(const HelloFarmerApp());
}

class HelloFarmerApp extends StatelessWidget {
  const HelloFarmerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HelloFarmer',
      theme: ThemeData(
        primaryColor: const Color(0xFF2C6E49),
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C6E49),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/logo.png'), // substituir pelo teu logo
        ),
        actions: const [
          Icon(Icons.search, color: Colors.white),
          SizedBox(width: 12),
          Icon(Icons.person, color: Colors.white),
          SizedBox(width: 12),
          Icon(Icons.more_vert, color: Colors.white),
          SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Olá, Rúben!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Descobre os melhores produtos frescos na tua zona!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'Recomendados para ti',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildProductItem('Couve', 'assets/couve.png'),
                  _buildProductItem('Beringela', 'assets/beringela.png'),
                  _buildProductItem('Cenoura', 'assets/cenoura.png'),
                  _buildProductItem('Tomate', 'assets/tomate.png'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Produtores perto de ti',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildProducerRow(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: const Color(0xFF2C6E49),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shopping_basket), label: 'Encomendas'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explorar'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Mensagens'),
        ],
      ),
    );
  }

  Widget _buildProductItem(String name, String imagePath) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(imagePath),
          ),
          const SizedBox(height: 6),
          Text(name),
        ],
      ),
    );
  }

  Widget _buildProducerRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildProducerItem('Joaquim Soares', 'Setúbal', 3.7, 496, 'assets/p1.png'),
        _buildProducerItem('Zé das Couves', 'Setúbal', 4.5, 34, 'assets/p2.png'),
        _buildProducerItem('Antonio Silva', 'Setúbal', 3.6, 653, 'assets/p3.png'),
      ],
    );
  }

  Widget _buildProducerItem(String name, String location, double rating, int reviews, String imagePath) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage(imagePath),
        ),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        Text(location, style: const TextStyle(fontSize: 10)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(rating.toString(), style: const TextStyle(fontSize: 10)),
            const Icon(Icons.star, size: 12, color: Colors.amber),
            Text('($reviews)', style: const TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }
}
