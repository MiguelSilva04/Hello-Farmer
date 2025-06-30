# 🌾 Hello Farmer

**Hello Farmer** é uma plataforma inovadora que aproxima **produtores locais** e **consumidores**, promovendo a compra direta de produtos agrícolas frescos, sustentáveis e regionais. Com uma experiência de utilizador fluida e funcionalidades completas, a aplicação valoriza a agricultura local e fortalece relações de confiança.

---

## 📌 Índice

- [✨ Funcionalidades](#-funcionalidades)
- [🚀 Instalação](#-instalação)
- [📁 Estrutura do Projeto](#-estrutura-do-projeto)
- [🧪 Tecnologias Utilizadas](#-tecnologias-utilizadas)
- [🔒 Segurança e Privacidade](#-segurança-e-privacidade)
- [🤝 Contribuições](#-contribuições)
- [📜 Licença](#-licença)
- [👥 Autores](#-autores)

## ✨ Funcionalidades

### 👤 Autenticação & Perfil
- Registo e login com validação por email
- Recuperação de password e autenticação segura
- Gestão do perfil com imagem, dados pessoais e localização
- Autenticação por biometria ou PIN (opcional)

### 🛒 Para Consumidores
- Explorar produtos por **categorias**, **novidades**, **promoções** e **favoritos**
- Carrinho de compras inteligente com múltiplos produtores
- Avaliações e comentários após compra
- Histórico de encomendas e faturas em PDF
- **Mapa interativo** com bancas e produtores próximos
- Chat direto com produtores
- Notificações em tempo real (estado da encomenda, promoções, etc.)

### 🧑‍🌾 Para Produtores
- Gestão de banca (perfil, descrição, localização, foto)
- Publicação e edição de anúncios com imagens e promoções
- Gestão de encomendas com atualização de estados
- Envio de notificações e mensagens a clientes
- Análise de vendas, produtos, e estatísticas gráficas
- Gestão de cabazes personalizados
- Histórico de clientes e interação por chat
- Faturação e geração de PDFs automáticos

### 🔁 Funcionalidades Gerais
- Sistema de mensagens seguro (com encriptação)
- Notificações push
- Gestão de preferências (tema, idioma, notificações, etc.)
- Interface responsiva

---

## 🚀 Instalação

1. Clona o repositório:
   ```bash
   git clone https://github.com/MiguelSilva202200034/ProjetoCM.git
   ```

2. Acede à pasta do projeto:
   ```bash
   cd hello-farmer
   ```

3. Instala as dependências:
   ```bash
   flutter pub get
   ```

4. Cria o ficheiro `.env` na raiz com as tuas variáveis:
   ```env
   OPENWEATHER_API_KEY=xxxxxxx
   ```

5. Executa a aplicação:
   ```bash
   flutter run
   ```

---

## 📁 Estrutura do Projeto

```
lib/
├── components/        # Widgets reutilizáveis (UI e lógica)
├── core/              # Modelos, serviços e lógica de negócio
├── encryption/        # Lógica de encriptação de mensagens
├── pages/             # Páginas principais (home, carrinho, detalhes, etc.)
├── utils/             # Funções auxiliares e constantes globais
├── l10n/              # Internacionalização e traduções

functions/             # Cloud Functions (Firebase backend)
```

---

## 🧪 Tecnologias Utilizadas

- **Flutter** & Dart
- **Firebase**: Auth, Firestore, Storage, Realtime DB, Cloud Functions, Messaging
- **Provider** (gestão de estado)
- **RxDart**
- **Google Maps API** (`google_maps_flutter`)
- **Geolocator**, **permission_handler**
- **encrypt** & **crypto** (mensagens privadas)
- **intl** (datas e moeda)
- **pdf** & **printing**
- **flutter_local_notifications**
- **cloud_functions**
- **shared_preferences**
- **timelines_plus**, **fl_chart**, **percent_indicator**

---

## 🔒 Segurança e Privacidade

- Autenticação segura com email
- Encriptação de mensagens entre utilizadores
- Gestão de permissões de localização, notificações, ficheiros
- Sessões seguras com possibilidade de logout remoto
- Política de privacidade clara e disponível na app

---

## 🤝 Contribuições

Contribuições são bem-vindas!  
Podes abrir uma [issue](https://github.com/MiguelSilva202200034/ProjetoCM/issues) ou um [pull request](https://github.com/MiguelSilva202200034/ProjetoCM/pulls) com sugestões ou melhorias.

---

## 📜 Licença

Distribuído sob a licença MIT.  
Consulta o ficheiro [`LICENSE`](LICENSE) para mais informações.

---

## 👥 Autores

- Miguel Silva - 202200034  
- Rúben Alves - 202200028  
- Ricardo Oliveira - 2023000157  
- Henrique Franco - 202101006  

🔗 Repositório oficial: [github.com/MiguelSilva202200034/ProjetoCM](https://github.com/MiguelSilva202200034/ProjetoCM)

