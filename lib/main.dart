import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toko Sembako',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),
      home: SplashScreen(),
    );
  }
}

// --- Splash Screen ---
class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () async {
      final prefs = await SharedPreferences.getInstance();
      String? user = prefs.getString('username');
      if (user != null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => HomeScreen(username: user)));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_hd.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Text('Toko Sembako',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                        color: Colors.black54,
                        blurRadius: 5,
                        offset: Offset(2, 2))
                  ])),
        ),
      ),
    );
  }
}

// --- Login / Register Screen ---
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> register() async {
    String user = usernameController.text.trim();
    String pass = passwordController.text.trim();
    if (user.isNotEmpty && pass.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', user);
      await prefs.setString('password', pass);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Akun berhasil dibuat')));
      usernameController.clear();
      passwordController.clear();
    }
  }

  Future<void> login() async {
    String user = usernameController.text.trim();
    String pass = passwordController.text.trim();
    final prefs = await SharedPreferences.getInstance();
    String? savedUser = prefs.getString('username');
    String? savedPass = prefs.getString('password');

    if (savedUser == user && savedPass == pass) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => HomeScreen(username: user)));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Login gagal')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_hd.png'),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text('Toko Sembako',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                SizedBox(height: 30),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                      labelText: 'Username', border: OutlineInputBorder()),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                      labelText: 'Password', border: OutlineInputBorder()),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(onPressed: login, child: Text('Login')),
                    ElevatedButton(onPressed: register, child: Text('Buat Akun')),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Home Screen ---
class HomeScreen extends StatefulWidget {
  final String username;
  HomeScreen({required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> daftarBarang = [
    {'nama': 'Aqua Botol', 'harga': 5000, 'image': 'assets/images/aqua_hd.png'},
    {'nama': 'Indomie Goreng', 'harga': 3500, 'image': 'assets/images/indomie_hd.png'},
    {'nama': 'Chitato', 'harga': 8000, 'image': 'assets/images/chitato_hd.png'},
    {'nama': 'Teh Kotak', 'harga': 6000, 'image': 'assets/images/teh_hd.png'},
  ];

  List<Map<String, dynamic>> keranjang = [];

  int get totalHarga => keranjang.fold(0, (prev, item) => prev + (item['harga'] as int));

  void addBarang(Map<String, dynamic> item) {
    setState(() {
      keranjang.add(item);
    });
  }

  void removeBarang(int index) {
    setState(() {
      keranjang.removeAt(index);
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, ${widget.username}'),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_hd.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8),
                itemCount: daftarBarang.length,
                itemBuilder: (context, i) {
                  final item = daftarBarang[i];
                  return GestureDetector(
                    onTap: () => addBarang(item),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.vertical(top: Radius.circular(10)),
                              child: Image.asset(item['image'],
                                  fit: BoxFit.cover, width: double.infinity),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: Column(
                              children: [
                                Text(item['nama'],
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Rp ${item['harga']}',
                                    style: TextStyle(color: Colors.green[800])),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: keranjang.length,
                itemBuilder: (context, i) {
                  final item = keranjang[i];
                  return Container(
                    width: 100,
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item['nama'], textAlign: TextAlign.center),
                        Text('Rp ${item['harga']}'),
                        IconButton(
                          icon: Icon(Icons.delete, size: 18, color: Colors.red),
                          onPressed: () => removeBarang(i),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Total Harga: Rp $totalHarga',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}