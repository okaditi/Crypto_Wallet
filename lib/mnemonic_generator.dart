import 'package:bip39/bip39.dart' as bip39;

String generateMnemonic() {
  return bip39.generateMnemonic();
}

void main() {
  String mnemonic = generateMnemonic();
  print("Your Seed Phrase: $mnemonic");
}
