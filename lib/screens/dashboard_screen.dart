import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),

      /// 🔹 APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A0572),
        title: const Text("My Habits"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),

      /// 🔹 ADD BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6A0572),
        child: const Icon(Icons.add),
        onPressed: () => _showAddHabitSheet(context),
      ),

      /// 🔹 STREAM
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("habits")
            .where("userId", isEqualTo: user?.email)
            .orderBy("createdAt")
            .snapshots(),

        builder: (context, snapshot) {
          /// 🟡 LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          /// 🔴 ERROR UI (IMPORTANT)
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "⚠️ Firestore index missing.\n\n"
                      "Open browser console → click the index link → create index.\n\n"
                      "Then reload app.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          final habits = snapshot.data!.docs;

          /// 🟢 EMPTY STATE
          if (habits.isEmpty) {
            return _emptyState(context, user);
          }

          final completed =
              habits.where((h) => h["completed"] == true).length;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(user),
                  const SizedBox(height: 20),
                  _progressCard(completed, habits.length),
                  const SizedBox(height: 25),

                  const Text("Today's Habits",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  ...habits.map((habit) => _habitTile(habit)).toList(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 🔹 EMPTY UI
  Widget _emptyState(BuildContext context, User? user) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _header(user),
            const SizedBox(height: 30),
            const Icon(Icons.track_changes, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text("No habits yet",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Tap + to create your first habit 🚀"),
          ],
        ),
      ),
    );
  }

  /// 🔹 HEADER
  Widget _header(User? user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF6A0572),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Welcome 👋",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(user?.email ?? "")
            ],
          )
        ],
      ),
    );
  }

  /// 🔹 PROGRESS CARD
  Widget _progressCard(int completed, int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A0572), Color(0xFFC2185B)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Today's Progress",
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            "$completed / $total Habits",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: total == 0 ? 0 : completed / total,
            backgroundColor: Colors.white24,
          )
        ],
      ),
    );
  }

  /// 🔹 HABIT TILE
  Widget _habitTile(QueryDocumentSnapshot habit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF6A0572),
            child: Icon(Icons.check, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(habit["title"],
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          IconButton(
            icon: Icon(
              habit["completed"]
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: habit["completed"] ? Colors.green : Colors.grey,
            ),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection("habits")
                  .doc(habit.id)
                  .update({"completed": !habit["completed"]});
            },
          )
        ],
      ),
    );
  }

  /// 🔹 ADD HABIT
  void _showAddHabitSheet(BuildContext context) {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Add Habit",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Habit name"),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Target days"),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A0572)),
                onPressed: () {
                  FirebaseFirestore.instance.collection("habits").add({
                    "title": titleController.text,
                    "completed": false,
                    "targetDays":
                    int.tryParse(targetController.text) ?? 21,
                    "streak": 0,
                    "userId": user?.email,
                    "createdAt": Timestamp.now(),
                  });

                  Navigator.pop(context);
                },
                child: const Text("Save"),
              )
            ],
          ),
        );
      },
    );
  }
}