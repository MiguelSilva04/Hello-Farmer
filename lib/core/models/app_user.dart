import 'package:harvestly/core/models/notification.dart';

abstract class AppUser {
  final String id;
  final String email;
  String firstName;
  String lastName;
  String? aboutMe;
  String phone;
  String gender;
  String imageUrl;
  String address;
  final int? taxpayerNumber;
  String? backgroundUrl;
  String? recoveryEmail;
  String? dateOfBirth;
  bool isProducer;
  String? iban;
  List<NotificationItem>? notifications = null;

  AppUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.gender,
    required this.imageUrl,
    this.aboutMe,
    this.backgroundUrl,
    this.recoveryEmail,
    this.dateOfBirth,
    required this.isProducer,
  }) : taxpayerNumber = 12345678910111213,
       iban = "PT50 0085 9837 8776 7846 4789",
       address = "Rua Central, 458\n1100-145 Lisboa, Portugal",
       notifications = [
         NotificationItem(
           id: '1',
           title: 'Encomenda enviada',
           description:
               'Encomenda de Alfaces Biológicas enviada para Ana Loures.',
           dateTime: DateTime.now().subtract(Duration(hours: 2)),
           type: NotificationType.orderSent,
         ),
         NotificationItem(
           id: '2',
           title: 'Entrega agendada',
           description:
               'Encomenda de Cenouras será recolhida a 17/04 até às 10:00.',
           dateTime: DateTime.now().subtract(Duration(hours: 5)),
           type: NotificationType.deliveryScheduled,
         ),
         NotificationItem(
           id: '3',
           title: 'Anúncio publicado',
           description:
               'O seu anúncio de "Compota de abóbora" foi publicado com sucesso!',
           dateTime: DateTime.now().subtract(Duration(days: 1)),
           type: NotificationType.adPublished,
         ),
         NotificationItem(
           id: '4',
           title: 'Nova avaliação',
           description:
               'O consumidor Pedro Alves deixou uma avaliação no seu perfil!',
           dateTime: DateTime.now().subtract(Duration(days: 2)),
           type: NotificationType.newReview,
         ),
         NotificationItem(
           id: '5',
           title: 'Nova mensagem',
           description:
               'O cliente Rúbem Sousa enviou uma mensagem sobre "Cenouras Biológicas".',
           dateTime: DateTime.now().subtract(Duration(days: 3)),
           type: NotificationType.newMessage,
         ),
       ];

  @override
  String toString() {
    return 'AppUser(id: $id, firstName: $firstName, lastName: $lastName, email: $email, gender: $gender, phone: $phone, recoveryEmail: $recoveryEmail, dateOfBirth: $dateOfBirth, imageUrl: $imageUrl, backgroundUrl: $backgroundUrl, isProducer: $isProducer)';
  }
}
