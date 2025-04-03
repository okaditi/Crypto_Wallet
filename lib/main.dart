// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'services/wallet_services.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crypt',
      theme: ThemeData.dark(),
      home: LoginScreen(),
    );
  }
}

// -------------------- LOGIN SCREEN --------------------
class LoginScreen extends StatelessWidget {
  final WalletService walletService = WalletService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Crypt", 
                style: TextStyle(
                  fontSize: 50, 
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 40,),
              Text(
                "Welcome back you've been missed!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple[500],
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScreen(walletService: walletService),
                      ),
                    );
                  },
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                    ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add MainScreen to handle navigation
class MainScreen extends StatefulWidget {
  final WalletService walletService;
  MainScreen({required this.walletService});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeContent(),
      WalletScreen(walletService: widget.walletService),
      SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.deepPurple[500],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// Convert HomeScreen to HomeContent
class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'Crypt',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }
}

// Add SettingsScreen
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('Profile'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Handle profile tap
              },
            ),
            ListTile(
              leading: Icon(Icons.security),
              title: Text('Security'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Handle security tap
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications_outlined),
              title: Text('Notifications'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Handle notifications tap
              },
            ),
            Divider(color: Colors.grey[800]),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Sign Out', style: TextStyle(color: Colors.red)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Sign Out'),
                      content: Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          child: Text('Sign Out', style: TextStyle(color: Colors.red)),
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                              (Route<dynamic> route) => false,
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- WALLET SCREEN --------------------
class WalletScreen extends StatefulWidget {
  final WalletService walletService;
  WalletScreen({required this.walletService});
<<<<<<< HEAD
=======

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String balance = 'Fetching...';
  String? walletAddress;
  List<Map<String, String>> assets = [];

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    try {
      String? privateKey = await widget.walletService.loadPrivateKey();
      if (privateKey != null) {
        String address = widget.walletService.getEthereumAddress(privateKey);
        setState(() => walletAddress = address);

        EtherAmount ethBalance = await widget.walletService.getBalance(address);
        double ethValue = ethBalance.getValueInUnit(EtherUnit.ether);
>>>>>>> bddd3d4 (Updated UI and Wallet Screen layout)

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

<<<<<<< HEAD
class _WalletScreenState extends State<WalletScreen> {
  String balance = 'Fetching...';
  String? walletAddress;
  List<Map<String, String>> assets = [];

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    try {
      String? privateKey = await widget.walletService.loadPrivateKey();
      if (privateKey != null) {
        String address = widget.walletService.getEthereumAddress(privateKey);
        setState(() => walletAddress = address);

        EtherAmount ethBalance = await widget.walletService.getBalance(address);
        double ethValue = ethBalance.getValueInUnit(EtherUnit.ether);
        double ethToUsd = await widget.walletService.getEthToUsdRate();
        double ethUsdValue = ethValue * ethToUsd;

        List<Map<String, String>> fetchedAssets = await widget.walletService.getAllAssets(address);

        setState(() {
          balance = ethValue.toStringAsFixed(4);
          assets = fetchedAssets;
=======
        setState(() {
          balance = ethValue.toStringAsFixed(4);
>>>>>>> bddd3d4 (Updated UI and Wallet Screen layout)
        });
      } else {
        setState(() => balance = 'No wallet found');
      }
    } catch (e) {
      setState(() => balance = 'Error fetching balance');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Wallet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text('Total Balance', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  SizedBox(height: 5),
                  Text('$balance ETH', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  Text('\$${assets.isNotEmpty ? assets[0]['usd'] : '0.00'} USD', style: TextStyle(fontSize: 18, color: Colors.greenAccent)),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _walletActionButton(Icons.download, 'Buy'),
                _walletActionButton(Icons.arrow_upward, 'Send'),
                _walletActionButton(Icons.swap_horiz, 'Swap'),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Assets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('Activity', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
            Divider(color: Colors.grey),
            Expanded(
              child: ListView.builder(
                itemCount: assets.length,
                itemBuilder: (context, index) {
                  final asset = assets[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[800],
                      child: Text(asset['symbol'] ?? '?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    title: Text('${asset['amount']} ${asset['symbol']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    subtitle: Text('\$${asset['usd']} USD', style: TextStyle(color: Colors.grey)),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _walletActionButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue,
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
