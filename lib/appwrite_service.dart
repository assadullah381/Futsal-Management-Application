// appwrite_service.dart
import 'package:appwrite/appwrite.dart';

class AppwriteService {
  static final Client client = Client()
    ..setEndpoint('https://fra.cloud.appwrite.io/v1')
    ..setProject('67d0e2dd00399b43677c')
    ..setSelfSigned(status: true);

  static final Account account = Account(client);
}
