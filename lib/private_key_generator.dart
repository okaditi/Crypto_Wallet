import 'package:bip32/bip32.dart' as bip32;
import 'package:hex/hex.dart';
import 'package:bip39/bip39.dart' as bip39;

String getPrivateKey(String mnemonic) {
  final seed = bip39.mnemonicToSeed(mnemonic);
  final root = bip32.BIP32.fromSeed(seed);
  final child = root.derivePath("m/44'/60'/0'/0/0"); // Ethereum Path

  return HEX.encode(child.privateKey!);
}

void main() {
  String mnemonic = "your mnemonic here"; 
  String privateKey = getPrivateKey(mnemonic);
  print("Private Key: $privateKey");
}
