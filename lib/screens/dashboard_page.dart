import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Selamat Datang,", style: TextStyle(color: Colors.grey[400])),
                      Text(user?.email?.split('@')[0] ?? "Pelajar",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent)
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Progres Card (Modern Glass)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.blueAccent.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: const Column(
                  children: [
                    Text("Total Belajar Hari Ini", style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 10),
                    Text("04:30", style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text("Jam : Menit", style: TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 35),
              const Text("Aktivitas Terakhir", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              // List Real-time dari Firestore
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('study_logs')
                    .where('userId', isEqualTo: user?.uid)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("Belum ada data belajar."));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      return _buildStudyTile(doc['activity'], doc['duration']);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        label: const Text("Tambah Log", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  Widget _buildStudyTile(String title, String duration) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.bookmark_outline, color: Colors.blueAccent),
              const SizedBox(width: 15),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
          Text("$duration Jam", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final activityController = TextEditingController();
    final durationController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 25, right: 25, top: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Apa yang dipelajari?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: activityController,
              decoration: InputDecoration(hintText: "Nama Aktivitas", filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: "Durasi (Jam)", filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: () {
                  FirebaseFirestore.instance.collection('study_logs').add({
                    'activity': activityController.text,
                    'duration': durationController.text,
                    'userId': FirebaseAuth.instance.currentUser?.uid,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                },
                child: const Text("Simpan Progres", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}