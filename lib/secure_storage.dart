import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

void savePrivateKey(String privateKey) async {
  await storage.write(key: "private_key", value: privateKey);
}

Future<String?> getPrivateKey() async {
  return await storage.read(key: "private_key");
}
