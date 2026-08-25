import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

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
      home: const AuthGate(),
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

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LenteraLogo(size: 82),
            SizedBox(height: 20),
            Text(
              'LENTERA',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: darkGreen,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Literasi Edukasi Narasi Terpadu',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(
              color: primaryColor,
            ),
          ],
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
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: lightGreen,
        shape: BoxShape.circle,
        border: Border.all(
          color: primaryColor.withOpacity(.18),
          width: 2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(size * .08),
        child: Image.asset(
          'assets/lentera_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            Icons.menu_book_rounded,
            size: size * .48,
            color: primaryColor,
          ),
        ),
      ),
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
  // SIMPAN PROGRES
  // ----------------------------------------------------------

  static Future<void> saveProgress({
    required String nis,
    required String nama,
    required String kelas,
    required int durationSeconds,
    String surat = 'Tidak diketahui',
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
  // LIVE TRACKING SESI MENGAJI
  // ----------------------------------------------------------

  static Future<void> startLiveSession({
    required String nis,
    required String nama,
    required String kelas,
    required String surat,
    required int ayat,
    required int durationSeconds,
  }) async {
    if (nis.trim().isEmpty) return;

    await root
        .child('sesi_mengaji')
        .child(nis)
        .set({
      'nis': nis,
      'nama': nama,
      'kelas': kelas,
      'surat': surat,
      'ayat': ayat,
      'durasiDetik': durationSeconds,
      'active': true,
      'status': 'Sedang membaca',
      'startedAt': ServerValue.timestamp,
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
    String? status,
  }) async {
    if (nis.trim().isEmpty) return;

    await root
        .child('sesi_mengaji')
        .child(nis)
        .update({
      'nis': nis,
      'nama': nama,
      'kelas': kelas,
      'surat': surat,
      'ayat': ayat,
      'durasiDetik': durationSeconds,
      'active': active,
      'status': status ??
          (active ? 'Sedang membaca' : 'Terputus'),
      'updatedAt': ServerValue.timestamp,
    });
  }

  static Future<void> endLiveSession(String nis) async {
    if (nis.trim().isEmpty) return;

    await root
        .child('sesi_mengaji')
        .child(nis)
        .update({
      'active': false,
      'status': 'Selesai',
      'endedAt': ServerValue.timestamp,
      'updatedAt': ServerValue.timestamp,
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
      case 5:
        return const QuranReaderPage();
      case 6:
        return const AdminLiveTrackingPage();
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
    'Baca Al-Qur\'an',
    'Live Tracking',
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

            _drawerItem(
              5,
              Icons.menu_book_rounded,
              'Baca Al-Qur\'an',
            ),

            _drawerItem(
              6,
              Icons.radar_rounded,
              'Live Tracking',
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

  @override
  void initState() {
    super.initState();

    _searchController.addListener(
      _filter,
    );

    _load();
  }

  @override
  void dispose() {
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

          const SizedBox(height: 18),

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

  const StudentCard({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    final nama =
        student['nama']
            ?.toString() ??
        'Tanpa Nama';

    final nis =
        student['nis']
            ?.toString() ??
        '-';

    final kelas =
        student['kelas']
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
          color: Color(0xFFE0E8E5),
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        leading: CircleAvatar(
          backgroundColor: lightGreen,
          child: Text(
            nama.isNotEmpty
                ? nama[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          nama,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: darkGreen,
          ),
        ),
        subtitle: Text(
          'NIS: $nis  •  Kelas: $kelas',
        ),
        trailing: const Icon(
          Icons.chevron_right,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  StudentDetailPage(
                student: student,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// STUDENT DETAIL
// ============================================================

class StudentDetailPage extends StatelessWidget {
  final Map<String, dynamic> student;

  const StudentDetailPage({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    final nama =
        student['nama']
            ?.toString() ??
        '-';

    final nis =
        student['nis']
            ?.toString() ??
        '-';

    final nisn =
        student['nisn']
            ?.toString() ??
        '-';

    final kelas =
        student['kelas']
            ?.toString() ??
        '-';

    final gender =
        student['jenisKelamin']
            ?.toString() ??
        '-';

    final email =
        student['email']
            ?.toString() ??
        '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Siswa',
        ),
      ),
      body: ListView(
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
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor:
                      Colors.white,
                  child: Text(
                    nama.isNotEmpty
                        ? nama[0]
                            .toUpperCase()
                        : '?',
                    style:
                        const TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          primaryColor,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 14,
                ),
                Text(
                  nama,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  'NIS $nis',
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

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

class _AdminAttendancePageState
    extends State<AdminAttendancePage> {
  bool _loading = true;

  List<Map<String, dynamic>> _data = [];

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
      final data =
          await LenteraDatabase.getAttendance();

      if (!mounted) return;

      setState(() {
        _data = data;
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
          Row(
            children: [
              const Icon(
                Icons.calendar_month,
                color: primaryColor,
              ),
              const SizedBox(width: 10),
              Text(
                '${_data.length} data absensi',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          if (_data.isEmpty)
            const EmptyCard(
              icon: Icons.event_busy_outlined,
              text:
                  'Belum ada data absensi.',
            )
          else
            ..._data.map(
              (item) =>
                  AttendanceCard(
                data: item,
              ),
            ),
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

class _AdminProgressPageState
    extends State<AdminProgressPage> {
  bool _loading = true;

  List<Map<String, dynamic>> _data = [];

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
      final data =
          await LenteraDatabase.getProgress();

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
          const Text(
            'Progres Literasi Al-Qur\'an',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            '${_data.length} aktivitas membaca tercatat',
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
                data: item,
              ),
            ),
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
        data['surat']?.toString() ?? 'Surat belum tercatat';

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

            Text(
              'Surat: $surat',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _ProgressInfo(
                    title:
                        'Ayat terakhir',
                    value: ayat,
                  ),
                ),
                Expanded(
                  child: _ProgressInfo(
                    title:
                        'Durasi',
                    value:
                        _formatDuration(
                      durasi,
                    ),
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
// ADMIN LIVE TRACKING
// ============================================================

class AdminLiveTrackingPage extends StatefulWidget {
  const AdminLiveTrackingPage({super.key});

  @override
  State<AdminLiveTrackingPage> createState() => _AdminLiveTrackingPageState();
}

class _AdminLiveTrackingPageState extends State<AdminLiveTrackingPage> {
  StreamSubscription<DatabaseEvent>? _subscription;
  Map<String, dynamic> _sessions = {};

  @override
  void initState() {
    super.initState();
    _subscription = FirebaseDatabase.instance.ref('sesi_mengaji').onValue.listen((event) {
      final value = event.snapshot.value;
      if (!mounted) return;
      setState(() {
        _sessions = value is Map ? Map<String, dynamic>.from(value) : {};
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = _sessions.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));

    return RefreshIndicator(
      onRefresh: () async {
        final snap = await FirebaseDatabase.instance.ref('sesi_mengaji').get();
        final value = snap.value;
        if (mounted) {
          setState(() {
            _sessions = value is Map ? Map<String, dynamic>.from(value) : {};
          });
        }
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(Icons.radar_rounded, color: primaryColor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${entries.length} siswa sedang/baru melakukan sesi membaca.',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: darkGreen),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (entries.isEmpty)
            const EmptyCard(
              icon: Icons.hourglass_empty_rounded,
              text: 'Belum ada sesi mengaji aktif.',
            )
          else
            ...entries.map((entry) {
              final raw = entry.value;
              final data = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
              final active = data['active'] == true;
              final nama = data['nama']?.toString() ?? '-';
              final nis = data['nis']?.toString() ?? entry.key;
              final kelas = data['kelas']?.toString() ?? '-';
              final surat = data['surat']?.toString() ?? '-';
              final ayat = data['ayat']?.toString() ?? '-';
              final status = data['status']?.toString() ?? (active ? 'Sedang membaca' : 'Terputus');
              final duration = int.tryParse(data['durasiDetik']?.toString() ?? '') ?? 0;
              final minutes = duration ~/ 60;
              final seconds = duration % 60;

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: CircleAvatar(
                    backgroundColor: active ? lightGreen : const Color(0xFFFFF4E5),
                    child: Icon(active ? Icons.menu_book : Icons.warning_amber_rounded,
                        color: active ? primaryColor : Colors.orange),
                  ),
                  title: Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, color: darkGreen)),
                  subtitle: Text('NIS: $nis • Kelas: $kelas\n$surat • Ayat $ayat • ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'),
                  isThreeLine: true,
                  trailing: Text(
                    status,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: active ? primaryColor : Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }),
        ],
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
          icon: Icons.auto_stories_rounded,
          title: 'Baca Al-Qur\'an Lengkap',
          subtitle:
              'Baca seluruh surah dengan terjemahan dan warna tajwid.',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuranReaderPage(
                  student: student,
                ),
              ),
            );
          },
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
  State<ReadingPage> createState() =>
      _ReadingPageState();
}

class _ReadingPageState
    extends State<ReadingPage>
    with WidgetsBindingObserver {
  Timer? _timer;

  int _seconds = 0;
  int _lastAyat = 1;

  bool _started = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addObserver(this);

    _startReading();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startLiveTracking();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();

    WidgetsBinding.instance
        .removeObserver(this);

    super.dispose();
  }

  void _startReading() {
    _started = true;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted && _started) {
          setState(() {
            _seconds++;
          });
          if (_seconds % 5 == 0) {
            _updateLiveTracking();
          }
        }
      },
    );
  }

  Future<void> _startLiveTracking() async {
    final student = widget.student;
    try {
      await LenteraDatabase.startLiveSession(
        nis: student['nis']?.toString() ?? '',
        nama: student['nama']?.toString() ?? '',
        kelas: student['kelas']?.toString() ?? '',
        surat: 'Belum memilih surat',
        ayat: _lastAyat,
        durationSeconds: _seconds,
      );
    } catch (e) {
      debugPrint('Gagal memulai live tracking: $e');
    }
  }

  Future<void> _updateLiveTracking() async {
    final student = widget.student;
    try {
      await LenteraDatabase.updateLiveSession(
        nis: student['nis']?.toString() ?? '',
        nama: student['nama']?.toString() ?? '',
        kelas: student['kelas']?.toString() ?? '',
        surat: 'Belum memilih surat',
        ayat: _lastAyat,
        durationSeconds: _seconds,
      );
    } catch (_) {}
  }

  Future<void> _saveAndExit() async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    final nis = widget.student['nis']?.toString() ?? '';
    final nama = widget.student['nama']?.toString() ?? '';
    final kelas = widget.student['kelas']?.toString() ?? '';

    try {
      await LenteraDatabase.saveProgress(
        nis: nis,
        nama: nama,
        kelas: kelas,
        durationSeconds: _seconds,
        lastAyat: _lastAyat,
      );
    } catch (e) {
      debugPrint('Gagal menyimpan progres: $e');
    }

    _timer?.cancel();
    try {
      await LenteraDatabase.endLiveSession(widget.student['nis']?.toString() ?? '');
    } catch (_) {}

    if (!mounted) return;

    if (widget.onFinished != null) {
      widget.onFinished!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.paused) {
      _logBackgroundInterruption();
      _markLiveInterrupted();
    } else if (state == AppLifecycleState.resumed) {
      _startLiveTracking();
    }
  }

  Future<void> _markLiveInterrupted() async {
    final student = widget.student;
    try {
      await LenteraDatabase.updateLiveSession(
        nis: student['nis']?.toString() ?? '',
        nama: student['nama']?.toString() ?? '',
        kelas: student['kelas']?.toString() ?? '',
        surat: 'Belum memilih surat',
        ayat: _lastAyat,
        durationSeconds: _seconds,
        active: false,
        status: 'Terputus / meninggalkan aplikasi',
      );
    } catch (_) {}
  }

  Future<void>
      _logBackgroundInterruption() async {
    final nis =
        widget.student['nis']
            ?.toString() ??
        '';

    final nama =
        widget.student['nama']
            ?.toString() ??
        '';

    final kelas =
        widget.student['kelas']
            ?.toString() ??
        '';

    try {
      await LenteraDatabase.logInterruption(
        nis: nis,
        nama: nama,
        kelas: kelas,
        message:
            'Siswa meninggalkan halaman membaca',
      );
    } catch (_) {}
  }

  String _formatTime(
    int seconds,
  ) {
    final minutes =
        seconds ~/ 60;

    final secs =
        seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
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
          title: const Text(
            'Membaca Al-Qur\'an',
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding:
                  const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: darkGreen,
                borderRadius:
                    BorderRadius.circular(22),
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
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    _formatTime(_seconds),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding:
                  const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Text(
                    'Simulasi Halaman Al-Qur\'an',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                    textAlign: TextAlign.center,
                    textDirection:
                        TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 28,
                      height: 1.8,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Dengan nama Allah Yang Maha Pengasih, '
                    'Maha Penyayang.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.7,
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _lastAyat > 1
                            ? () {
                                setState(() {
                                  _lastAyat--;
                                });
                              }
                            : null,
                        icon: const Icon(
                          Icons.remove_circle_outline,
                        ),
                      ),

                      Text(
                        'Ayat $_lastAyat',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          setState(() {
                            _lastAyat++;
                          });
                        },
                        icon: const Icon(
                          Icons.add_circle_outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saving
                    ? null
                    : _saveAndExit,
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.check,
                      ),
                label: Text(
                  _saving
                      ? 'Menyimpan...'
                      : 'Selesai Membaca',
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      primaryColor,
                  foregroundColor:
                      Colors.white,
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

// ============================================================
// QURAN READER - FULL SURAH + INDONESIAN TRANSLATION + TAJWEED
// ============================================================

class QuranSurahInfo {
  final int number;
  final String name;
  final String englishName;
  final String englishTranslation;
  final int numberOfAyahs;

  const QuranSurahInfo({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishTranslation,
    required this.numberOfAyahs,
  });

  factory QuranSurahInfo.fromJson(Map<String, dynamic> json) {
    return QuranSurahInfo(
      number: (json['number'] as num?)?.toInt() ?? 1,
      name: json['name']?.toString() ?? '',
      englishName: json['englishName']?.toString() ?? '',
      englishTranslation:
          json['englishNameTranslation']?.toString() ?? '',
      numberOfAyahs: (json['numberOfAyahs'] as num?)?.toInt() ?? 0,
    );
  }
}

class QuranAyahData {
  final int numberInSurah;
  final String tajweedText;
  final String translation;

  const QuranAyahData({
    required this.numberInSurah,
    required this.tajweedText,
    required this.translation,
  });
}

class QuranReaderPage extends StatefulWidget {
  final Map<String, dynamic>? student;

  const QuranReaderPage({
    super.key,
    this.student,
  });

  @override
  State<QuranReaderPage> createState() => _QuranReaderPageState();
}

class _QuranReaderPageState extends State<QuranReaderPage>
    with WidgetsBindingObserver {
  static List<QuranSurahInfo>? _surahCache;

  List<QuranSurahInfo> _surahs = [];
  List<QuranAyahData> _ayahs = [];

  QuranSurahInfo? _selectedSurah;

  bool _loadingSurahs = true;
  bool _loadingAyahs = false;
  String? _error;

  int _lastAyah = 1;
  int _seconds = 0;
  Timer? _timer;
  DateTime? _startedAt;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startedAt = DateTime.now();
    _startTimer();
    _loadSurahs();
    if (widget.student != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startLiveTracking();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _seconds++);
        if (_seconds % 5 == 0) {
          _updateLiveTracking();
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && widget.student != null) {
      _recordInterruption();
      _markLiveInterrupted();
    } else if (state == AppLifecycleState.resumed && widget.student != null) {
      _startLiveTracking();
    }
  }

  Future<void> _markLiveInterrupted() async {
    final student = widget.student;
    if (student == null) return;
    try {
      await LenteraDatabase.updateLiveSession(
        nis: student['nis']?.toString() ?? '',
        nama: student['nama']?.toString() ?? '',
        kelas: student['kelas']?.toString() ?? '',
        surat: _selectedSurah?.name ?? 'Belum memilih surah',
        ayat: _lastAyah,
        durationSeconds: _seconds,
        active: false,
        status: 'Terputus / meninggalkan aplikasi',
      );
    } catch (_) {}
  }

  Future<void> _recordInterruption() async {
    final student = widget.student!;
    try {
      await LenteraDatabase.logInterruption(
        nis: student['nis']?.toString() ?? '',
        nama: student['nama']?.toString() ?? '',
        kelas: student['kelas']?.toString() ?? '',
        message: 'Siswa meninggalkan halaman baca Al-Qur\'an lengkap',
      );
    } catch (_) {}
  }

  Future<void> _startLiveTracking() async {
    final student = widget.student;
    if (student == null) return;
    try {
      await LenteraDatabase.startLiveSession(
        nis: student['nis']?.toString() ?? '',
        nama: student['nama']?.toString() ?? '',
        kelas: student['kelas']?.toString() ?? '',
        surat: _selectedSurah?.name ?? 'Memilih surah',
        ayat: _lastAyah,
        durationSeconds: _seconds,
      );
    } catch (e) {
      debugPrint('Gagal memulai live tracking: $e');
    }
  }

  Future<void> _updateLiveTracking() async {
    final student = widget.student;
    final surah = _selectedSurah;
    if (student == null || surah == null) return;
    try {
      await LenteraDatabase.updateLiveSession(
        nis: student['nis']?.toString() ?? '',
        nama: student['nama']?.toString() ?? '',
        kelas: student['kelas']?.toString() ?? '',
        surat: surah.name,
        ayat: _lastAyah,
        durationSeconds: _seconds,
      );
    } catch (e) {
      debugPrint('Gagal memperbarui live tracking: $e');
    }
  }

  Future<void> _loadSurahs() async {
    setState(() {
      _loadingSurahs = true;
      _error = null;
    });

    try {
      if (_surahCache == null) {
        final response = await http.get(
          Uri.parse('https://api.alquran.cloud/v1/surah'),
        );

        if (response.statusCode != 200) {
          throw Exception('Gagal mengambil daftar surah.');
        }

        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as List<dynamic>;

        _surahCache = data
            .map((item) => QuranSurahInfo.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList();
      }

      if (!mounted) return;

      setState(() {
        _surahs = List<QuranSurahInfo>.from(_surahCache!);
        _selectedSurah = _selectedSurah ?? _surahs.first;
        _loadingSurahs = false;
      });

      await _loadAyahs(_selectedSurah!);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingSurahs = false;
        _error = 'Tidak dapat memuat Al-Qur\'an. Periksa koneksi internet.';
      });
    }
  }

  Future<void> _loadAyahs(QuranSurahInfo surah) async {
    setState(() {
      _loadingAyahs = true;
      _error = null;
    });

    try {
      final responses = await Future.wait([
        http.get(
          Uri.parse(
            'https://api.alquran.cloud/v1/surah/${surah.number}/quran-tajweed',
          ),
        ),
        http.get(
          Uri.parse(
            'https://api.alquran.cloud/v1/surah/${surah.number}/id.indonesian',
          ),
        ),
      ]);

      if (responses[0].statusCode != 200 ||
          responses[1].statusCode != 200) {
        throw Exception('Gagal mengambil ayat.');
      }

      final tajweedBody =
          jsonDecode(responses[0].body) as Map<String, dynamic>;
      final translationBody =
          jsonDecode(responses[1].body) as Map<String, dynamic>;

      final tajweedData =
          Map<String, dynamic>.from(tajweedBody['data'] as Map);
      final translationData =
          Map<String, dynamic>.from(translationBody['data'] as Map);

      final tajweedAyahs = tajweedData['ayahs'] as List<dynamic>;
      final translationAyahs = translationData['ayahs'] as List<dynamic>;

      final translations = <int, String>{};
      for (final item in translationAyahs) {
        final map = Map<String, dynamic>.from(item as Map);
        final number = (map['numberInSurah'] as num?)?.toInt() ?? 0;
        translations[number] = map['text']?.toString() ?? '';
      }

      final result = <QuranAyahData>[];
      for (final item in tajweedAyahs) {
        final map = Map<String, dynamic>.from(item as Map);
        final number = (map['numberInSurah'] as num?)?.toInt() ?? 0;
        result.add(
          QuranAyahData(
            numberInSurah: number,
            tajweedText: map['text']?.toString() ?? '',
            translation: translations[number] ?? '',
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _ayahs = result;
        _lastAyah = 1;
        _loadingAyahs = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingAyahs = false;
        _ayahs = [];
        _error = 'Ayat tidak dapat dimuat. Coba pilih surah lagi.';
      });
    }
  }

  Future<void> _selectSurah(QuranSurahInfo? surah) async {
    if (surah == null) return;
    setState(() => _selectedSurah = surah);
    await _loadAyahs(surah);
    await _updateLiveTracking();
  }

  Future<void> _saveProgressAndExit() async {
    if (_saving) return;
    setState(() => _saving = true);

    _timer?.cancel();

    if (widget.student != null) {
      final student = widget.student!;
      try {
        await LenteraDatabase.saveProgress(
          nis: student['nis']?.toString() ?? '',
          nama: student['nama']?.toString() ?? '',
          kelas: student['kelas']?.toString() ?? '',
          durationSeconds: _seconds,
          surat: _selectedSurah?.name ?? 'Tidak diketahui',
          lastAyat: _lastAyah,
        );
      } catch (e) {
        debugPrint('Gagal menyimpan progres Quran: $e');
      }
    }

    if (widget.student != null) {
      try {
        await LenteraDatabase.endLiveSession(widget.student!['nis']?.toString() ?? '');
      } catch (_) {}
    }

    if (!mounted) return;
    Navigator.of(context).pop();
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
        await _saveProgressAndExit();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Baca Al-Qur\'an',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  _formatTime(_seconds),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        body: _loadingSurahs
            ? const Center(
                child: CircularProgressIndicator(color: primaryColor),
              )
            : _error != null && _surahs.isEmpty
                ? _buildErrorState()
                : Column(
                    children: [
                      _buildSurahSelector(),
                      _buildTajweedLegend(),
                      Expanded(child: _buildAyahList()),
                    ],
                  ),
        bottomNavigationBar: widget.student == null
            ? null
            : SafeArea(
                minimum: const EdgeInsets.all(12),
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _saveProgressAndExit,
                    icon: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(
                      _saving ? 'Menyimpan...' : 'Selesai Membaca',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 56,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Terjadi kesalahan.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _loadSurahs,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahSelector() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: Colors.white,
      child: DropdownButtonFormField<QuranSurahInfo>(
        value: _selectedSurah,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Pilih Surah',
          prefixIcon: const Icon(Icons.menu_book_rounded),
          filled: true,
          fillColor: backgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        items: _surahs.map((surah) {
          return DropdownMenuItem<QuranSurahInfo>(
            value: surah,
            child: Text(
              '${surah.number}. ${surah.englishName} — ${surah.name}',
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: _selectSurah,
      ),
    );
  }

  Widget _buildTajweedLegend() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      color: Colors.white,
      child: Wrap(
        spacing: 10,
        runSpacing: 6,
        children: const [
          _TajweedLegendItem('Mad', Color(0xFF4050FF)),
          _TajweedLegendItem('Qalqalah', Color(0xFFDD0008)),
          _TajweedLegendItem('Ikhfa', Color(0xFF9400A8)),
          _TajweedLegendItem('Idgham', Color(0xFF169200)),
          _TajweedLegendItem('Iqlab', Color(0xFF26BFFD)),
          _TajweedLegendItem('Ghunnah', Color(0xFFFF7E1E)),
        ],
      ),
    );
  }

  Widget _buildAyahList() {
    if (_loadingAyahs) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (_ayahs.isEmpty) {
      return Center(
        child: Text(_error ?? 'Belum ada ayat untuk ditampilkan.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      itemCount: _ayahs.length,
      itemBuilder: (context, index) {
        final ayah = _ayahs[index];
        final selected = ayah.numberInSurah == _lastAyah;

        return GestureDetector(
          onTap: () {
            setState(() => _lastAyah = ayah.numberInSurah);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFF0F8F5) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? primaryColor.withOpacity(.35)
                    : const Color(0xFFE1E9E6),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: lightGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${ayah.numberInSurah}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (selected)
                      const Icon(
                        Icons.bookmark_rounded,
                        color: primaryColor,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 29,
                        height: 2.0,
                        color: Color(0xFF1D2927),
                      ),
                      children: _TajweedParser.parse(
                        ayah.tajweedText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9F8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    ayah.translation,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.65,
                      color: Color(0xFF4D5B58),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TajweedLegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _TajweedLegendItem(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TajweedParser {
  static const Map<String, Color> _colors = {
    'h': Color(0xFFAAAAAA), // Hamzatul Wasl
    's': Color(0xFFAAAAAA), // Silent
    'l': Color(0xFFAAAAAA), // Lam Shamsiyyah
    'n': Color(0xFF537FFF), // Madd normal
    'p': Color(0xFF4050FF), // Madd permissible
    'm': Color(0xFF000EBC), // Madd necessary
    'q': Color(0xFFDD0008), // Qalqalah
    'o': Color(0xFF2144C1), // Madd obligatory
    'c': Color(0xFFD500B7), // Ikhfa Shafawi
    'f': Color(0xFF9400A8), // Ikhfa
    'w': Color(0xFF58B800), // Idgham Shafawi
    'i': Color(0xFF26BFFD), // Iqlab
    'a': Color(0xFF169777), // Idgham with ghunnah
    'u': Color(0xFF169200), // Idgham without ghunnah
    'd': Color(0xFFA1A1A1), // Idgham mutajanisayn
    'b': Color(0xFFA1A1A1), // Idgham mutaqaribayn
    'g': Color(0xFFFF7E1E), // Ghunnah
  };

  static const Set<String> _markers = {
    'h', 's', 'l', 'n', 'p', 'm', 'q', 'o',
    'c', 'f', 'w', 'i', 'a', 'u', 'd', 'b', 'g',
  };

  static List<TextSpan> parse(String text) {
    final parser = _Parser(text);
    return parser.parseUntil(null);
  }

  static Color colorFor(String marker) {
    return _colors[marker] ?? const Color(0xFF1D2927);
  }
}

class _Parser {
  final String text;
  int index = 0;

  _Parser(this.text);

  List<TextSpan> parseUntil(String? closing) {
    final spans = <TextSpan>[];
    final buffer = StringBuffer();

    void flush() {
      if (buffer.isEmpty) return;
      spans.add(TextSpan(text: buffer.toString()));
      buffer.clear();
    }

    while (index < text.length) {
      if (closing != null && text[index] == ']') {
        flush();
        index++;
        break;
      }

      if (text[index] == '[' && index + 1 < text.length) {
        final marker = text[index + 1];
        if (_TajweedParser._markers.contains(marker)) {
          flush();
          index += 2;

          if (index < text.length && text[index] == ':') {
            index++;
            while (index < text.length &&
                RegExp(r'\d').hasMatch(text[index])) {
              index++;
            }
          }

          if (index < text.length && text[index] == '[') {
            index++;
            final children = parseUntil(']');
            spans.add(
              TextSpan(
                style: TextStyle(
                  color: _TajweedParser.colorFor(marker),
                  fontWeight: FontWeight.w500,
                ),
                children: children,
              ),
            );
            continue;
          }

          buffer.write('[');
          buffer.write(marker);
          continue;
        }
      }

      buffer.write(text[index]);
      index++;
    }

    flush();
    return spans;
  }
}
