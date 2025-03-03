import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

final String rpcUrl = "https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID";
final Web3Client ethClient = Web3Client(rpcUrl, http.Client());

Future<EtherAmount> getBalance(String address) async {
  EthereumAddress ethAddress = EthereumAddress.fromHex(address);
  return await ethClient.getBalance(ethAddress);
}
