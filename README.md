# Hello Farmer

Hello Farmer é uma aplicação inovadora que aproxima produtores e consumidores, facilitando a compra e venda direta de produtos agrícolas frescos e locais. Com uma interface intuitiva e funcionalidades avançadas, a plataforma promove a valorização da agricultura local, a transparência e a confiança entre utilizadores.

---

## Índice

- [Funcionalidades Principais](#funcionalidades-principais)
- [Instalação](#instalação)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Tecnologias Utilizadas](#tecnologias-utilizadas)
- [Segurança e Privacidade](#segurança-e-privacidade)
- [Contribuição](#contribuição)
- [Licença](#licença)
- [Autores](#autores)

---

## Funcionalidades Principais

### Ecrã de Boas-vindas & Autenticação

- Ecrã de boas-vindas com apresentação das vantagens da plataforma.
- Autenticação segura com registo de consumidores e produtores.
- Validação de dados, recuperação de password e autenticação por email.
- Personalização do perfil com imagem, dados pessoais e localização.

### Para Consumidores

- **Exploração de Produtos:** Pesquisa por categorias, produtos recomendados, promoções e favoritos.
- **Carrinho e Encomendas:** Adiciona produtos ao carrinho, faz encomendas rápidas e acompanha o histórico.
- **Avaliações:** Avalia produtos e produtores após cada compra.
- **Notificações em Tempo Real:** Recebe alertas sobre promoções, novidades e o estado das tuas encomendas.
- **Chat Direto:** Comunica facilmente com produtores para esclarecer dúvidas ou combinar detalhes.
- **Mapa Interativo:** Descobre bancas e produtores próximos de ti.
- **Gestão de Perfil:** Edita dados pessoais, métodos de pagamento e preferências.
- **Faturas e Histórico:** Consulta faturas em PDF e histórico detalhado de compras.

### Para Produtores

- **Gestão de Banca:** Cria e personaliza a tua banca, adiciona produtos com fotos, descrições e preços.
- **Gestão de Anúncios:** Publica, edita, destaca e remove anúncios de forma simples.
- **Gestão de Encomendas:** Acompanha todas as encomendas recebidas e atualiza o seu estado.
- **Promoções Personalizadas:** Envia ofertas e promoções diretamente aos teus clientes.
- **Estatísticas e Relatórios:** Consulta dados de vendas, inventário, análise de produtos e desempenho da tua banca.
- **Avaliações e Feedback:** Recebe avaliações dos clientes para melhorar continuamente.
- **Notificações em Tempo Real:** Mantém-te sempre informado sobre novas encomendas e mensagens.
- **Gestão de Cabazes:** Cria e gere cabazes personalizados para venda.
- **Faturação e Pagamentos:** Gera faturas automáticas e gere dados de faturação.
- **Gestão de Clientes:** Consulta e contacta clientes recorrentes.

### Funcionalidades Gerais

- **Sistema de Mensagens:** Chat seguro e encriptado entre utilizadores.
- **Notificações Push e Email:** Recebe notificações importantes mesmo fora da app.
- **Gestão de Preferências:** Personaliza temas, idioma, notificações e privacidade.
- **Política de Devoluções:** Definição de políticas de devolução por loja.
- **Gestão de Sessões:** Logout remoto e autenticação biométrica/PIN.
- **Acessibilidade:** Interface adaptada a diferentes dispositivos e tamanhos de ecrã.

---

## Instalação

1. **Clona o repositório:**
   ```bash
   git clone https://github.com/MiguelSilva202200034/ProjetoCM.git
   ```
2. **Acede à pasta do projeto:**
   ```bash
   cd hello-farmer
   ```
3. **Instala as dependências:**
   ```bash
   flutter pub get
   ```
4. **Configura as variáveis de ambiente:**
   - Cria um ficheiro `.env` com as tuas chaves Firebase e APIs necessárias.
5. **Executa a aplicação:**
   ```bash
   flutter run
   ```

---

## Estrutura do Projeto

```
lib/
  components/        # Widgets e componentes reutilizáveis
  core/              # Modelos, serviços, lógica de negócio
  encryption/        # Serviços de encriptação de mensagens
  pages/             # Páginas principais da aplicação
  utils/             # Utilitários, helpers e constantes
  l10n/              # Internacionalização
functions/           # Cloud Functions para lógica backend
```

---

## Tecnologias Utilizadas

- **Flutter** (Dart)
- **Firebase**: Firestore, Auth, Storage, Cloud Functions, Realtime Database, Firebase Messaging
- **Provider** (gestão de estado)
- **RxDart**
- **Google Maps** (`google_maps_flutter`)
- **Geolocator** e **permission_handler** (localização)
- **intl** (formatação de datas e moedas)
- **image_picker** (seleção de imagens)
- **encrypt** e **crypto** (encriptação de mensagens)
- **pdf** e **printing** (geração e partilha de faturas em PDF)
- **fl_chart** e **percent_indicator** (gráficos e estatísticas)
- **font_awesome_flutter** (ícones)
- **shared_preferences** (preferências locais)
- **timelines_plus** (timelines de encomendas)
- **flutter_local_notifications** (notificações locais)
- **cloud_functions** (funções serverless)
- **country_picker** e **intl_phone_number_input** (formulários internacionais)

---

## Segurança e Privacidade

- **Autenticação segura** com validação de email e autenticação biométrica/PIN.
- **Encriptação de mensagens** para garantir privacidade nas conversas.
- **Gestão de permissões** para localização, notificações e acesso a ficheiros.
- **Política de privacidade** clara e disponível na aplicação.
- **Gestão de sessões** e possibilidade de logout remoto.

---

## Contribuição

Contribuições são bem-vindas!  
Sente-te à vontade para abrir issues ou pull requests com sugestões, melhorias ou correções.

---

## Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

---

Descobre já a Hello Farmer e faz parte desta comunidade que valoriza o melhor da agricultura local!


link repositorio git: https://github.com/MiguelSilva202200034/ProjetoCM.git

## Autores

- Miguel Silva - 202200034
- Rúben Alves - 202200028
- Ricardo Oliveira - 2023000157
- Henrique Franco - 202101006

