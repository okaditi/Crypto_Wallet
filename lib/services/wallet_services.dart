import 'dart:convert';
import 'hush_wallet_service.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:hex/hex.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';


//setting up dependencies/tools we will use throughout the service!!!

class WalletService {
  final storage = FlutterSecureStorage(); //saves private key on the devices
  final String rpcUrl = "https://sepolia.infura.io/v3/235b57e865d249359ec1aebd2c620c39"; // Infura API- intracting w blockchain using etherum node url which in this case is infura, an ethereum provider and i fucking forgot mine so i have to ask bhaiya
  final HushWalletService hushWalletService = HushWalletService();
  late Web3Client ethClient; // lets us send transaction,get balance, interact with smart contracts
  late WalletConnect connector; //connects the metamask wallet to our app
  SessionStatus? session; //keep tracks of metamask wallet connection

  WalletService() {
    ethClient = Web3Client(rpcUrl, http.Client()); //creating a connection w the ethereum , allows us to send transactions, check balances, interact with smart contracts

    // Initialize WalletConnect so we can later use it to connect with meta mask
    connector = WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientMeta: PeerMeta(
        name: "Crypto Wallet",
        description: "A secure crypto wallet",
        url: "https://example.com",
        icons: ["https://your-app-url.com/icon.png"],
      ),
    );
      setupNewWallet();
  }

/// Creates a new main wallet and a backup HushWallet
  Future<void> setupNewWallet() async {
    print("Setting up a new wallet and backup HushWallet...");
    await hushWalletService.createWallet(isBackup: false);
    await hushWalletService.createWallet(isBackup: true);
  }



  /// Generates a 12-word mnemonic (seed phrase)
  String generateMnemonic() {
    return bip39.generateMnemonic();
  } //generating 12 seed phrases, here we are using the big39 package we included on the top of the code 

  /// Converts seed phrases to private key 
  String derivePrivateKey(String mnemonic) {
    final seed = bip39.mnemonicToSeed(mnemonic); //converts the 12 words into a binary seed
    final root = bip32.BIP32.fromSeed(seed); //creates a root key from binary key 
    final child = root.derivePath("m/44'/60'/0'/0/0"); //follows the path to get a unique private key 
    return HEX.encode(child.privateKey!); //converts the private key into a readable format 
  }

  /// Derives Ethereum (public) address from private key - this address is used perform transaction
  String getEthereumAddress(String privateKey) {
    final private = EthPrivateKey.fromHex(privateKey);
    return private.address.hexEip55;
  }

  /// Saves private key securely
  Future<void> savePrivateKey(String privateKey) async {
    await storage.write(key: "private_key", value: privateKey);
  }

  /// Reads the private key when needed in the future
  Future<String?> loadPrivateKey() async {
    return await storage.read(key: "private_key");
  }

  
  /// Saves the seed phrase securely
  Future<void> saveSeedPhrase(String mnemonic) async {
    await storage.write(key: "seed_phrase", value: mnemonic);
  }

  /// Reads the saved seed phrase when needed
  Future<String?> loadSeedPhrase() async {
    return await storage.read(key: "seed_phrase");
  }

  /// Connects to MetaMask via WalletConnect
  Future<void> connectMetaMask(Function(String) onConnected) async { // input here is the ethereum address of the user's wallet 
    if (!connector.connected) {    //checking if it is not already connected 
      try {
        session = await connector.createSession( //creating a wallet connect session to interact 
          chainId: 11155111, // Sepolia Testnet- these already fixed 
          onDisplayUri: (uri) async {
            print("WalletConnect URI: $uri"); //generates a connect walllet uri if needed - by scanning the QR code you can manually connect 
          },
        );

        if (session != null) { // checks if session was successful or not
          String address = session!.accounts[0];
          onConnected(address); //passes the user's wallet address back to the app
        }
      } catch (e) { // error handling
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

  
  Future<void> selfDestructWallet() async {
    print("Main wallet is being destroyed...");
    String? privateKey = await loadPrivateKey();
    String? backupAddress = await hushWalletService.getBackupWalletAddress();

    if (privateKey != null && backupAddress != null) {
      print("Transferring funds to backup wallet before destruction...");
      try {
        EtherAmount balance = await getBalance(getEthereumAddress(privateKey));
        await sendTransaction(privateKey, backupAddress, balance.getValueInUnit(EtherUnit.ether)); // Send all funds
      } catch (e) {
        print("Transfer failed: $e");
      }
    }

    await storage.delete(key: "private_key");
    await storage.delete(key: "seed_phrase");
    print("Main wallet has been wiped.");
    await hushWalletService.activateHushWallet();
    print("HushWallet is now the active wallet.");
    await setupNewWallet();
    print("A new backup HushWallet has been created.");
  }

  //hnn created: extra function
  /// Fetches the ETH to USD conversion ratewith this coingecko API
  Future<double> getEthToUsdRate() async {
    final url = Uri.parse('https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['ethereum']['usd'].toDouble();
    } else {
      throw Exception('Failed to fetch ETH price');
    }
  }

  /// gets allthe  assets in the wallet 
  Future<List<Map<String, String>>> getAllAssets(String address) async {
    List<Map<String, String>> assets = [];

    // Fetch ETH balance
    EtherAmount ethBalance = await getBalance(address);
    double ethValue = ethBalance.getValueInUnit(EtherUnit.ether);
    double ethUsdValue = ethValue * await getEthToUsdRate();

    assets.add({
      'symbol': 'ETH',
      'amount': ethValue.toStringAsFixed(4),
      'usd': ethUsdValue.toStringAsFixed(2),
    });

    return assets;
  }

}
