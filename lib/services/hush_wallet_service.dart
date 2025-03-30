import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:hex/hex.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

class HushWalletService {
  final storage = FlutterSecureStorage();
  final String rpcUrl = "https://sepolia.infura.io/v3/YOUR_INFURA_KEY";
  late Web3Client ethClient;

  HushWalletService() {
    ethClient = Web3Client(rpcUrl, http.Client());
  }

  /// Generates a new wallet (Main or HushWallet)
  Future<Map<String, String>> createWallet({bool isBackup = false}) async {
    String mnemonic = bip39.generateMnemonic();
    String privateKey = derivePrivateKey(mnemonic);
    String address = getEthereumAddress(privateKey);

    if (isBackup) {
      await storage.write(key: "hush_wallet_private_key", value: privateKey);
      await storage.write(key: "hush_wallet_seed", value: mnemonic);
      await storage.write(key: "hush_wallet_address", value: address);
    } else {
      await storage.write(key: "main_wallet_private_key", value: privateKey);
      await storage.write(key: "main_wallet_seed", value: mnemonic);
      await storage.write(key: "main_wallet_address", value: address);

      // Auto-generate a backup HushWallet
      await createWallet(isBackup: true);
    }

    return {
      "mnemonic": mnemonic,
      "privateKey": privateKey,
      "address": address,
    };
  }

  /// Converts seed phrases to private key
  String derivePrivateKey(String mnemonic) {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(seed);
    final child = root.derivePath("m/44'/60'/0'/0/0");
    return HEX.encode(child.privateKey!);
  }

  /// Gets Ethereum address from private key
  String getEthereumAddress(String privateKey) {
    final private = EthPrivateKey.fromHex(privateKey);
    return private.address.hexEip55;
  }

  /// Self-destructs the main wallet and activates HushWallet
  Future<void> activateHushWallet() async {
    // Retrieve HushWallet details
    String? hushPrivateKey = await storage.read(key: "hush_wallet_private_key");
    String? hushSeed = await storage.read(key: "hush_wallet_seed");
    String? hushAddress = await storage.read(key: "hush_wallet_address");

    if (hushPrivateKey == null || hushSeed == null || hushAddress == null) {
      print("No backup HushWallet found.");
      return;
    }

    // Auto-transfer funds before destruction (Optional)
    await autoTransferFunds(hushAddress);

    // Delete main wallet data
    await storage.delete(key: "main_wallet_private_key");
    await storage.delete(key: "main_wallet_seed");
    await storage.delete(key: "main_wallet_address");

    // Promote HushWallet to Main Wallet
    await storage.write(key: "main_wallet_private_key", value: hushPrivateKey);
    await storage.write(key: "main_wallet_seed", value: hushSeed);
    await storage.write(key: "main_wallet_address", value: hushAddress);

    // Remove old HushWallet keys (as it is now the main wallet)
    await storage.delete(key: "hush_wallet_private_key");
    await storage.delete(key: "hush_wallet_seed");
    await storage.delete(key: "hush_wallet_address");

    print("Main wallet destroyed. HushWallet is now the main wallet.");

    // Prompt the user to create a new HushWallet
    await createWallet(isBackup: true);
  }

  /// Triggers self-destruction and activates HushWallet
  Future<void> triggerSelfDestruct() async {
    print("Self-destruction initiated");

    bool confirmDestruction = await getUserConfirmation();
    if (!confirmDestruction) {
      print("Self destruction canceled");
      return;
    }

    // Fetch the backup wallet address
    String? hushAddress = await getBackupWalletAddress();
    if (hushAddress == null) {
      print("No backup wallet found. Cannot proceed.");
      return;
    }

    print("Transferring funds before destruction");
    await autoTransferFunds(hushAddress);

    // Now, activate HushWallet after fund transfer
    await activateHushWallet();

    print("Self-destruction complete. HushWallet is now the main wallet.");
  }


  Future<String?> getBackupWalletAddress() async {
    return await storage.read(key: "hush_wallet_address");
  }


  Future<bool> getUserConfirmation() async {
    // Implement a UI prompt to confirm self-destruction.
    return true; // Placeholder: Change this to real user confirmation logic.
  }

  /// Auto-transfers funds to HushWallet before self-destruction
  Future<void> autoTransferFunds(String hushAddress) async {
    String? mainPrivateKey = await storage.read(key: "main_wallet_private_key");
    String? mainAddress = await storage.read(key: "main_wallet_address");

    if (mainPrivateKey == null || mainAddress == null) {
      print("Main wallet not found. Cannot transfer funds.");
      return;
    }

    // Get balance of the main wallet
    EthereumAddress ethMainAddress = EthereumAddress.fromHex(mainAddress);
    EtherAmount balance = await ethClient.getBalance(ethMainAddress);

    // Check if balance is sufficient
    if (balance.getValueInUnit(EtherUnit.ether) > 0) {
      final credentials = EthPrivateKey.fromHex(mainPrivateKey);
      final transaction = Transaction(
        to: EthereumAddress.fromHex(hushAddress),
        value: balance, // Transfer entire balance
      );

      try {
        String txHash = await ethClient.sendTransaction(credentials, transaction);
        print("Funds transferred to HushWallet. TxHash: $txHash");
      } catch (e) {
        print("Error transferring funds: $e");
      }
    } else {
      print("No funds available for transfer.");
    }
  }

  /// Fetches the current active wallet address
  Future<String?> getCurrentWalletAddress() async {
    return await storage.read(key: "main_wallet_address");
  }
}
