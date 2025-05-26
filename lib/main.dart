import 'package:flutter/material.dart';

// --- MODELS ---
enum SeatStatus { available, selected, occupied }

class Movie {
  final String id;
  final String title;
  final String posterUrl;
  final String description;
  final String genre;
  final String duration;
  final List<String> showtimes;

  const Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.description,
    required this.genre,
    required this.duration,
    required this.showtimes,
  });
}

class Seat {
  final String id;
  final String row;
  final int number;
  SeatStatus status; // Now mutable outside of constructor for updates

  Seat({
    required this.id,
    required this.row,
    required this.number,
    this.status = SeatStatus.available,
  });

  // copyWith is still useful for creating new instances with changed properties
  Seat copyWith({SeatStatus? status}) {
    return Seat(
      id: id,
      row: row,
      number: number,
      status: status ?? this.status,
    );
  }
}

class User {
  final String username;
  final String password; // In a real app, never store plain passwords!

  const User({required this.username, required this.password});
}

// --- GLOBAL DATA (for demonstration purposes) ---
List<User> registeredUsers = [
  const User(username: 'user1', password: 'password1'),
  const User(username: 'admin', password: 'adminpassword'),
];

// This list will now hold the global state of all seats across the app.
// We initialize it once and update it after bookings.
List<Seat> globalSeats = [];

// Function to initialize global seats
void _initializeGlobalSeats() {
  globalSeats.clear();
  final int rows = 8;
  final int cols = 10;
  final List<String> seatRows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

  for (int r = 0; r < rows; r++) {
    for (int c = 1; c <= cols; c++) {
      final String seatId = '${seatRows[r]}$c';
      SeatStatus status = SeatStatus.available;
      // Simulate some initially occupied seats
      if ((r == 2 && c == 5) || (r == 3 && c == 3) || (r == 3 && c == 4) || (r == 5 && c == 8)) {
        status = SeatStatus.occupied;
      }
      globalSeats.add(Seat(id: seatId, row: seatRows[r], number: c, status: status));
    }
  }
}

// --- MAIN APPLICATION ---
void main() {
  // Initialize global seats when the app starts
  _initializeGlobalSeats();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bioskopku Satu File',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        chipTheme: ChipThemeData(
          selectedColor: Colors.blueGrey[700],
          labelStyle: const TextStyle(color: Colors.black),
          secondaryLabelStyle: const TextStyle(color: Colors.white),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// --- SCREENS ---

// Screen 0: LoginScreen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _login() {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text;
      final password = _passwordController.text;

      bool isAuthenticated = false;
      for (var user in registeredUsers) {
        if (user.username == username && user.password == password) {
          isAuthenticated = true;
          break;
        }
      }

      if (isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selamat datang, $username!')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MovieListScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username atau password salah!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bioskopku - Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.movie_filter,
                  size: 100,
                  color: Colors.blueGrey,
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                //button login
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const UserListScreen()),
                    );
                  },
                  child: const Text('Lihat Daftar Pengguna'),
                ),
              ],
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

// Screen 1: MovieListScreen
class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  final List<Movie> movies = const [
    Movie(
      id: 'm1',
      title: 'Avengers: Endgame',
      posterUrl: 'https://cdn.marvel.com/content/1x/avengersendgame_lob_crd_05.jpg',
      description: 'Adrift in space with no food or water, Tony Stark sends a message to Pepper Potts as his oxygen supply starts to dwindle. Meanwhile, the remaining Avengers -- Thor, Black Widow, Captain America and Bruce Banner -- must figure out a way to bring back their vanquished allies for an epic showdown with Thanos -- the evil demigod who decimated the planet and the universe.',
      genre: 'Action, Sci-Fi',
      duration: '3h 1min',
      showtimes: ['12:00', '14:30', '17:00', '19:30', '22:00'],
    ),
    Movie(
      id: 'm2',
      title: 'Spider-Man: No Way Home',
      posterUrl: 'https://m.media-amazon.com/images/M/MV5BZWMyYzMyYjktMTg1ZS00MTlkLTljYzItYmY4OTNkNjU2MGE1XkEyXkFqcGdeQXVyMTE0MzQwMDgy._V1_FMjpg_UX1000_.jpg',
      description: 'With Spider-Man\'s identity now revealed, Peter asks Doctor Strange for help. When a spell goes wrong, dangerous foes from other worlds start to appear, forcing Peter to discover what it truly means to be Spider-Man.',
      genre: 'Action, Adventure',
      duration: '2h 28min',
      showtimes: ['11:00', '13:30', '16:00', '18:30', '21:00'],
    ),
    Movie(
      id: 'm3',
      title: 'Dune: Part Two',
      posterUrl: 'https://m.media-amazon.com/images/M/MV5BMzY3NzZlM2EtNWY3MS00NmQ1LWFmNDctZDBlNWE4MzA0NWI0XkEyXkFqcGdeQXVyMTkxNjUyNQ@@._V1_.jpg',
      description: 'Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators who destroyed his family.',
      genre: 'Sci-Fi, Adventure',
      duration: '2h 46min',
      showtimes: ['10:00', '13:00', '16:00', '19:00'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bioskopku - Film Tayang'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const UserListScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: movies.length,
        itemBuilder: (ctx, index) {
          final movie = movies[index];
          return Card(
            elevation: 6,
            margin: const EdgeInsets.only(bottom: 20.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MovieDetailScreen(movie: movie),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        movie.posterUrl,
                        width: 120,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 180,
                            color: Colors.grey[300],
                            child: const Icon(Icons.movie, size: 60, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 18.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            '${movie.genre} | ${movie.duration}',
                            style: TextStyle(color: Colors.grey[700], fontSize: 14),
                          ),
                          const SizedBox(height: 8.0),
                          const Text(
                            'Jam Tayang:',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4.0),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: movie.showtimes
                                .map((time) => Chip(
                              label: Text(time),
                              backgroundColor: Colors.blueGrey[100],
                              labelStyle: const TextStyle(fontSize: 12),
                            ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Screen 2: MovieDetailScreen
class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  String? _selectedShowtime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(
                  widget.movie.posterUrl,
                  height: 350,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 350,
                      width: 250,
                      color: Colors.grey[300],
                      child: const Icon(Icons.movie, size: 100, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            Text(
              widget.movie.title,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            Text(
              '${widget.movie.genre} | ${widget.movie.duration}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Sinopsis:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            Text(
              widget.movie.description,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 30.0),
            const Text(
              'Pilih Jam Tayang:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15.0),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: widget.movie.showtimes.map((time) {
                return ChoiceChip(
                  label: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Text(time),
                  ),
                  selected: _selectedShowtime == time,
                  selectedColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(
                    color: _selectedShowtime == time ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedShowtime = selected ? time : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 40.0),
            Center(
              child: ElevatedButton(
                onPressed: _selectedShowtime == null
                    ? null
                    : () async {
                  // Pass globalSeats to SeatSelectionScreen
                  final updatedSeats = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SeatSelectionScreen(
                        movie: widget.movie,
                        showtime: _selectedShowtime!,
                        initialSeats: globalSeats, // Pass current global seats
                      ),
                    ),
                  );

                  // If updatedSeats are returned (meaning a booking was made),
                  // update the globalSeats.
                  if (updatedSeats != null && updatedSeats is List<Seat>) {
                    setState(() {
                      // This part is crucial: we update the global state
                      // that the SeatSelectionScreen and future instances
                      // of it will use.
                      globalSeats = updatedSeats;
                      _selectedShowtime = null; // Reset selected showtime after booking
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Pilih Kursi',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}

// Screen 3: SeatSelectionScreen
class SeatSelectionScreen extends StatefulWidget {
  final Movie movie;
  final String showtime;
  final List<Seat> initialSeats; // New parameter to receive global seats

  const SeatSelectionScreen({
    super.key,
    required this.movie,
    required this.showtime,
    required this.initialSeats, // Require initial seats
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  // Seats for this screen will be a copy of the initialSeats to allow local modification
  List<Seat> seats = [];

  @override
  void initState() {
    super.initState();
    // Deep copy the initial seats to allow local state changes
    seats = widget.initialSeats.map((seat) => seat.copyWith()).toList();
  }

  void _toggleSeatStatus(Seat seat) {
    setState(() {
      if (seat.status == SeatStatus.available) {
        seat.status = SeatStatus.selected;
      } else if (seat.status == SeatStatus.selected) {
        seat.status = SeatStatus.available;
      }
    });
  }

  List<Seat> get _selectedSeats =>
      seats.where((seat) => seat.status == SeatStatus.selected).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Kursi - ${widget.movie.title}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Layar Bioskop',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 15, bottom: 20),
                  height: 25,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'LAYAR',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 10, // cols is now hardcoded for GridView.builder
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 6.0,
                  mainAxisSpacing: 6.0,
                ),
                itemCount: seats.length,
                itemBuilder: (ctx, index) {
                  final seat = seats[index];
                  return _SeatWidgetInternal(
                    seat: seat,
                    onTap: () => _toggleSeatStatus(seat),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSeatLegend(SeatStatus.available, 'Tersedia'),
                    _buildSeatLegend(SeatStatus.selected, 'Terpilih'),
                    _buildSeatLegend(SeatStatus.occupied, 'Terisi'),
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _selectedSeats.isEmpty
                      ? null
                      : () async {
                    // Pass selected seats and movie details to BookingSummaryScreen
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BookingSummaryScreen(
                          movie: widget.movie,
                          showtime: widget.showtime,
                          selectedSeats: _selectedSeats,
                          allSeats: seats, // Pass all seats to update in summary
                        ),
                      ),
                    );

                    // If result is true, it means booking was confirmed
                    if (result == true) {
                      // Pop this screen and return the updated globalSeats to MovieDetailScreen
                      Navigator.of(context).pop(seats);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Pesan ${_selectedSeats.length} Kursi',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatLegend(SeatStatus status, String label) {
    Color color;
    switch (status) {
      case SeatStatus.available:
        color = Colors.grey[300]!;
        break;
      case SeatStatus.selected:
        color = Colors.blue;
        break;
      case SeatStatus.occupied:
        color = Colors.red;
        break;
    }
    return Row(
      children: [
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 15)),
      ],
    );
  }
}

// Screen 4: BookingSummaryScreen
class BookingSummaryScreen extends StatelessWidget {
  final Movie movie;
  final String showtime;
  final List<Seat> selectedSeats;
  final List<Seat> allSeats; // New: Receive all seats to update their status

  const BookingSummaryScreen({
    super.key,
    required this.movie,
    required this.showtime,
    required this.selectedSeats,
    required this.allSeats, // Require all seats
  });

  String _getSeatsString() {
    return selectedSeats.map((s) => '${s.row}${s.number}').join(', ');
  }

  double _calculateTotalPrice() {
    const double pricePerSeat = 35000.0; // Assume price per seat in IDR
    return selectedSeats.length * pricePerSeat;
  }

  // Function to update the status of selected seats to occupied
  void _markSeatsAsOccupied() {
    for (var selectedSeat in selectedSeats) {
      // Find the corresponding seat in the full list and update its status
      final seatToUpdate = allSeats.firstWhere((s) => s.id == selectedSeat.id);
      seatToUpdate.status = SeatStatus.occupied;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan Pemesanan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Film: ${movie.title}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            const SizedBox(height: 15),
            Text(
              'Jam Tayang: $showtime',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 15),
            Text(
              'Kursi Dipilih: ${_getSeatsString()}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 15),
            Text(
              'Jumlah Tiket: ${selectedSeats.length}',
              style: const TextStyle(fontSize: 18),
            ),
            const Divider(height: 40, thickness: 1.5, color: Colors.grey),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Pembayaran:',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rp ${_calculateTotalPrice().toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _showConfirmationDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Konfirmasi Pembayaran',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pemesanan Berhasil! 🎉'),
        content: Text(
            'Tiket Anda untuk film ${movie.title} pada jam $showtime dengan kursi ${_getSeatsString()} telah berhasil dipesan.\n\nTerima kasih telah menggunakan Bioskopku!'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              // Mark seats as occupied globally before navigating back
              _markSeatsAsOccupied();
              Navigator.of(ctx).pop(); // Pop the dialog
              // Pop the SeatSelectionScreen and indicate successful booking
              Navigator.of(context).pop(true);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Screen 5: UserListScreen
class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengguna'),
      ),
      body: registeredUsers.isEmpty
          ? const Center(
        child: Text(
          'Belum ada pengguna terdaftar.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: registeredUsers.length,
        itemBuilder: (ctx, index) {
          final user = registeredUsers[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 12.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.blueGrey),
              title: Text(
                user.username,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              subtitle: Text('Password: ${user.password} (Demo)'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Detail pengguna: ${user.username}')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// --- WIDGETS ---

// Widget Kursi Individual (internal)
class _SeatWidgetInternal extends StatelessWidget {
  final Seat seat;
  final VoidCallback onTap;

  const _SeatWidgetInternal({
    required this.seat,
    required this.onTap,
  });

  Color _getSeatColor() {
    switch (seat.status) {
      case SeatStatus.available:
        return Colors.grey[300]!;
      case SeatStatus.selected:
        return Colors.blue[600]!;
      case SeatStatus.occupied:
        return Colors.red[400]!;
    }
  }

  Color _getTextColor() {
    return seat.status == SeatStatus.selected ? Colors.white : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: seat.status == SeatStatus.occupied ? null : onTap,
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: _getSeatColor(),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[500]!),
          boxShadow: seat.status == SeatStatus.selected
              ? [
            BoxShadow(
              color: Colors.blue.withOpacity(0.5),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ]
              : null,
        ),
        child: Center(
          child: Text(
            '${seat.row}${seat.number}',
            style: TextStyle(
              color: _getTextColor(),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
