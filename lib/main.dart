import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const StudyApp());
}

class StudyApp extends StatelessWidget {
  const StudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0E14), // Hitam Deep
        textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Profil (Mirip UI kamu)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Halo, User!", style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                      const Text("Ayo Belajar Hari Ini", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const CircleAvatar(radius: 25, backgroundColor: Colors.blueAccent),
                ],
              ),
              const SizedBox(height: 30),

              // Card Utama (Glassmorphism Effect)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blueAccent, Colors.blue.shade900]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 20, spreadRadius: 2)],
                ),
                child: Column(
                  children: [
                    const Text("Target Mingguan", style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 10),
                    const Text("18 / 24 Jam", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: 0.75,
                      backgroundColor: Colors.white24,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      minHeight: 8,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              const Text("Aktivitas Terbaru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              // List Belajar (Contoh Item)
              Expanded(
                child: ListView(
                  children: const [
                    StudyItemTile(title: "Belajar Flutter UI", duration: "2 Jam", icon: Icons.code),
                    StudyItemTile(title: "Matematika Diskrit", duration: "1.5 Jam", icon: Icons.calculate),
                    StudyItemTile(title: "Membaca Buku Design", duration: "45 Menit", icon: Icons.menu_book),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Tombol Tambah (Powerful Minimalist)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text("Tambah Log"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}

class StudyItemTile extends StatelessWidget {
  final String title;
  final String duration;
  final IconData icon;

  const StudyItemTile({super.key, required this.title, required this.duration, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        // Memberi sedikit border transparan agar terlihat seperti kaca
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect( // Agar efek blur tidak keluar dari border
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          // Warna background semi-transparan
          color: Colors.white.withOpacity(0.05),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.blueAccent, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(duration, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}}