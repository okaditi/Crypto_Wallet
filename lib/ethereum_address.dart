import 'package:web3dart/credentials.dart';

String getEthereumAddress(String privateKey) {
  final private = EthPrivateKey.fromHex(privateKey);
  return private.address.hexEip55; // Ethereum address
}

void main() {
  String privateKey = "your_private_key_here";
  String address = getEthereumAddress(privateKey);
  print("Ethereum Address: $address");
}
