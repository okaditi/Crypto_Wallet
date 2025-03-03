import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:hex/hex.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

class WalletService {
  final storage = FlutterSecureStorage();
  final String rpcUrl = "https://sepolia.infura.io/v3/YOUR_INFURA_KEY"; // Infura API
  late Web3Client ethClient;
  late WalletConnect connector;
  SessionStatus? session;

  WalletService() {
    ethClient = Web3Client(rpcUrl, http.Client());

    // Initialize WalletConnect
    connector = WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientMeta: PeerMeta(
        name: "Crypto Wallet",
        description: "A secure crypto wallet",
        url: "https://your-app-url.com",
        icons: ["https://your-app-url.com/icon.png"],
      ),
    );
  }

  /// Generates a 12-word mnemonic (seed phrase)
  String generateMnemonic() {
    return bip39.generateMnemonic();
  }

  /// Converts mnemonic to private key (Renamed Function)
  String derivePrivateKey(String mnemonic) {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(seed);
    final child = root.derivePath("m/44'/60'/0'/0/0"); // Ethereum path
    return HEX.encode(child.privateKey!);
  }

  /// Derives Ethereum address from private key
  String getEthereumAddress(String privateKey) {
    final private = EthPrivateKey.fromHex(privateKey);
    return private.address.hexEip55;
  }

  /// Saves private key securely
  Future<void> savePrivateKey(String privateKey) async {
    await storage.write(key: "private_key", value: privateKey);
  }

  /// Retrieves private key securely (Renamed Function)
  Future<String?> loadPrivateKey() async {
    return await storage.read(key: "private_key");
  }

  /// Connects to MetaMask via WalletConnect
  Future<void> connectMetaMask(Function(String) onConnected) async {
    if (!connector.connected) {
      try {
        session = await connector.createSession(
          chainId: 11155111, // Sepolia Testnet
          onDisplayUri: (uri) async {
            print("WalletConnect URI: $uri");
          },
        );

        if (session != null) {
          String address = session!.accounts[0];
          onConnected(address);
        }
      } catch (e) {
        print("Error connecting MetaMask: $e");
      }
    }
  }

  /// Disconnects MetaMask
  Future<void> disconnectMetaMask() async {
    if (connector.connected) {
      await connector.killSession();
      session = null;
    }
  }

  /// Fetches ETH balance
  Future<EtherAmount> getBalance(String address) async {
    EthereumAddress ethAddress = EthereumAddress.fromHex(address);
    return await ethClient.getBalance(ethAddress);
  }

  /// Sends ETH transaction
  Future<String> sendTransaction(
      String privateKey, String recipient, double amount) async {
    final credentials = EthPrivateKey.fromHex(privateKey);
    final toAddress = EthereumAddress.fromHex(recipient);

    final transaction = Transaction(
      to: toAddress,
      value: EtherAmount.fromUnitAndValue(EtherUnit.ether, amount),
    );

    return await ethClient.sendTransaction(credentials, transaction);
  }
}
