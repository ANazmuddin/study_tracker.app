import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.email?.split('@')[0] ?? "Ahnan";

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // --- FOTO PROFIL & NAMA ---
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blueAccent, width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFF1E293B),
                    child: Icon(Icons.person, size: 50, color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                displayName.toUpperCase(),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              // Status/Bio yang bisa disesuaikan
              Text(
                "Freelance Full Stack Web Developer",
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(height: 30),

              // --- KARTU TOTAL STATISTIK ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    const Text("Akumulasi Belajar", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('study_logs')
                          .where('userId', isEqualTo: user?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const CircularProgressIndicator();

                        double totalHours = 0;
                        for (var doc in snapshot.data!.docs) {
                          totalHours += double.tryParse(doc['duration'].toString()) ?? 0.0;
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem("Total Sesi", "${snapshot.data!.docs.length}"),
                            Container(width: 1, height: 40, color: Colors.grey[800]),
                            _buildStatItem("Total Jam", totalHours.toStringAsFixed(1)),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- MENU PENGATURAN ---
              _buildMenuTile(Icons.settings_outlined, "Pengaturan Akun"),
              _buildMenuTile(Icons.color_lens_outlined, "Tema Aplikasi"),
              _buildMenuTile(Icons.help_outline_rounded, "Bantuan & FAQ"),

              const SizedBox(height: 20),

              // --- TOMBOL LOGOUT ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/');
                    }
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text("Keluar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      ],
    );
  }

  Widget _buildMenuTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222D),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: () {}, // Nanti bisa diisi fungsi navigasi
      ),
    );
  }
}