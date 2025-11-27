import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/university_viewmodel.dart';
import '../utils/country_codes.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController countryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(universityViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "University Finder",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------------- PROFILE ----------------
            const Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage:
                      NetworkImage("https://i.pravatar.cc/150?img=10"),
                ),
                SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, Chris 👋",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text("Search universities worldwide"),
                  ],
                )
              ],
            ),

            const SizedBox(height: 22),

            // ---------------- SEARCH FIELD ----------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: countryController,
                decoration: const InputDecoration(
                  hintText: "Enter Country Name", // disappears while typing
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ---------------- SEARCH BUTTON ----------------
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  final country = countryController.text.trim();
                  final notifier =
                      ref.read(universityViewModelProvider.notifier);

                  notifier.searchUniversity(country).then((_) {
                    final error = ref.read(universityViewModelProvider).error;

                    if (error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4C8CFF),
                        Color(0xFF2962FF),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Search",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- LOADING ----------------
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: CircularProgressIndicator(),
              ),

            // ---------------- ERROR BOX ----------------
            if (state.error != null && !state.isLoading)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        state.error!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // -------- FIX: Hide retry for empty country name --------
                    if (state.error !=
                        "Invalid country: Please enter a country name.")
                      TextButton(
                        onPressed: () {
                          final country = countryController.text.trim();
                          ref
                              .read(universityViewModelProvider.notifier)
                              .searchUniversity(country);
                        },
                        child: const Text("Retry"),
                      ),
                  ],
                ),
              ),

            // ---------------- RESULTS ----------------
            if (!state.isLoading && state.universities.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 10),
                  itemCount: state.universities.length,
                  itemBuilder: (context, index) {
                    final uni = state.universities[index];

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CountryFlag.fromCountryCode(
                            getCountryCode(uni.country), // <-- FROM UTILS
                            height: 32,
                            width: 32,
                          ),
                        ),
                        title: Text(
                          uni.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(uni.country),
                        trailing: IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () async {
                            if (uni.webPages.isNotEmpty) {
                              final url = Uri.parse(uni.webPages.first);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(
                                  url,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            }
                          },
                        ),
                        onTap: () => context.push('/details', extra: uni),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
