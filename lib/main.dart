import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const LenteraApp());
}

// ============================================================
// APP
// ============================================================

class LenteraApp extends StatelessWidget {
  const LenteraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LENTERA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFF8FAF8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B6B5F),
          brightness: Brightness.light,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFD8E1DE),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFD8E1DE),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF0B6B5F),
              width: 2,
            ),
          ),
        ),
      ),
      home: const StartupGate(),
    );
  }
}

// ============================================================
// CONSTANT
// ============================================================

const Color primaryColor = Color(0xFF0B6B5F);
const Color darkGreen = Color(0xFF123B3B);
const Color lightGreen = Color(0xFFE8F3F0);
const Color backgroundColor = Color(0xFFF8FAF8);


const List<String> quranSurahs = [
  'Al-Fatihah', 'Al-Baqarah', 'Ali Imran', 'An-Nisa', 'Al-Maidah',
  'Al-Anam', 'Al-Araf', 'Al-Anfal', 'At-Taubah', 'Yunus',
  'Hud', 'Yusuf', 'Ar-Rad', 'Ibrahim', 'Al-Hijr', 'An-Nahl',
  'Al-Isra', 'Al-Kahfi', 'Maryam', 'Taha', 'Al-Anbiya', 'Al-Hajj',
  'Al-Muminun', 'An-Nur', 'Al-Furqan', 'Asy-Syuara', 'An-Naml',
  'Al-Qasas', 'Al-Ankabut', 'Ar-Rum', 'Luqman', 'As-Sajdah',
  'Al-Ahzab', 'Saba', 'Fatir', 'Yasin', 'As-Saffat', 'Sad',
  'Az-Zumar', 'Ghafir', 'Fussilat', 'Asy-Syura', 'Az-Zukhruf',
  'Ad-Dukhan', 'Al-Jasiyah', 'Al-Ahqaf', 'Muhammad', 'Al-Fath',
  'Al-Hujurat', 'Qaf', 'Az-Zariyat', 'At-Tur', 'An-Najm',
  'Al-Qamar', 'Ar-Rahman', 'Al-Waqiah', 'Al-Hadid', 'Al-Mujadilah',
  'Al-Hasyr', 'Al-Mumtahanah', 'As-Saff', 'Al-Jumuah', 'Al-Munafiqun',
  'At-Tagabun', 'At-Talaq', 'At-Tahrim', 'Al-Mulk', 'Al-Qalam',
  'Al-Haqqah', 'Al-Maarij', 'Nuh', 'Al-Jinn', 'Al-Muzzammil',
  'Al-Muddassir', 'Al-Qiyamah', 'Al-Insan', 'Al-Mursalat', 'An-Naba',
  'An-Naziat', 'Abasa', 'At-Takwir', 'Al-Infitar', 'Al-Mutaffifin',
  'Al-Insyiqaq', 'Al-Buruj', 'At-Tariq', 'Al-Ala', 'Al-Gasyiyah',
  'Al-Fajr', 'Al-Balad', 'Asy-Syams', 'Al-Lail', 'Ad-Duha',
  'Asy-Syarh', 'At-Tin', 'Al-Alaq', 'Al-Qadr', 'Al-Bayyinah',
  'Az-Zalzalah', 'Al-Adiyat', 'Al-Qariah', 'At-Takasur', 'Al-Asr',
  'Al-Humazah', 'Al-Fil', 'Quraisy', 'Al-Maun', 'Al-Kausar',
  'Al-Kafirun', 'An-Nasr', 'Al-Lahab', 'Al-Ikhlas', 'Al-Falaq', 'An-Nas',
];

// ============================================================
// AUTH GATE
// ============================================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        final user = snapshot.data;

        if (user == null) {
          return const LoginPage();
        }

        // Admin berdasarkan email.
        if (user.email?.toLowerCase() == 'admin@lentera.com') {
          return const AdminDashboard();
        }

        return const StudentDashboard();
      },
    );
  }
}

// ============================================================
// SPLASH
// ============================================================

class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const SplashScreen();
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/lentera_logo_full.png',
                  width: 420,
                  height: 260,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 28),
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Memuat LENTERA...',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: .4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LOGO
// ============================================================

class LenteraLogo extends StatelessWidget {
  final double size;

  const LenteraLogo({
    super.key,
    this.size = 70,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/lentera_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

// ============================================================
// LOGIN PAGE
// ============================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _identifierController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty) {
      _message('Masukkan email atau NIS.');
      return;
    }

    if (password.isEmpty) {
      _message('Masukkan password.');
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      String email = identifier;

      // Jika bukan email, berarti NIS siswa.
      if (!email.contains('@')) {
        email = '$email@lentera.app';
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      // AuthGate otomatis menentukan dashboard.
    } on FirebaseAuthException catch (e) {
      String message = 'Login gagal.';

      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          message = 'NIS/email atau password salah.';
          break;

        case 'invalid-email':
          message = 'Format email tidak valid.';
          break;

        case 'user-disabled':
          message = 'Akun ini dinonaktifkan.';
          break;

        case 'too-many-requests':
          message = 'Terlalu banyak percobaan. Coba lagi nanti.';
          break;

        default:
          message = e.message ?? 'Login gagal.';
      }

      _message(message);
    } catch (e) {
      _message('Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _forgotPassword() async {
    final value = _identifierController.text.trim();

    if (value.isEmpty || !value.contains('@')) {
      _message(
        'Untuk reset password, masukkan email terlebih dahulu.',
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: value,
      );

      _message(
        'Link reset password telah dikirim ke email.',
      );
    } on FirebaseAuthException catch (e) {
      _message(e.message ?? 'Gagal mengirim email reset password.');
    }
  }

  void _message(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: LenteraLogo(
                      size: 86,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'LENTERA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: darkGreen,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Literasi Edukasi Narasi Terpadu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 48),

                  const Text(
                    'Selamat Datang',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    'Masuk untuk melanjutkan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: _identifierController,
                    enabled: !_loading,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email atau NIS',
                      hintText: 'Masukkan email atau NIS',
                      prefixIcon: Icon(
                        Icons.person_outline,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _passwordController,
                    enabled: !_loading,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _login(),
                    decoration: InputDecoration(
                      labelText: 'Kata sandi',
                      hintText: 'Masukkan kata sandi',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                      ),
                      suffixIcon: IconButton(
                        onPressed: _loading
                            ? null
                            : () {
                                setState(() {
                                  _obscurePassword =
                                      !_obscurePassword;
                                });
                              },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _loading
                          ? null
                          : _forgotPassword,
                      child: const Text(
                        'Lupa kata sandi?',
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _loading
                          ? null
                          : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'MASUK',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'Siswa dapat masuk menggunakan NIS.\n'
                    'Admin masuk menggunakan email admin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FIREBASE DATABASE SERVICE
// ============================================================

class LenteraDatabase {
  static final FirebaseDatabase database =
      FirebaseDatabase.instance;

  static Future<DataSnapshot>? _usersSnapshotFuture;

  static DatabaseReference get root =>
      database.ref();

  static Future<DataSnapshot> _getUsersSnapshot() {
    return _usersSnapshotFuture ??=
        root.child('users').get();
  }

  // ----------------------------------------------------------
  // SISWA
  // ----------------------------------------------------------

  static Future<List<Map<String, dynamic>>> getStudents() async {
    final snapshot = await _getUsersSnapshot();

    if (!snapshot.exists ||
        snapshot.value == null) {
      return [];
    }

    final value = snapshot.value;

    if (value is! Map) {
      return [];
    }

    final List<Map<String, dynamic>> result = [];

    for (final entry in value.entries) {
      final key = entry.key.toString();
      final raw = entry.value;

      if (raw is! Map) continue;

      final map =
          Map<String, dynamic>.from(raw);

      map['nis'] ??= key;

      result.add(map);
    }

    result.sort(
      (a, b) => (a['nama'] ?? '')
          .toString()
          .toLowerCase()
          .compareTo(
            (b['nama'] ?? '')
                .toString()
                .toLowerCase(),
          ),
    );

    return result;
  }

  // ----------------------------------------------------------
  // ABSENSI
  // ----------------------------------------------------------

  static Future<List<Map<String, dynamic>>> getAttendance() async {
    // Satu request untuk seluruh users, bukan satu request per siswa.
    final snapshot = await _getUsersSnapshot();
    if (!snapshot.exists || snapshot.value is! Map) return [];

    final users = Map<String, dynamic>.from(snapshot.value as Map);
    final List<Map<String, dynamic>> result = [];

    for (final entry in users.entries) {
      if (entry.value is! Map) continue;
      final student = Map<String, dynamic>.from(entry.value as Map);
      final nis = student['nis']?.toString() ?? entry.key.toString();
      final absensi = student['absensi'];
      if (absensi is! Map) continue;

      for (final attendanceEntry in absensi.entries) {
        if (attendanceEntry.value is! Map) continue;
        final attendance = Map<String, dynamic>.from(
          attendanceEntry.value as Map,
        );
        attendance['nis'] = nis;
        attendance['nama'] = student['nama'];
        attendance['kelas'] = student['kelas'];
        attendance['tanggal'] ??= attendanceEntry.key.toString();
        result.add(attendance);
      }
    }

    result.sort(
      (a, b) => (b['tanggal'] ?? '').toString().compareTo(
        (a['tanggal'] ?? '').toString(),
      ),
    );
    return result;
  }

  // ----------------------------------------------------------
  // PROGRES
  // ----------------------------------------------------------

  static Future<List<Map<String, dynamic>>> getProgress() async {
    final results = <Map<String, dynamic>>[];

    // Ambil progres sekali saja.
    final progressSnapshot = await root.child('progres').get();
    if (!progressSnapshot.exists || progressSnapshot.value is! Map) {
      return results;
    }

    // Ambil nama/kelas siswa sekali saja.
    final usersSnapshot = await _getUsersSnapshot();
    final users = usersSnapshot.exists && usersSnapshot.value is Map
        ? Map<String, dynamic>.from(usersSnapshot.value as Map)
        : <String, dynamic>{};

    final progressUsers = Map<String, dynamic>.from(
      progressSnapshot.value as Map,
    );

    for (final entry in progressUsers.entries) {
      final nis = entry.key.toString();
      final studentRaw = users[nis];
      final student = studentRaw is Map
          ? Map<String, dynamic>.from(studentRaw)
          : <String, dynamic>{};
      final value = entry.value;
      if (value is! Map) continue;

      for (final progressEntry in value.entries) {
        if (progressEntry.value is! Map) continue;
        final progress = Map<String, dynamic>.from(
          progressEntry.value as Map,
        );
        progress['nis'] = nis;
        progress['nama'] ??= student['nama'];
        progress['kelas'] ??= student['kelas'];
        progress['tanggal'] ??= progressEntry.key.toString();
        results.add(progress);
      }
    }

    results.sort(
      (a, b) => (b['tanggal'] ?? '').toString().compareTo(
        (a['tanggal'] ?? '').toString(),
      ),
    );
    return results;
  }

  // ----------------------------------------------------------
  // INTERUPSI
  // ----------------------------------------------------------

  static Future<List<Map<String, dynamic>>>
      getInterruptions() async {
    final snapshot =
        await root.child('interupsi').get();

    if (!snapshot.exists ||
        snapshot.value == null) {
      return [];
    }

    final value = snapshot.value;

    if (value is! Map) {
      return [];
    }

    final List<Map<String, dynamic>> result = [];

    for (final entry in value.entries) {
      final raw = entry.value;

      if (raw is Map) {
        final map =
            Map<String, dynamic>.from(raw);

        map['id'] =
            entry.key.toString();

        result.add(map);
      }
    }

    result.sort(
      (a, b) {
        final aTime =
            a['timestamp'] ??
                a['createdAt'] ??
                '';

        final bTime =
            b['timestamp'] ??
                b['createdAt'] ??
                '';

        return bTime
            .toString()
            .compareTo(
              aTime.toString(),
            );
      },
    );

    return result;
  }

  static Future<void> markAttendance({
    required String nis,
    required String nama,
    required String kelas,
  }) async {
    final now = DateTime.now();
    final date = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    await root.child('users').child(nis).child('absensi').child(date).set({
      'nis': nis,
      'nama': nama,
      'kelas': kelas,
      'tanggal': date,
      'status': 'Hadir',
      'keterangan': 'Hadir',
      'timestamp': ServerValue.timestamp,
    });
  }


  // ----------------------------------------------------------
  // LIVE TRACKING SESI MENGAJI
  // ----------------------------------------------------------

  static DatabaseReference liveSessionRef(String nis) =>
      root.child('sesi_mengaji').child(nis);

  static Future<void> startLiveSession({
    required String nis,
    required String nama,
    required String kelas,
    required String surat,
    required int ayat,
    required int durationSeconds,
  }) async {
    final ref = liveSessionRef(nis);

    await ref.set({
      'nis': nis,
      'nama': nama,
      'kelas': kelas,
      'surat': surat,
      'ayat': ayat,
      'durasiDetik': durationSeconds,
      'active': true,
      'status': 'Sedang membaca',
      'mulaiAt': ServerValue.timestamp,
      'updatedAt': ServerValue.timestamp,
    });

    await ref.onDisconnect().update({
      'active': false,
      'status': 'Terputus',
      'updatedAt': ServerValue.timestamp,
    });
  }

  static Future<void> updateLiveSession({
    required String nis,
    required String nama,
    required String kelas,
    required String surat,
    required int ayat,
    required int durationSeconds,
    bool active = true,
    String status = 'Sedang membaca',
  }) async {
    await liveSessionRef(nis).update({
      'nis': nis,
      'nama': nama,
      'kelas': kelas,
      'surat': surat,
      'ayat': ayat,
      'durasiDetik': durationSeconds,
      'active': active,
      'status': status,
      'updatedAt': ServerValue.timestamp,
    });
  }

  static Future<void> endLiveSession(String nis) async {
    final ref = liveSessionRef(nis);
    try {
      await ref.onDisconnect().cancel();
    } catch (_) {}
    await ref.remove();
  }

  // ----------------------------------------------------------
  // SIMPAN PROGRES
  // ----------------------------------------------------------

  static Future<void> saveProgress({
    required String nis,
    required String nama,
    required String kelas,
    required int durationSeconds,
    required String surat,
    required int lastAyat,
  }) async {
    final now = DateTime.now();

    final date =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    await root
        .child('progres')
        .child(nis)
        .child(date)
        .set({
      'nis': nis,
      'nama': nama,
      'kelas': kelas,
      'tanggal': date,
      'durasiDetik': durationSeconds,
      'surat': surat,
      'ayatTerakhir': lastAyat,
      'timestamp': ServerValue.timestamp,
    });
  }

  // ----------------------------------------------------------
  // CATAT INTERUPSI
  // ----------------------------------------------------------

  static Future<void> logInterruption({
    required String nis,
    required String nama,
    required String kelas,
    required String message,
  }) async {
    await root
        .child('interupsi')
        .push()
        .set({
      'nis': nis,
      'studentName': nama,
      'nama': nama,
      'className': kelas,
      'kelas': kelas,
      'message': message,
      'timestamp': ServerValue.timestamp,
      'createdAt': DateTime.now()
          .toIso8601String(),
    });
  }
  // Catat interupsi lengkap saat siswa meninggalkan halaman membaca.
  static Future<void> recordInterruption({
    required String nis,
    required String nama,
    required String kelas,
    required String surat,
    required int ayat,
    required int durationSeconds,
  }) async {
    await root.child('interupsi').push().set({
      'nis': nis,
      'studentName': nama,
      'nama': nama,
      'className': kelas,
      'kelas': kelas,
      'surat': surat,
      'ayat': ayat,
      'durasiDetik': durationSeconds,
      'message': 'Siswa meninggalkan halaman membaca',
      'timestamp': ServerValue.timestamp,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

}

// ============================================================
// ADMIN DASHBOARD
// ============================================================

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() =>
      _AdminDashboardState();
}

class _AdminDashboardState
    extends State<AdminDashboard> {
  int _selectedIndex = 0;

  Widget _currentPage() {
    switch (_selectedIndex) {
      case 1:
        return const AdminStudentsPage();
      case 2:
        return const AdminAttendancePage();
      case 3:
        return const AdminProgressPage();
      case 4:
        return const AdminInterruptionsPage();
      default:
        return const AdminOverviewPage();
    }
  }

  final List<String> _titles = const [
    'Dashboard',
    'Daftar Siswa',
    'Absensi',
    'Progres Al-Qur\'an',
    'Interupsi Membaca',
  ];

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: darkGreen,
          ),
        ),
        actions: [
          Padding(
            padding:
                const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Keluar',
              onPressed: _logout,
              icon: const Icon(
                Icons.logout_rounded,
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _currentPage(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                24,
                30,
                24,
                26,
              ),
              color: darkGreen,
              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  LenteraLogo(
                    size: 64,
                  ),
                  SizedBox(height: 18),
                  Text(
                    'LENTERA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Panel Administrator',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            _drawerItem(
              0,
              Icons.dashboard_outlined,
              'Dashboard',
            ),

            _drawerItem(
              1,
              Icons.people_outline,
              'Daftar Siswa',
            ),

            _drawerItem(
              2,
              Icons.calendar_month_outlined,
              'Absensi',
            ),

            _drawerItem(
              3,
              Icons.menu_book_outlined,
              'Progres Al-Qur\'an',
            ),

            _drawerItem(
              4,
              Icons.warning_amber_outlined,
              'Interupsi Membaca',
            ),

            const Spacer(),

            const Divider(),

            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text(
                'Keluar',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: _logout,
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    int index,
    IconData icon,
    String title,
  ) {
    final selected =
        _selectedIndex == index;

    return ListTile(
      selected: selected,
      selectedTileColor: lightGreen,
      leading: Icon(
        icon,
        color: selected
            ? primaryColor
            : Colors.grey.shade700,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected
              ? FontWeight.bold
              : FontWeight.normal,
          color: selected
              ? primaryColor
              : Colors.black87,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });

        Navigator.pop(context);
      },
    );
  }
}

// ============================================================
// ADMIN OVERVIEW
// ============================================================

class AdminOverviewPage extends StatefulWidget {
  const AdminOverviewPage({super.key});

  @override
  State<AdminOverviewPage> createState() =>
      _AdminOverviewPageState();
}

class _AdminOverviewPageState
    extends State<AdminOverviewPage> {
  bool _loading = true;

  int _students = 0;
  int _attendance = 0;
  int _progress = 0;
  int _interruptions = 0;

  List<Map<String, dynamic>> _latestInterruptions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    try {
      final data = await Future.wait([
        LenteraDatabase.getStudents(),
        LenteraDatabase.getAttendance(),
        LenteraDatabase.getProgress(),
        LenteraDatabase.getInterruptions(),
      ]);

      final students = data[0] as List<Map<String, dynamic>>;
      final attendance = data[1] as List<Map<String, dynamic>>;
      final progress = data[2] as List<Map<String, dynamic>>;
      final interruptions = data[3] as List<Map<String, dynamic>>;

      if (!mounted) return;

      setState(() {
        _students = students.length;
        _attendance = attendance.length;
        _progress = progress.length;
        _interruptions =
            interruptions.length;

        _latestInterruptions =
            interruptions.take(5).toList();

        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengambil data: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Selamat datang, Admin 👋',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Pantau aktivitas literasi siswa secara terpusat.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 24),

          GridView.count(
            crossAxisCount:
                MediaQuery.of(context).size.width >
                        800
                    ? 4
                    : 2,
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.55,
            children: [
              AdminStatCard(
                title: 'Total Siswa',
                value: '$_students',
                icon: Icons.people_alt_outlined,
              ),
              AdminStatCard(
                title: 'Data Absensi',
                value: '$_attendance',
                icon: Icons.calendar_month_outlined,
              ),
              AdminStatCard(
                title: 'Data Progres',
                value: '$_progress',
                icon: Icons.menu_book_outlined,
              ),
              AdminStatCard(
                title: 'Interupsi',
                value: '$_interruptions',
                icon: Icons.warning_amber_outlined,
              ),
            ],
          ),

          const SizedBox(height: 28),

          const Text(
            'Interupsi Terbaru',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),

          const SizedBox(height: 12),

          if (_latestInterruptions.isEmpty)
            const EmptyCard(
              icon: Icons.check_circle_outline,
              text: 'Belum ada interupsi membaca.',
            )
          else
            ..._latestInterruptions.map(
              (item) => InterruptionCard(
                data: item,
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// ADMIN STAT CARD
// ============================================================

class AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const AdminStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE0E8E5),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: primaryColor,
                size: 25,
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
            ],
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ADMIN STUDENTS
// ============================================================

class AdminStudentsPage extends StatefulWidget {
  const AdminStudentsPage({super.key});

  @override
  State<AdminStudentsPage> createState() =>
      _AdminStudentsPageState();
}

class _AdminStudentsPageState
    extends State<AdminStudentsPage> {
  final TextEditingController _searchController =
      TextEditingController();

  bool _loading = true;

  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _filtered = [];
  final Map<String, Map<String, dynamic>> _liveSessions = {};
  StreamSubscription<DatabaseEvent>? _liveSubscription;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(
      _filter,
    );

    _load();
    _listenLiveSessions();
  }

  void _listenLiveSessions() {
    _liveSubscription = FirebaseDatabase.instance
        .ref('sesi_mengaji')
        .onValue
        .listen((event) {
      final next = <String, Map<String, dynamic>>{};
      final value = event.snapshot.value;

      if (value is Map) {
        for (final entry in value.entries) {
          if (entry.value is! Map) continue;
          final session = Map<String, dynamic>.from(entry.value as Map);
          final nis = session['nis']?.toString() ?? entry.key.toString();
          final active = session['active'] == true;
          if (active) {
            next[nis] = session;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _liveSessions
          ..clear()
          ..addAll(next);
      });
    });
  }

  @override
  void dispose() {
    _liveSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _filter() {
    final query =
        _searchController.text
            .trim()
            .toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filtered = List.from(_students);
      } else {
        _filtered = _students.where((student) {
          final nama =
              student['nama']
                  ?.toString()
                  .toLowerCase() ??
              '';

          final nis =
              student['nis']
                  ?.toString()
                  .toLowerCase() ??
              '';

          final kelas =
              student['kelas']
                  ?.toString()
                  .toLowerCase() ??
              '';

          return nama.contains(query) ||
              nis.contains(query) ||
              kelas.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    try {
      final data =
          await LenteraDatabase.getStudents();

      if (!mounted) return;

      setState(() {
        _students = data;
        _filtered = List.from(data);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText:
                  'Cari nama, NIS, atau kelas...',
              prefixIcon: Icon(
                Icons.search,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.wifi_tethering,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_liveSessions.length} siswa sedang membaca',
                    style: const TextStyle(
                      color: darkGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Text(
            '${_filtered.length} siswa ditemukan',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 12),

          if (_filtered.isEmpty)
            const EmptyCard(
              icon: Icons.people_outline,
              text: 'Data siswa tidak ditemukan.',
            )
          else
            ..._filtered.map(
              (student) =>
                  StudentCard(
                student: student,
                liveSession: _liveSessions[student['nis']?.toString()],
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// STUDENT CARD
// ============================================================

class StudentCard extends StatelessWidget {
  final Map<String, dynamic> student;
  final Map<String, dynamic>? liveSession;

  const StudentCard({
    super.key,
    required this.student,
    this.liveSession,
  });

  @override
  Widget build(BuildContext context) {
    final nama = student['nama']?.toString() ?? 'Tanpa Nama';
    final nis = student['nis']?.toString() ?? '-';
    final kelas = student['kelas']?.toString() ?? '-';
    final isLive = liveSession?['active'] == true;

    final surat = liveSession?['surat']?.toString() ?? '-';
    final ayat = liveSession?['ayat']?.toString() ?? '-';
    final duration = _formatLiveDuration(liveSession?['durasiDetik']);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isLive ? primaryColor.withOpacity(0.35) : const Color(0xFFE0E8E5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentDetailPage(student: student),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: lightGreen,
                    child: Text(
                      nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nama,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: darkGreen,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text('NIS: $nis  •  Kelas: $kelas'),
                      ],
                    ),
                  ),
                  Icon(
                    isLive ? Icons.circle : Icons.circle_outlined,
                    size: 13,
                    color: isLive ? Colors.green : Colors.grey,
                  ),
                ],
              ),
              if (isLive) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.menu_book_rounded,
                            size: 18,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 7),
                          const Expanded(
                            child: Text(
                              'SEDANG MEMBACA',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            duration,
                            style: const TextStyle(
                              color: darkGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Surat: $surat  •  Ayat: $ayat',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: darkGreen,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Data diperbarui otomatis secara realtime.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: 8),
                const Text(
                  'Belum sedang membaca',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatLiveDuration(dynamic value) {
    final seconds = value is num
        ? value.toInt()
        : int.tryParse(value?.toString() ?? '') ?? 0;
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

// ============================================================
// STUDENT DETAIL + LIVE TRACKING
// ============================================================

class StudentDetailPage extends StatelessWidget {
  final Map<String, dynamic> student;

  const StudentDetailPage({
    super.key,
    required this.student,
  });

  String _formatDuration(dynamic value) {
    final seconds = value is num
        ? value.toInt()
        : int.tryParse(value?.toString() ?? '') ?? 0;

    final minutes = seconds ~/ 60;
    final secs = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final nama = student['nama']?.toString() ?? '-';
    final nis = student['nis']?.toString() ?? '-';
    final nisn = student['nisn']?.toString() ?? '-';
    final kelas = student['kelas']?.toString() ?? '-';
    final gender = student['jenisKelamin']?.toString() ?? '-';
    final email = student['email']?.toString() ?? '-';

    // Dengarkan khusus siswa yang sedang dibuka.
    final liveRef =
        FirebaseDatabase.instance.ref('sesi_mengaji/$nis');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Siswa'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          // ======================================================
          // BIODATA
          // ======================================================

          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: darkGreen,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: Colors.white,
                  child: Text(
                    nama.isNotEmpty
                        ? nama[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  nama,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'NIS $nis',
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ======================================================
          // LIVE TRACKING
          // ======================================================

          StreamBuilder<DatabaseEvent>(
            stream: liveRef.onValue,

            builder: (context, snapshot) {
              Map<String, dynamic>? liveData;

              if (snapshot.hasData &&
                  snapshot.data!.snapshot.value != null) {

                final raw =
                    snapshot.data!.snapshot.value;

                if (raw is Map) {
                  liveData =
                      Map<String, dynamic>.from(raw);
                }
              }

              final isLive =
                  liveData?['active'] == true;

              final surat =
                  liveData?['surat']?.toString() ?? '-';

              final ayat =
                  liveData?['ayat']?.toString() ?? '-';

              final durasi =
                  liveData?['durasiDetik'];

              final status =
                  liveData?['status']?.toString() ??
                  'Tidak sedang membaca';

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: isLive
                      ? lightGreen
                      : Colors.white,

                  borderRadius:
                      BorderRadius.circular(20),

                  border: Border.all(
                    color: isLive
                        ? primaryColor
                        : const Color(0xFFE0E8E5),
                    width: isLive ? 1.5 : 1,
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    // HEADER LIVE
                    Row(
                      children: [

                        Icon(
                          isLive
                              ? Icons.circle
                              : Icons.circle_outlined,

                          color: isLive
                              ? Colors.green
                              : Colors.grey,

                          size: 14,
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            isLive
                                ? 'SEDANG MEMBACA AL-QUR\'AN'
                                : 'TIDAK SEDANG MEMBACA',

                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,

                              color: isLive
                                  ? primaryColor
                                  : Colors.grey,
                            ),
                          ),
                        ),

                        if (isLive)
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // STATUS
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(14),
                      ),

                      child: Row(
                        children: [

                          const Icon(
                            Icons.info_outline,
                            color: primaryColor,
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              status,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // POSISI BACAAN
                    const Text(
                      'Posisi Bacaan Saat Ini',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [

                        Expanded(
                          child: _LiveInfoBox(
                            icon:
                                Icons.menu_book_rounded,
                            title: 'SURAT',
                            value: surat,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _LiveInfoBox(
                            icon:
                                Icons.format_list_numbered,
                            title: 'AYAT',
                            value: ayat,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // DURASI
                    _LiveInfoBox(
                      icon: Icons.timer_outlined,
                      title: 'DURASI MEMBACA',
                      value: _formatDuration(durasi),
                    ),

                    const SizedBox(height: 14),

                    if (isLive)
                      const Text(
                        'Perubahan surat dan ayat akan '
                        'terlihat otomatis secara realtime.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // ======================================================
          // DATA SISWA
          // ======================================================

          InfoTile(
            icon: Icons.badge_outlined,
            title: 'NIS',
            value: nis,
          ),

          InfoTile(
            icon: Icons.credit_card_outlined,
            title: 'NISN',
            value: nisn,
          ),

          InfoTile(
            icon: Icons.class_outlined,
            title: 'Kelas',
            value: kelas,
          ),

          InfoTile(
            icon: Icons.person_outline,
            title: 'Jenis Kelamin',
            value: gender,
          ),

          InfoTile(
            icon: Icons.email_outlined,
            title: 'Email',
            value: email,
          ),
        ],
      ),
    );
  }
}


// ============================================================
// LIVE INFO BOX
// ============================================================

class _LiveInfoBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _LiveInfoBox({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(0xFFF5FAF8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE0E8E5),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: primaryColor,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INFO TILE
// ============================================================

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const InfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: primaryColor,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: darkGreen,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ADMIN ATTENDANCE
// ============================================================

class AdminAttendancePage
    extends StatefulWidget {
  const AdminAttendancePage({super.key});

  @override
  State<AdminAttendancePage> createState() =>
      _AdminAttendancePageState();
}

class _AdminAttendancePageState extends State<AdminAttendancePage> {
  bool _loading = true;
  List<Map<String, dynamic>> _data = [];
  String _selectedClass = 'Semua Kelas';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await LenteraDatabase.getAttendance();
      if (!mounted) return;
      setState(() { _data = data; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<String> get _classes {
    final classes = _data.map((e) => (e['kelas'] ?? e['className'] ?? '').toString().trim()).where((e) => e.isNotEmpty).toSet().toList();
    classes.sort();
    return ['Semua Kelas', ...classes];
  }

  List<Map<String, dynamic>> get _filteredData {
    if (_selectedClass == 'Semua Kelas') return _data;
    return _data.where((e) => (e['kelas'] ?? e['className'] ?? '').toString() == _selectedClass).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: primaryColor));
    final filtered = _filteredData;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(children: [
            const Icon(Icons.calendar_month, color: primaryColor),
            const SizedBox(width: 10),
            Expanded(child: Text('${filtered.length} data absensi', style: const TextStyle(fontWeight: FontWeight.bold, color: darkGreen))),
          ]),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _selectedClass,
            decoration: const InputDecoration(labelText: 'Filter Kelas', prefixIcon: Icon(Icons.class_outlined)),
            items: _classes.map((kelas) => DropdownMenuItem(value: kelas, child: Text(kelas))).toList(),
            onChanged: (value) { if (value != null) setState(() => _selectedClass = value); },
          ),
          const SizedBox(height: 15),
          if (filtered.isEmpty) const EmptyCard(icon: Icons.event_busy_outlined, text: 'Belum ada data absensi untuk kelas ini.')
          else ...filtered.map((item) => AttendanceCard(data: item)),
        ],
      ),
    );
  }
}

// ============================================================
// ATTENDANCE CARD
// ============================================================

class AttendanceCard
    extends StatelessWidget {
  final Map<String, dynamic> data;

  const AttendanceCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final nama =
        data['nama']
            ?.toString() ??
        data['studentName']
            ?.toString() ??
        '-';

    final kelas =
        data['kelas']
            ?.toString() ??
        data['className']
            ?.toString() ??
        '-';

    final tanggal =
        data['tanggal']
            ?.toString() ??
        '-';

    final status =
        data['status']
            ?.toString() ??
        data['keterangan']
            ?.toString() ??
        data['kehadiran']
            ?.toString() ??
        'Hadir';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: lightGreen,
          child: const Icon(
            Icons.event_available,
            color: primaryColor,
          ),
        ),
        title: Text(
          nama,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '$kelas • $tanggal',
        ),
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: lightGreen,
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ADMIN PROGRESS
// ============================================================

class AdminProgressPage
    extends StatefulWidget {
  const AdminProgressPage({super.key});

  @override
  State<AdminProgressPage> createState() =>
      _AdminProgressPageState();
}

class _AdminProgressPageState extends State<AdminProgressPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _data = [];
  String _selectedClass = 'Semua Kelas';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await LenteraDatabase.getProgress();
      if (!mounted) return;
      setState(() { _data = data; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<String> get _classes {
    final classes = _data.map((e) => (e['kelas'] ?? e['className'] ?? '').toString().trim()).where((e) => e.isNotEmpty).toSet().toList();
    classes.sort();
    return ['Semua Kelas', ...classes];
  }

  List<Map<String, dynamic>> get _filteredData {
    if (_selectedClass == 'Semua Kelas') return _data;
    return _data.where((e) => (e['kelas'] ?? e['className'] ?? '').toString() == _selectedClass).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: primaryColor));
    final filtered = _filteredData;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Progres Literasi Al-Qur\'an', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkGreen)),
          const SizedBox(height: 5),
          Text('${filtered.length} aktivitas membaca tercatat', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 18),
          DropdownButtonFormField<String>(
            value: _selectedClass,
            decoration: const InputDecoration(labelText: 'Filter Kelas', prefixIcon: Icon(Icons.class_outlined)),
            items: _classes.map((kelas) => DropdownMenuItem(value: kelas, child: Text(kelas))).toList(),
            onChanged: (value) { if (value != null) setState(() => _selectedClass = value); },
          ),
          const SizedBox(height: 15),
          if (filtered.isEmpty) const EmptyCard(icon: Icons.menu_book_outlined, text: 'Belum ada progres membaca untuk kelas ini.')
          else ...filtered.map((item) => ProgressCard(data: item)),
        ],
      ),
    );
  }
}

// ============================================================
// PROGRESS CARD
// ============================================================

class ProgressCard
    extends StatelessWidget {
  final Map<String, dynamic> data;

  const ProgressCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final nama =
        data['nama']
            ?.toString() ??
        data['studentName']
            ?.toString() ??
        '-';

    final kelas =
        data['kelas']
            ?.toString() ??
        data['className']
            ?.toString() ??
        '-';

    final tanggal =
        data['tanggal']
            ?.toString() ??
        '-';

    final surat =
        data['surat']
            ?.toString() ??
        '-';

    final ayat =
        data['ayatTerakhir']
            ?.toString() ??
        data['lastAyat']
            ?.toString() ??
        '-';

    final durasi =
        data['durasiDetik']
            ?.toString() ??
        data['durationSeconds']
            ?.toString() ??
        '0';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      color: Colors.white,
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    color: primaryColor,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        nama,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                          color: darkGreen,
                        ),
                      ),
                      Text(
                        '$kelas • $tanggal',
                        style:
                            const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(
              height: 24,
            ),

            Row(
              children: [
                Expanded(
                  child: _ProgressInfo(
                    title: 'Surat',
                    value: surat,
                  ),
                ),
                Expanded(
                  child: _ProgressInfo(
                    title: 'Ayat terakhir',
                    value: ayat,
                  ),
                ),
                Expanded(
                  child: _ProgressInfo(
                    title: 'Durasi',
                    value: _formatDuration(durasi),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(
    String value,
  ) {
    final seconds =
        int.tryParse(value) ?? 0;

    final minutes =
        seconds ~/ 60;

    return '$minutes menit';
  }
}

class _ProgressInfo
    extends StatelessWidget {
  final String title;
  final String value;

  const _ProgressInfo({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: darkGreen,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ADMIN INTERRUPTIONS
// ============================================================

class AdminInterruptionsPage
    extends StatefulWidget {
  const AdminInterruptionsPage({
    super.key,
  });

  @override
  State<AdminInterruptionsPage> createState() =>
      _AdminInterruptionsPageState();
}

class _AdminInterruptionsPageState
    extends State<AdminInterruptionsPage> {
  bool _loading = true;

  List<Map<String, dynamic>> _data = [];

  StreamSubscription<DatabaseEvent>?
      _subscription;

  @override
  void initState() {
    super.initState();

    _load();

    // Realtime monitoring.
    _subscription = FirebaseDatabase
        .instance
        .ref('interupsi')
        .onValue
        .listen((_) {
      _load();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data =
          await LenteraDatabase
              .getInterruptions();

      if (!mounted) return;

      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding:
                const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E5),
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 30,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Halaman ini memantau ketika siswa '
                    'meninggalkan sesi membaca Al-Qur\'an.',
                    style: TextStyle(
                      color: Color(0xFF7A4B00),
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            '${_data.length} interupsi tercatat',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),

          const SizedBox(height: 12),

          if (_data.isEmpty)
            const EmptyCard(
              icon:
                  Icons.check_circle_outline,
              text:
                  'Belum ada interupsi.',
            )
          else
            ..._data.map(
              (item) =>
                  InterruptionCard(
                data: item,
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// INTERRUPTION CARD
// ============================================================

class InterruptionCard
    extends StatelessWidget {
  final Map<String, dynamic> data;

  const InterruptionCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final nama =
        data['nama']
            ?.toString() ??
        data['studentName']
            ?.toString() ??
        '-';

    final kelas =
        data['kelas']
            ?.toString() ??
        data['className']
            ?.toString() ??
        '-';

    final nis =
        data['nis']
            ?.toString() ??
        '-';

    final message =
        data['message']
            ?.toString() ??
        'Meninggalkan sesi membaca';

    final timestamp =
        data['createdAt']
            ?.toString() ??
        data['timestamp']
            ?.toString() ??
        '-';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFF0E2CA),
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.all(14),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4E5),
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
          ),
        ),
        title: Text(
          nama,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: darkGreen,
          ),
        ),
        subtitle: Padding(
          padding:
              const EdgeInsets.only(
            top: 5,
          ),
          child: Text(
            '$message\n'
            'NIS: $nis • Kelas: $kelas\n'
            '$timestamp',
          ),
        ),
      ),
    );
  }
}

// ============================================================
// STUDENT DASHBOARD
// ============================================================

class StudentDashboard
    extends StatefulWidget {
  const StudentDashboard({
    super.key,
  });

  @override
  State<StudentDashboard> createState() =>
      _StudentDashboardState();
}

class _StudentDashboardState
    extends State<StudentDashboard> {
  int _index = 0;

  Map<String, dynamic>? _student;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  Future<void> _loadStudent() async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    try {
      final snapshot =
          await FirebaseDatabase
              .instance
              .ref('users')
              .get();

      if (!snapshot.exists ||
          snapshot.value is! Map) {
        setState(() {
          _loading = false;
        });
        return;
      }

      final users =
          Map<String, dynamic>.from(
        snapshot.value as Map,
      );

      Map<String, dynamic>?
          found;

      for (final entry
          in users.entries) {
        if (entry.value is! Map) {
          continue;
        }

        final student =
            Map<String, dynamic>.from(
          entry.value as Map,
        );

        final authUid =
            student['authUid']
                ?.toString();

        if (authUid == user.uid) {
          student['nis'] ??=
              entry.key.toString();

          found = student;
          break;
        }
      }

      if (!mounted) return;

      setState(() {
        _student = found;
        _loading = false;
      });

      // Absensi otomatis tercatat saat siswa membuka aplikasi hari ini.
      if (found != null) {
        LenteraDatabase.markAttendance(
          nis: found['nis']?.toString() ?? '',
          nama: found['nama']?.toString() ?? '',
          kelas: found['kelas']?.toString() ?? '',
        ).catchError((_) {});
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        ),
      );
    }

    if (_student == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'LENTERA',
          ),
          actions: [
            IconButton(
              onPressed: _logout,
              icon: const Icon(
                Icons.logout,
              ),
            ),
          ],
        ),
        body: const Center(
          child: Text(
            'Data siswa tidak ditemukan.',
          ),
        ),
      );
    }

    final pages = [
      StudentHomePage(
        student: _student!,
        onOpenReading: () => setState(() => _index = 1),
        onOpenProgress: () => setState(() => _index = 2),
      ),
      ReadingPage(
        student: _student!,
        onFinished: () => setState(() => _index = 0),
      ),
      StudentProgressPage(
        student: _student!,
      ),
      StudentProfilePage(
        student: _student!,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LENTERA',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: darkGreen,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Keluar',
            onPressed: _logout,
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: pages[_index],
      bottomNavigationBar:
          NavigationBar(
        selectedIndex: _index,
        onDestinationSelected:
            (index) {
          setState(() {
            _index = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.menu_book_outlined,
            ),
            selectedIcon: Icon(
              Icons.menu_book,
            ),
            label: 'Mengaji',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.bar_chart_outlined,
            ),
            selectedIcon: Icon(
              Icons.bar_chart,
            ),
            label: 'Progres',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
            ),
            selectedIcon: Icon(
              Icons.person,
            ),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STUDENT HOME
// ============================================================

class StudentHomePage
    extends StatelessWidget {
  final Map<String, dynamic> student;
  final VoidCallback onOpenReading;
  final VoidCallback onOpenProgress;

  const StudentHomePage({
    super.key,
    required this.student,
    required this.onOpenReading,
    required this.onOpenProgress,
  });

  @override
  Widget build(BuildContext context) {
    final nama =
        student['nama']
            ?.toString() ??
        'Siswa';

    final kelas =
        student['kelas']
            ?.toString() ??
        '-';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding:
              const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: darkGreen,
            borderRadius:
                BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Assalamu\'alaikum 👋',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                nama,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Kelas $kelas',
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        const Text(
          'Aktivitas Literasi',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: darkGreen,
          ),
        ),

        const SizedBox(height: 12),

        _StudentMenuCard(
          icon: Icons.menu_book,
          title:
              'Mulai Membaca Al-Qur\'an',
          subtitle:
              'Lanjutkan aktivitas mengaji hari ini.',
          onTap: onOpenReading,
        ),

        _StudentMenuCard(
          icon: Icons.bar_chart,
          title: 'Lihat Progres',
          subtitle:
              'Pantau perkembangan literasi kamu.',
          onTap: onOpenProgress,
        ),

        _StudentMenuCard(
          icon: Icons.calendar_month,
          title: 'Absensi',
          subtitle:
              'Lihat catatan kehadiran kamu.',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    StudentAttendancePage(
                  student: student,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ============================================================
// STUDENT MENU CARD
// ============================================================

class _StudentMenuCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _StudentMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.all(14),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: lightGreen,
            borderRadius:
                BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: primaryColor,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: darkGreen,
          ),
        ),
        subtitle: Text(
          subtitle,
        ),
        trailing: const Icon(
          Icons.chevron_right,
        ),
        onTap: onTap,
      ),
    );
  }
}

// ============================================================
// READING PAGE
// ============================================================

class ReadingPage
    extends StatefulWidget {
  final Map<String, dynamic> student;
  final VoidCallback? onFinished;

  const ReadingPage({
    super.key,
    required this.student,
    this.onFinished,
  });

  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage>
    with WidgetsBindingObserver {
  Timer? _timer;

  int _seconds = 0;
  int _lastAyat = 1;
  String _selectedSurah = quranSurahs.first;

  bool _started = false;
  bool _saving = false;
  bool _liveUpdating = false;

  String get _nis => widget.student['nis']?.toString() ?? '';
  String get _nama => widget.student['nama']?.toString() ?? '';
  String get _kelas => widget.student['kelas']?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startReading();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  super.didChangeAppLifecycleState(state);

  if (!_started || _saving) return;

  if (state == AppLifecycleState.paused) {
    _setLiveActive(false);
    _handleInterruption();
  } else if (state == AppLifecycleState.resumed) {
    _setLiveActive(true);
    _handleResume();
  }
}

Future<void> _handleInterruption() async {
  if (!_started || _saving || _nis.isEmpty) return;

  debugPrint('⚠️ INTERUPSI TERDETEKSI: $_nis');

  try {
    await LenteraDatabase.recordInterruption(
      nis: _nis,
      nama: _nama,
      kelas: _kelas,
      surat: _selectedSurah,
      ayat: _lastAyat,
      durationSeconds: _seconds,
    );
  } catch (e) {
    debugPrint('Gagal mencatat interupsi: $e');
  }
}

Future<void> _handleResume() async {
  if (!_started || _saving || _nis.isEmpty) return;

  debugPrint('✅ SISWA KEMBALI KE APLIKASI: $_nis');

  await _pushLiveSession();
}
  Future<void> _startReading() async {
    _started = true;

    try {
      await LenteraDatabase.startLiveSession(
        nis: _nis,
        nama: _nama,
        kelas: _kelas,
        surat: _selectedSurah,
        ayat: _lastAyat,
        durationSeconds: _seconds,
      );
    } catch (e) {
      debugPrint('Gagal memulai live tracking: $e');
    }

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted || !_started) return;

        setState(() {
          _seconds++;
        });

        // Kirim pembaruan setiap 5 detik agar Firebase tetap ringan.
        if (_seconds % 5 == 0) {
          _pushLiveSession();
        }
      },
    );
  }

  Future<void> _pushLiveSession() async {
    if (_liveUpdating || _saving || !_started || _nis.isEmpty) return;
    _liveUpdating = true;
    try {
      await LenteraDatabase.updateLiveSession(
        nis: _nis,
        nama: _nama,
        kelas: _kelas,
        surat: _selectedSurah,
        ayat: _lastAyat,
        durationSeconds: _seconds,
      );
    } catch (e) {
      debugPrint('Gagal memperbarui live tracking: $e');
    } finally {
      _liveUpdating = false;
    }
  }

  Future<void> _changeAyat(int value) async {
    final next = _lastAyat + value;
    if (next < 1) return;

    setState(() {
      _lastAyat = next;
    });
    await _pushLiveSession();
  }

  Future<void> _changeSurah(String? value) async {
    if (value == null || value == _selectedSurah) return;

    setState(() {
      _selectedSurah = value;
      _lastAyat = 1;
    });
    await _pushLiveSession();
  }

  Future<void> _saveAndExit() async {
    if (_saving) return;

    setState(() {
      _saving = true;
      _started = false;
    });

    _timer?.cancel();

    try {
      await LenteraDatabase.saveProgress(
        nis: _nis,
        nama: _nama,
        kelas: _kelas,
        durationSeconds: _seconds,
        surat: _selectedSurah,
        lastAyat: _lastAyat,
      );

      await LenteraDatabase.endLiveSession(_nis);
    } catch (e) {
      debugPrint('Gagal menyimpan progres: $e');
      try {
        await LenteraDatabase.endLiveSession(_nis);
      } catch (_) {}
    }

    if (!mounted) return;

    if (widget.onFinished != null) {
      widget.onFinished!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _setLiveActive(bool active) async {
    if (_nis.isEmpty || _saving) return;
    try {
      await LenteraDatabase.updateLiveSession(
        nis: _nis,
        nama: _nama,
        kelas: _kelas,
        surat: _selectedSurah,
        ayat: _lastAyat,
        durationSeconds: _seconds,
        active: active,
        status: active ? 'Sedang membaca' : 'Sementara berhenti',
      );
    } catch (_) {}
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _saveAndExit();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Membaca Al-Qur'an"),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: darkGreen,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 52,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Sesi Membaca',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _formatTime(_seconds),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_selectedSurah • Ayat $_lastAyat',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lokasi Bacaan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _selectedSurah,
                    decoration: const InputDecoration(
                      labelText: 'Surat',
                      prefixIcon: Icon(Icons.menu_book_outlined),
                    ),
                    items: quranSurahs
                        .map(
                          (surah) => DropdownMenuItem<String>(
                            value: surah,
                            child: Text(surah),
                          ),
                        )
                        .toList(),
                    onChanged: _saving ? null : _changeSurah,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _saving || _lastAyat <= 1
                              ? null
                              : () => _changeAyat(-1),
                          icon: const Icon(Icons.remove),
                          label: const Text('Ayat sebelumnya'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saving
                              ? null
                              : () => _changeAyat(1),
                          icon: const Icon(Icons.add),
                          label: const Text('Ayat berikutnya'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Ayat $_lastAyat',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: darkGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                children: [
                  Text(
                    "Simulasi Halaman Al-Qur'an",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                  SizedBox(height: 18),
                  Text(
                    'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: 28, height: 1.8),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17, height: 1.7),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _saveAndExit,
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(_saving ? 'Menyimpan...' : 'Selesai Membaca'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// STUDENT PROGRESS
// ============================================================

class StudentProgressPage
    extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentProgressPage({
    super.key,
    required this.student,
  });

  @override
  State<StudentProgressPage> createState() =>
      _StudentProgressPageState();
}

class _StudentProgressPageState
    extends State<StudentProgressPage> {
  bool _loading = true;

  List<Map<String, dynamic>> _data = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final nis =
        widget.student['nis']
            ?.toString() ??
        '';

    try {
      final snapshot =
          await FirebaseDatabase
              .instance
              .ref('progres')
              .child(nis)
              .get();

      final List<Map<String, dynamic>>
          result = [];

      if (snapshot.exists &&
          snapshot.value is Map) {
        final value =
            snapshot.value as Map;

        for (final entry
            in value.entries) {
          if (entry.value is Map) {
            final map =
                Map<String, dynamic>.from(
              entry.value as Map,
            );

            map['tanggal'] ??=
                entry.key.toString();

            result.add(map);
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _data = result;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Progres Literasi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            '${_data.length} aktivitas membaca',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 18),

          if (_data.isEmpty)
            const EmptyCard(
              icon:
                  Icons.menu_book_outlined,
              text:
                  'Belum ada progres membaca.',
            )
          else
            ..._data.map(
              (item) =>
                  ProgressCard(
                data: {
                  ...item,
                  'nama':
                      widget.student['nama'],
                  'kelas':
                      widget.student['kelas'],
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// STUDENT ATTENDANCE
// ============================================================

class StudentAttendancePage
    extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentAttendancePage({
    super.key,
    required this.student,
  });

  @override
  State<StudentAttendancePage> createState() =>
      _StudentAttendancePageState();
}

class _StudentAttendancePageState
    extends State<StudentAttendancePage> {
  bool _loading = true;

  List<Map<String, dynamic>> _data = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final nis =
        widget.student['nis']
            ?.toString() ??
        '';

    try {
      final snapshot =
          await FirebaseDatabase
              .instance
              .ref('users')
              .child(nis)
              .child('absensi')
              .get();

      final List<Map<String, dynamic>>
          result = [];

      if (snapshot.exists &&
          snapshot.value is Map) {
        final value =
            snapshot.value as Map;

        for (final entry
            in value.entries) {
          if (entry.value is Map) {
            final map =
                Map<String, dynamic>.from(
              entry.value as Map,
            );

            map['tanggal'] ??=
                entry.key.toString();

            result.add(map);
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _data = result;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        appBar: null,
        body: Center(
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Absensi',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding:
              const EdgeInsets.all(20),
          children: [
            if (_data.isEmpty)
              const EmptyCard(
                icon:
                    Icons.event_busy_outlined,
                text:
                    'Belum ada data absensi.',
              )
            else
              ..._data.map(
                (item) =>
                    AttendanceCard(
                  data: {
                    ...item,
                    'nama':
                        widget.student[
                            'nama'],
                    'kelas':
                        widget.student[
                            'kelas'],
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// STUDENT PROFILE
// ============================================================

class StudentProfilePage
    extends StatelessWidget {
  final Map<String, dynamic> student;

  const StudentProfilePage({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Center(
          child: LenteraLogo(
            size: 90,
          ),
        ),

        const SizedBox(height: 15),

        Text(
          student['nama']
                  ?.toString() ??
              '-',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: darkGreen,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'NIS ${student['nis'] ?? '-'}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 25),

        InfoTile(
          icon: Icons.badge_outlined,
          title: 'NIS',
          value:
              student['nis']
                      ?.toString() ??
                  '-',
        ),

        InfoTile(
          icon: Icons.credit_card,
          title: 'NISN',
          value:
              student['nisn']
                      ?.toString() ??
                  '-',
        ),

        InfoTile(
          icon: Icons.class_outlined,
          title: 'Kelas',
          value:
              student['kelas']
                      ?.toString() ??
                  '-',
        ),

        InfoTile(
          icon: Icons.person_outline,
          title: 'Jenis Kelamin',
          value:
              student['jenisKelamin']
                      ?.toString() ??
                  '-',
        ),

        InfoTile(
          icon: Icons.email_outlined,
          title: 'Email',
          value:
              student['email']
                      ?.toString() ??
                  '-',
        ),
      ],
    );
  }
}

// ============================================================
// EMPTY CARD
// ============================================================

class EmptyCard extends StatelessWidget {
  final IconData icon;
  final String text;

  const EmptyCard({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE0E8E5),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 45,
            color: Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}