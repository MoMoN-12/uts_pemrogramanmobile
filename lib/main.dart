import 'package:flutter/material.dart';
//komenan
void main() {
  runApp(BioskopkuApp());
}

// --- MODELS ---
enum SeatStatus { available, selected, occupied }

class User {
  final String username;
  final String password;
  final String name;
  final String email;
  final String phone;

  const User({
    required this.username,
    required this.password,
    required this.name,
    required this.email,
    required this.phone,
  });
}

class Movie {
  final String id;
  final String title;
  final String posterUrl;
  final String description;
  final String genre;
  final String duration;
  final List<String> showtimes;
  final double rating;
  final int price;
  final String ageRating;
  final String director;
  final List<String> cast;
  final String theater;

  const Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.description,
    required this.genre,
    required this.duration,
    required this.showtimes,
    required this.rating,
    required this.price,
    required this.ageRating,
    required this.director,
    required this.cast,
    required this.theater,
  });
}

class Seat {
  final String id;
  final String row;
  final int number;
  SeatStatus status;
  final int price;
  final String type;

  Seat({
    required this.id,
    required this.row,
    required this.number,
    this.status = SeatStatus.available,
    required this.price,
    required this.type,
  });
}

class PaymentMethod {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  final int fee;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.fee,
  });
}

class BookingData {
  final Movie movie;
  final String showtime;
  final String date;
  final List<Seat> selectedSeats;
  final int totalPrice;
  final PaymentMethod? paymentMethod;
  final String? bookingId;
  final DateTime? paymentDate;

  const BookingData({
    required this.movie,
    required this.showtime,
    required this.date,
    required this.selectedSeats,
    required this.totalPrice,
    this.paymentMethod,
    this.bookingId,
    this.paymentDate,
  });

  BookingData copyWith({
    Movie? movie,
    String? showtime,
    String? date,
    List<Seat>? selectedSeats,
    int? totalPrice,
    PaymentMethod? paymentMethod,
    String? bookingId,
    DateTime? paymentDate,
  }) {
    return BookingData(
      movie: movie ?? this.movie,
      showtime: showtime ?? this.showtime,
      date: date ?? this.date,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      bookingId: bookingId ?? this.bookingId,
      paymentDate: paymentDate ?? this.paymentDate,
    );
  }
}

// --- SEAT BOOKING SYSTEM ---
class SeatBookingSystem {
  // Map untuk menyimpan kursi yang sudah dipesan
  // Key: "movieId_date_showtime_seatId"
  // Value: true (sudah dipesan)
  static Map<String, bool> bookedSeats = {};

  // Fungsi untuk membuat key unik untuk setiap kursi
  static String _createSeatKey(String movieId, String date, String showtime, String seatId) {
    return "${movieId}_${date}_${showtime}_$seatId";
  }

  // Fungsi untuk mengecek apakah kursi sudah dipesan
  static bool isSeatBooked(String movieId, String date, String showtime, String seatId) {
    final key = _createSeatKey(movieId, date, showtime, seatId);
    return bookedSeats[key] ?? false;
  }

  // Fungsi untuk memesan kursi
  static void bookSeats(String movieId, String date, String showtime, List<String> seatIds) {
    for (final seatId in seatIds) {
      final key = _createSeatKey(movieId, date, showtime, seatId);
      bookedSeats[key] = true;
    }
  }

  // Fungsi untuk membatalkan pemesanan kursi (jika diperlukan)
  static void cancelSeatBooking(String movieId, String date, String showtime, List<String> seatIds) {
    for (final seatId in seatIds) {
      final key = _createSeatKey(movieId, date, showtime, seatId);
      bookedSeats.remove(key);
    }
  }

  // Fungsi untuk mendapatkan semua kursi yang dipesan untuk sesi tertentu
  static List<String> getBookedSeatsForSession(String movieId, String date, String showtime) {
    final bookedSeatIds = <String>[];
    final sessionPrefix = "${movieId}_${date}_$showtime";

    bookedSeats.forEach((key, value) {
      if (key.startsWith(sessionPrefix) && value) {
        final seatId = key.split('_').last;
        bookedSeatIds.add(seatId);
      }
    });

    return bookedSeatIds;
  }

  // Fungsi untuk mendapatkan statistik kursi
  static Map<String, int> getSeatStatistics(String movieId, String date, String showtime) {
    final bookedSeatIds = getBookedSeatsForSession(movieId, date, showtime);
    final totalSeats = 80; // 8 rows x 10 seats
    final availableSeats = totalSeats - bookedSeatIds.length;

    return {
      'total': totalSeats,
      'booked': bookedSeatIds.length,
      'available': availableSeats,
    };
  }
}

// --- GLOBAL DATA ---
List<User> registeredUsers = [
  const User(
    username: 'demo',
    password: 'demo123',
    name: 'Demo User',
    email: 'demo@example.com',
    phone: '+62812345678',
  ),
  const User(
    username: 'user1',
    password: 'password1',
    name: 'John Doe',
    email: 'john@example.com',
    phone: '+62812345679',
  ),
  const User(
    username: 'admin',
    password: 'admin123',
    name: 'Admin User',
    email: 'admin@example.com',
    phone: '+62812345680',
  ),
];

List<Movie> movies = [
  const Movie(
    id: 'm1',
    title: 'Avengers: Endgame',
    posterUrl: 'https://via.placeholder.com/300x400/4A90E2/FFFFFF?text=Avengers',
    description: 'Adrift in space with no food or water, Tony Stark sends a message to Pepper Potts as his oxygen supply starts to dwindle. Meanwhile, the remaining Avengers must figure out a way to bring back their vanquished allies for an epic showdown with Thanos.',
    genre: 'Action',
    duration: '181 min',
    showtimes: ['12:00', '14:30', '17:00', '19:30', '22:00'],
    rating: 8.4,
    price: 35000,
    ageRating: '13+',
    director: 'Anthony Russo, Joe Russo',
    cast: ['Robert Downey Jr.', 'Chris Evans', 'Mark Ruffalo', 'Chris Hemsworth'],
    theater: 'Studio 1',
  ),
  const Movie(
    id: 'm2',
    title: 'Spider-Man: No Way Home',
    posterUrl: 'https://via.placeholder.com/300x400/E74C3C/FFFFFF?text=Spider-Man',
    description: 'With Spider-Man\'s identity now revealed, Peter asks Doctor Strange for help. When a spell goes wrong, dangerous foes from other worlds start to appear.',
    genre: 'Action',
    duration: '148 min',
    showtimes: ['11:00', '13:30', '16:00', '18:30', '21:00'],
    rating: 8.2,
    price: 35000,
    ageRating: '13+',
    director: 'Jon Watts',
    cast: ['Tom Holland', 'Zendaya', 'Benedict Cumberbatch', 'Jacob Batalon'],
    theater: 'Studio 2',
  ),
  const Movie(
    id: 'm3',
    title: 'Dune: Part Two',
    posterUrl: 'https://via.placeholder.com/300x400/F39C12/FFFFFF?text=Dune',
    description: 'Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators who destroyed his family.',
    genre: 'Sci-Fi',
    duration: '166 min',
    showtimes: ['10:00', '13:00', '16:00', '19:00'],
    rating: 8.8,
    price: 40000,
    ageRating: '13+',
    director: 'Denis Villeneuve',
    cast: ['Timothée Chalamet', 'Zendaya', 'Rebecca Ferguson', 'Oscar Isaac'],
    theater: 'Studio 3',
  ),
  const Movie(
    id: 'm4',
    title: 'The Batman',
    posterUrl: 'https://via.placeholder.com/300x400/2C3E50/FFFFFF?text=Batman',
    description: 'When the Riddler, a sadistic serial killer, begins murdering key political figures in Gotham, Batman is forced to investigate the city\'s hidden corruption.',
    genre: 'Action',
    duration: '176 min',
    showtimes: ['13:00', '16:30', '20:00'],
    rating: 7.8,
    price: 35000,
    ageRating: '17+',
    director: 'Matt Reeves',
    cast: ['Robert Pattinson', 'Zoë Kravitz', 'Paul Dano', 'Jeffrey Wright'],
    theater: 'Studio 1',
  ),
  const Movie(
    id: 'm5',
    title: 'Turning Red',
    posterUrl: 'https://via.placeholder.com/300x400/E67E22/FFFFFF?text=Turning+Red',
    description: 'A 13-year-old girl named Meilin turns into a giant red panda whenever she gets too excited.',
    genre: 'Animation',
    duration: '100 min',
    showtimes: ['10:30', '12:30', '14:30', '16:30'],
    rating: 7.0,
    price: 30000,
    ageRating: 'SU',
    director: 'Domee Shi',
    cast: ['Rosalie Chiang', 'Sandra Oh', 'Ava Morse', 'Hyein Park'],
    theater: 'Studio 4',
  ),
];

List<PaymentMethod> paymentMethods = [
  const PaymentMethod(
    id: 'credit_card',
    name: 'Kartu Kredit/Debit',
    icon: Icons.credit_card,
    description: 'Visa, Mastercard, JCB',
    fee: 0,
  ),
  const PaymentMethod(
    id: 'gopay',
    name: 'GoPay',
    icon: Icons.phone_android,
    description: 'Bayar dengan GoPay',
    fee: 0,
  ),
  const PaymentMethod(
    id: 'ovo',
    name: 'OVO',
    icon: Icons.account_balance_wallet,
    description: 'Bayar dengan OVO',
    fee: 0,
  ),
  const PaymentMethod(
    id: 'dana',
    name: 'DANA',
    icon: Icons.phone_android,
    description: 'Bayar dengan DANA',
    fee: 0,
  ),
  const PaymentMethod(
    id: 'bank_transfer',
    name: 'Transfer Bank',
    icon: Icons.account_balance,
    description: 'BCA, Mandiri, BNI, BRI',
    fee: 2500,
  ),
];

// Global state
User? currentUser;
BookingData? currentBooking;
List<BookingData> bookingHistory = [];

// --- MAIN APP ---
class BioskopkuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BIOSKOPKU',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- SCREENS ---

// LoginScreen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeDemoBookedSeats();
  }

  void _initializeDemoBookedSeats() {
    SeatBookingSystem.bookSeats('m1', DateTime.now().toIso8601String().split('T')[0], '12:00', ['A5', 'A6', 'B3', 'B4']);
    SeatBookingSystem.bookSeats('m1', DateTime.now().toIso8601String().split('T')[0], '14:30', ['C7', 'C8', 'D5', 'D6']);
    SeatBookingSystem.bookSeats('m2', DateTime.now().toIso8601String().split('T')[0], '11:00', ['E1', 'E2', 'F9', 'F10']);
    SeatBookingSystem.bookSeats('m3', DateTime.now().toIso8601String().split('T')[0], '10:00', ['G3', 'G4', 'H7', 'H8']);
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 1));

      final username = _usernameController.text;
      final password = _passwordController.text;

      final user = registeredUsers.firstWhere(
            (u) => u.username == username && u.password == password,
        orElse: () => const User(username: '', password: '', name: '', email: '', phone: ''),
      );

      setState(() {
        _isLoading = false;
      });

      if (user.username.isNotEmpty) {
        currentUser = user;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selamat datang, ${user.name}!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MovieListScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username atau password salah!'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showRegisterDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final regUsernameController = TextEditingController();
    final regPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Buat Akun Baru'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama')),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Nomor HP')),
                TextField(controller: regUsernameController, decoration: const InputDecoration(labelText: 'Username')),
                TextField(
                  controller: regPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final newUser = User(
                  username: regUsernameController.text.trim(),
                  password: regPasswordController.text.trim(),
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                  phone: phoneController.text.trim(),
                );

                if (registeredUsers.any((u) => u.username == newUser.username)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Username sudah digunakan'), backgroundColor: Colors.orange),
                  );
                } else {
                  setState(() {
                    registeredUsers.add(newUser);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Akun berhasil dibuat!'), backgroundColor: Colors.green),
                  );
                }
              },
              child: const Text('Daftar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(40)),
                          child: const Icon(Icons.movie_filter, size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 24),
                        const Text('BIOSKOPKU', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
                        const SizedBox(height: 8),
                        const Text(
                          'Masuk untuk memesan tiket film favorit Anda',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          validator: (value) => (value == null || value.isEmpty) ? 'Username tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          validator: (value) => (value == null || value.isEmpty) ? 'Password tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Masuk', style: TextStyle(fontSize: 16)),
                          ),
                        ),

                        // Button Coba Demo
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: _showRegisterDialog,
                            child: const Text('Daftar Akun', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// 2. Movie List Screen
class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  String _searchQuery = '';
  String _selectedGenre = 'Semua';
  List<Movie> _filteredMovies = movies;

  @override
  void initState() {
    super.initState();
    _filterMovies();
  }

  void _filterMovies() {
    setState(() {
      _filteredMovies = movies.where((movie) {
        final matchesSearch = movie.title
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()) ||
            movie.genre.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesGenre =
            _selectedGenre == 'Semua' || movie.genre == _selectedGenre;
        return matchesSearch && matchesGenre;
      }).toList();
    });
  }

  void _logout() {
    currentUser = null;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final genres = ['Semua', ...movies.map((m) => m.genre).toSet().toList()];

    return Scaffold(
      appBar: AppBar(
        title: const Text('BIOSKOPKU'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                _showProfileDialog();
              } else if (value == 'history') {
                _showBookingHistory();
              } else if (value == 'seat_status') {
                _showSeatStatusDialog();
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: const [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profil'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'history',
                child: Row(
                  children: const [
                    Icon(Icons.history),
                    SizedBox(width: 8),
                    Text('Riwayat'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'seat_status',
                child: Row(
                  children: const [
                    Icon(Icons.event_seat),
                    SizedBox(width: 8),
                    Text('Status Kursi'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: const [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Keluar'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari film atau genre...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterMovies();
                  },
                ),
                const SizedBox(height: 12),

                // Genre Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: genres.length,
                    itemBuilder: (context, index) {
                      final genre = genres[index];
                      final isSelected = genre == _selectedGenre;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(genre),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedGenre = genre;
                            });
                            _filterMovies();
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Colors.blue[100],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Movies Grid
          Expanded(
            child: _filteredMovies.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.movie_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Tidak ada film yang ditemukan',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Coba ubah kata kunci pencarian atau filter',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _filteredMovies.length,
              itemBuilder: (context, index) {
                final movie = _filteredMovies[index];
                return MovieCard(
                  movie: movie,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            MovieDetailScreen(movie: movie),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profil Pengguna'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama: ${currentUser?.name}'),
            const SizedBox(height: 8),
            Text('Email: ${currentUser?.email}'),
            const SizedBox(height: 8),
            Text('Telepon: ${currentUser?.phone}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showBookingHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Riwayat Pemesanan'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: bookingHistory.isEmpty
              ? const Center(
            child: Text('Belum ada riwayat pemesanan'),
          )
              : ListView.builder(
            itemCount: bookingHistory.length,
            itemBuilder: (context, index) {
              final booking = bookingHistory[index];
              return Card(
                child: ListTile(
                  title: Text(booking.movie.title),
                  subtitle: Text(
                    '${booking.date} • ${booking.showtime}\n'
                        'ID: ${booking.bookingId}\n'
                        'Kursi: ${booking.selectedSeats.map((s) => s.id).join(', ')}',
                  ),
                  trailing: Text(
                    'Rp ${booking.totalPrice.toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]}.',
                    )}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showSeatStatusDialog() {
    final today = DateTime.now().toIso8601String().split('T')[0];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Status Kursi Hari Ini'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Card(
                child: ExpansionTile(
                  title: Text(movie.title),
                  subtitle: Text(movie.theater),
                  children: movie.showtimes.map((showtime) {
                    final stats = SeatBookingSystem.getSeatStatistics(
                        movie.id,
                        today,
                        showtime
                    );
                    final bookedSeats = SeatBookingSystem.getBookedSeatsForSession(
                        movie.id,
                        today,
                        showtime
                    );

                    return ListTile(
                      title: Text('Jam $showtime'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tersedia: ${stats['available']} kursi'),
                          Text('Terisi: ${stats['booked']} kursi'),
                          if (bookedSeats.isNotEmpty)
                            Text('Kursi terisi: ${bookedSeats.join(', ')}'),
                        ],
                      ),
                      trailing: CircularProgressIndicator(
                        value: stats['booked']! / stats['total']!,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          stats['booked']! > stats['total']! * 0.7
                              ? Colors.red
                              : stats['booked']! > stats['total']! * 0.4
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

// Movie Card Widget
class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Hitung statistik kursi untuk hari ini
    final today = DateTime.now().toIso8601String().split('T')[0];
    int totalBooked = 0;
    int totalSeats = 0;

    for (final showtime in movie.showtimes) {
      final stats = SeatBookingSystem.getSeatStatistics(movie.id, today, showtime);
      totalBooked += stats['booked']!;
      totalSeats += stats['total']!;
    }

    final availabilityPercentage = totalSeats > 0 ? (totalSeats - totalBooked) / totalSeats : 1.0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.movie,
                        size: 48,
                        color: Colors.grey[600],
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          movie.ageRating,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Indikator ketersediaan kursi
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: availabilityPercentage > 0.7
                              ? Colors.green
                              : availabilityPercentage > 0.3
                              ? Colors.orange
                              : Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event_seat,
                              size: 10,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${(availabilityPercentage * 100).round()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Movie Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          movie.duration,
                          style: const TextStyle(fontSize: 10),
                        ),
                        const Spacer(),
                        const Icon(Icons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          movie.rating.toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        movie.genre,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rp ${movie.price.toString().replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]}.',
                          )}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${movie.showtimes.length} jadwal',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 3. Movie Detail Screen
class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  String? _selectedShowtime;
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Set default date to today
    _selectedDate = DateTime.now().toIso8601String().split('T')[0];
  }

  List<Map<String, String>> _getNextDays() {
    final days = <Map<String, String>>[];
    for (int i = 0; i < 7; i++) {
      final date = DateTime.now().add(Duration(days: i));
      days.add({
        'date': date.toIso8601String().split('T')[0],
        'display': _formatDate(date),
      });
    }
    return days;
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${weekdays[date.weekday - 1]}\n${date.day} ${months[date.month - 1]}';
  }

  void _proceedToSeatSelection() {
    if (_selectedShowtime == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tanggal dan jam tayang terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    currentBooking = BookingData(
      movie: widget.movie,
      showtime: _selectedShowtime!,
      date: _selectedDate!,
      selectedSeats: [],
      totalPrice: 0,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SeatSelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableDates = _getNextDays();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Film'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Header
            Container(
              height: 300,
              child: Row(
                children: [
                  // Poster
                  Container(
                    width: 200,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.movie,
                            size: 64,
                            color: Colors.grey[600],
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.movie.ageRating,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Movie Info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.movie.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.movie.genre,
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16),
                              const SizedBox(width: 4),
                              Text(widget.movie.duration),
                              const SizedBox(width: 16),
                              const Icon(Icons.star, size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text('${widget.movie.rating}/10'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16),
                              const SizedBox(width: 4),
                              Text(widget.movie.theater),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            'Rp ${widget.movie.price.toString().replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (Match m) => '${m[1]}.',
                            )}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Synopsis
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sinopsis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.movie.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),

            // Movie Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Film',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Sutradara', widget.movie.director),
                  const SizedBox(height: 8),
                  _buildInfoRow('Pemeran', widget.movie.cast.join(', ')),
                ],
              ),
            ),

            // Date Selection
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Tanggal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: availableDates.length,
                      itemBuilder: (context, index) {
                        final day = availableDates[index];
                        final isSelected = _selectedDate == day['date'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedDate = day['date'];
                                _selectedShowtime = null; // Reset showtime selection
                              });
                            },
                            child: Container(
                              width: 60,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue : Colors.white,
                                border: Border.all(
                                  color: isSelected ? Colors.blue : Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  day['display']!,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Showtime Selection
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Jam Tayang',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_selectedDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Tanggal: ${_formatSelectedDate()}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.movie.showtimes.map((time) {
                      final isSelected = _selectedShowtime == time;

                      // Hitung statistik kursi untuk jam tayang ini
                      final stats = _selectedDate != null
                          ? SeatBookingSystem.getSeatStatistics(
                          widget.movie.id,
                          _selectedDate!,
                          time
                      )
                          : {'available': 80, 'booked': 0, 'total': 80};

                      final availableSeats = stats['available']!;
                      final isFullyBooked = availableSeats == 0;

                      return InkWell(
                        onTap: isFullyBooked ? null : () {
                          setState(() {
                            _selectedShowtime = time;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isFullyBooked
                                ? Colors.grey[300]
                                : isSelected
                                ? Colors.blue
                                : Colors.white,
                            border: Border.all(
                              color: isFullyBooked
                                  ? Colors.grey
                                  : isSelected
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                time,
                                style: TextStyle(
                                  color: isFullyBooked
                                      ? Colors.grey[600]
                                      : isSelected
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isFullyBooked
                                    ? 'Penuh'
                                    : '$availableSeats kursi',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isFullyBooked
                                      ? Colors.grey[600]
                                      : isSelected
                                      ? Colors.white70
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Book Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _proceedToSeatSelection,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_seat),
                      SizedBox(width: 8),
                      Text(
                        'Pilih Kursi',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  String _formatSelectedDate() {
    if (_selectedDate == null) return '';
    final date = DateTime.parse(_selectedDate!);
    final weekdays = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// 4. Seat Selection Screen
class SeatSelectionScreen extends StatefulWidget {
  const SeatSelectionScreen({super.key});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  List<Seat> seats = [];

  @override
  void initState() {
    super.initState();
    _initializeSeats();
  }

  void _initializeSeats() {
    final rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    final seatsPerRow = 10;

    // Dapatkan kursi yang sudah dipesan untuk sesi ini
    final bookedSeatIds = SeatBookingSystem.getBookedSeatsForSession(
      currentBooking!.movie.id,
      currentBooking!.date,
      currentBooking!.showtime,
    );

    for (final row in rows) {
      for (int i = 1; i <= seatsPerRow; i++) {
        final seatId = '$row$i';
        var status = SeatStatus.available;
        var price = currentBooking!.movie.price;
        var type = 'Regular';

        // Premium seats (front rows) cost more
        if (['A', 'B', 'C'].contains(row)) {
          price += 10000;
          type = 'Premium';
        }

        // Set status berdasarkan kursi yang sudah dipesan
        if (bookedSeatIds.contains(seatId)) {
          status = SeatStatus.occupied;
        }

        seats.add(Seat(
          id: seatId,
          row: row,
          number: i,
          status: status,
          price: price,
          type: type,
        ));
      }
    }
  }

  void _toggleSeat(String seatId) {
    setState(() {
      final seat = seats.firstWhere((s) => s.id == seatId);
      if (seat.status == SeatStatus.available) {
        seat.status = SeatStatus.selected;
      } else if (seat.status == SeatStatus.selected) {
        seat.status = SeatStatus.available;
      }
    });
  }

  List<Seat> get _selectedSeats =>
      seats.where((seat) => seat.status == SeatStatus.selected).toList();

  int get _totalPrice =>
      _selectedSeats.fold(0, (sum, seat) => sum + seat.price);

  void _proceedToPayment() {
    if (_selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih minimal satu kursi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    currentBooking = currentBooking!.copyWith(
      selectedSeats: _selectedSeats,
      totalPrice: _totalPrice,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PaymentScreen(),
      ),
    );
  }

  Color _getSeatColor(SeatStatus status) {
    switch (status) {
      case SeatStatus.available:
        return Colors.grey[300]!;
      case SeatStatus.selected:
        return Colors.blue;
      case SeatStatus.occupied:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hitung statistik kursi
    final availableSeats = seats.where((s) => s.status == SeatStatus.available).length;
    final occupiedSeats = seats.where((s) => s.status == SeatStatus.occupied).length;
    final selectedSeats = seats.where((s) => s.status == SeatStatus.selected).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Kursi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showSeatInfo();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Movie Info
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentBooking!.movie.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_formatDate()} • ${currentBooking!.showtime} • ${currentBooking!.movie.theater}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        currentBooking!.movie.genre,
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Statistik kursi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Tersedia', availableSeats, Colors.green),
                    _buildStatItem('Terisi', occupiedSeats, Colors.red),
                    _buildStatItem('Dipilih', selectedSeats, Colors.blue),
                  ],
                ),
              ],
            ),
          ),

          // Screen
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.tv, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  'LAYAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Seats
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
                    .map((row) => _buildSeatRow(row))
                    .toList(),
              ),
            ),
          ),

          // Legend
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(Colors.grey[300]!, 'Tersedia'),
                _buildLegendItem(Colors.blue, 'Terpilih'),
                _buildLegendItem(Colors.red, 'Terisi'),
              ],
            ),
          ),

          // Summary and Continue Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              children: [
                if (_selectedSeats.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kursi: ${_selectedSeats.map((s) => s.id).join(', ')}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Rp ${_totalPrice.toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]}.',
                        )}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _selectedSeats.isEmpty ? null : _proceedToPayment,
                    child: Text(
                      _selectedSeats.isEmpty
                          ? 'Pilih Kursi'
                          : 'Lanjut ke Pembayaran (${_selectedSeats.length} kursi)',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSeatRow(String row) {
    final rowSeats = seats.where((seat) => seat.row == row).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            child: Text(
              row,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          ...rowSeats.map((seat) => _buildSeatWidget(seat)),
          const SizedBox(width: 8),
          SizedBox(
            width: 20,
            child: Text(
              row,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatWidget(Seat seat) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: seat.status == SeatStatus.occupied
            ? null
            : () => _toggleSeat(seat.id),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _getSeatColor(seat.status),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: seat.status == SeatStatus.selected
                  ? Colors.blue[700]!
                  : Colors.grey,
            ),
          ),
          child: Center(
            child: Text(
              seat.number.toString(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: seat.status == SeatStatus.selected ||
                    seat.status == SeatStatus.occupied
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  void _showSeatInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informasi Kursi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Jenis Kursi:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('• Baris A-C: Premium (+Rp 10.000)'),
            Text('• Baris D-H: Regular'),
            const SizedBox(height: 12),
            const Text(
              'Status Kursi:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Tersedia untuk dipilih'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Kursi yang Anda pilih'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Sudah dipesan orang lain'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  String _formatDate() {
    final date = DateTime.parse(currentBooking!.date);
    final weekdays = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }
}

// 5. Payment Screen
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod? _selectedPaymentMethod;
  bool _isProcessing = false;
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _phoneController = TextEditingController();

  int get _totalWithFee =>
      currentBooking!.totalPrice + (_selectedPaymentMethod?.fee ?? 0);

  void _processPayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih metode pembayaran'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate form based on payment method
    if (_selectedPaymentMethod!.id == 'credit_card') {
      if (!_formKey.currentState!.validate()) {
        return;
      }
    } else if (['gopay', 'ovo', 'dana'].contains(_selectedPaymentMethod!.id)) {
      if (_phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan masukkan nomor telepon'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 3));

    // Generate booking ID
    final bookingId = 'BKG${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    // Book the selected seats in the system
    final seatIds = currentBooking!.selectedSeats.map((seat) => seat.id).toList();
    SeatBookingSystem.bookSeats(
      currentBooking!.movie.id,
      currentBooking!.date,
      currentBooking!.showtime,
      seatIds,
    );

    // Create final booking data
    final finalBooking = currentBooking!.copyWith(
      paymentMethod: _selectedPaymentMethod,
      bookingId: bookingId,
      paymentDate: DateTime.now(),
      totalPrice: _totalWithFee,
    );

    // Add to booking history
    bookingHistory.add(finalBooking);

    setState(() {
      _isProcessing = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kursi ${seatIds.join(', ')} berhasil dipesan!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate to success screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => BookingSuccessScreen(booking: finalBooking),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ringkasan Pesanan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currentBooking!.movie.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_formatDate()} • ${currentBooking!.showtime} • ${currentBooking!.movie.theater}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Kursi: ${currentBooking!.selectedSeats.map((s) => s.id).join(', ')}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tiket (${currentBooking!.selectedSeats.length}x)'),
                              Text('Rp ${currentBooking!.totalPrice.toString().replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]}.',
                              )}'),
                            ],
                          ),
                          if (_selectedPaymentMethod?.fee != null && _selectedPaymentMethod!.fee > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Biaya Admin'),
                                Text('Rp ${_selectedPaymentMethod!.fee.toString().replaceAllMapped(
                                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                      (Match m) => '${m[1]}.',
                                )}'),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Rp ${_totalWithFee.toString().replaceAllMapped(
                                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                      (Match m) => '${m[1]}.',
                                )}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Methods
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pilih Metode Pembayaran',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...paymentMethods.map((method) => _buildPaymentMethodTile(method)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Form
                  if (_selectedPaymentMethod != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Detail Pembayaran',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ..._buildPaymentForm(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),

          // Payment Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    const Text(
                      'Selesaikan dalam 15 menit',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processPayment,
                    child: _isProcessing
                        ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Memproses...'),
                      ],
                    )
                        : Text(
                      'Bayar Rp ${_totalWithFee.toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]}.',
                      )}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(PaymentMethod method) {
    final isSelected = _selectedPaymentMethod?.id == method.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = method;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? Colors.blue[50] : Colors.white,
          ),
          child: Row(
            children: [
              Radio<PaymentMethod>(
                value: method,
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
              ),
              Icon(method.icon, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      method.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (method.fee > 0)
                Text(
                  '+Rp ${method.fee.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]}.',
                  )}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPaymentForm() {
    if (_selectedPaymentMethod == null) return [];

    switch (_selectedPaymentMethod!.id) {
      case 'credit_card':
        return [
          TextFormField(
            controller: _cardNumberController,
            decoration: const InputDecoration(
              labelText: 'Nomor Kartu',
              hintText: '1234 5678 9012 3456',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nomor kartu tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  decoration: const InputDecoration(
                    labelText: 'MM/YY',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tanggal kadaluarsa tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'CVV tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cardNameController,
            decoration: const InputDecoration(
              labelText: 'Nama Pemegang Kartu',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama pemegang kartu tidak boleh kosong';
              }
              return null;
            },
          ),
        ];

      case 'gopay':
      case 'ovo':
      case 'dana':
        return [
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Nomor Telepon',
              hintText: '08xxxxxxxxxx',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Anda akan diarahkan ke aplikasi ${_selectedPaymentMethod!.name} untuk menyelesaikan pembayaran.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[700],
              ),
            ),
          ),
        ];

      case 'bank_transfer':
        return [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Setelah konfirmasi, Anda akan mendapatkan nomor rekening untuk transfer. Pembayaran harus diselesaikan dalam 24 jam.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[700],
              ),
            ),
          ),
        ];

      default:
        return [];
    }
  }

  String _formatDate() {
    final date = DateTime.parse(currentBooking!.date);
    final weekdays = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}

// 6. Booking Success Screen
class BookingSuccessScreen extends StatelessWidget {
  final BookingData booking;

  const BookingSuccessScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50),
              Color(0xFF2E7D32),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Success Header
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          size: 60,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Pembayaran Berhasil!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tiket Anda telah berhasil dipesan',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Kursi ${booking.selectedSeats.map((s) => s.id).join(', ')} telah dikunci untuk Anda',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Ticket
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ticket Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.blue, Colors.purple],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      booking.movie.title,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      booking.movie.genre,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  booking.movie.ageRating,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Booking Details
                        _buildDetailRow('ID Pemesanan', booking.bookingId!),
                        _buildDetailRow('Tanggal', _formatDate()),
                        _buildDetailRow('Jam Tayang', booking.showtime),
                        _buildDetailRow('Studio', booking.movie.theater),
                        _buildDetailRow(
                          'Kursi',
                          booking.selectedSeats.map((s) => s.id).join(', '),
                        ),
                        _buildDetailRow('Metode Pembayaran', booking.paymentMethod!.name),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Pembayaran',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Rp ${booking.totalPrice.toString().replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]}.',
                              )}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // QR Code Placeholder
                        Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.qr_code,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'QR Code',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tunjukkan QR code ini saat masuk bioskop',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        // Important Notes
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.yellow[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.yellow[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Informasi Penting:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellow[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '• Harap datang 30 menit sebelum jam tayang\n'
                                    '• Bawa identitas diri yang valid\n'
                                    '• Tiket tidak dapat dikembalikan atau ditukar\n'
                                    '• Simpan tiket ini hingga selesai menonton\n'
                                    '• Kursi Anda telah dikunci dan tidak dapat dipilih orang lain',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.yellow[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Fitur download akan segera tersedia!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.download),
                            label: const Text('Unduh'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Fitur share akan segera tersedia!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.share),
                            label: const Text('Bagikan'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const MovieListScreen(),
                            ),
                                (Route<dynamic> route) => false,
                          );
                        },
                        icon: const Icon(Icons.home),
                        label: const Text('Kembali ke Beranda'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate() {
    final date = DateTime.parse(booking.date);
    final weekdays = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
