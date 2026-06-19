import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/borrow_service.dart';
import '../splash.dart';
import '../widgets/asset_visual.dart';
import '../widgets/status_chip.dart';
import 'asset_admin.dart';
import 'request_admin.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _AdminDashboardContent(onOpenRequests: () => _setIndex(1)),
      const RequestAdminPage(embedded: true),
      const _AdminProfile(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE8EDF7),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _setIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            label: "Beranda",
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_rounded),
            label: "Peminjaman",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  void _setIndex(int index) {
    setState(() => _selectedIndex = index);
  }
}

class _AdminDashboardContent extends StatefulWidget {
  const _AdminDashboardContent({required this.onOpenRequests});

  final VoidCallback onOpenRequests;

  @override
  State<_AdminDashboardContent> createState() => _AdminDashboardContentState();
}

class _AdminDashboardContentState extends State<_AdminDashboardContent> {
  final _service = BorrowService();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 86,
              color: const Color(0xFF313498),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  const Icon(Icons.menu_rounded, color: Colors.white, size: 30),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Dashboard Admin",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Lab Multimedia",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: "Data alat",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AssetAdminPage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.inventory_2_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: FutureBuilder<Map<String, int>>(
                future: _service.getStats(),
                builder: (context, statsSnapshot) {
                  final stats = statsSnapshot.data ?? {};

                  return Column(
                    children: [
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.45,
                        children: [
                          _StatCard(
                            label: "Total Alat",
                            value: stats["totalAssets"] ?? 0,
                          ),
                          _StatCard(
                            label: "Peminjaman Aktif",
                            value: stats["activeBorrows"] ?? 0,
                            color: Colors.red,
                          ),
                          _StatCard(
                            label: "Menunggu Konfirmasi",
                            value: stats["pendingBorrows"] ?? 0,
                            color: const Color(0xFFF2A20E),
                          ),
                          _StatCard(
                            label: "Akan kembali Hari ini",
                            value: stats["dueToday"] ?? 0,
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: widget.onOpenRequests,
                        child: Ink(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Peminjama Terbaru",
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _service.getAllBorrows(status: "Menunggu"),
                        builder: (context, snapshot) {
                          final rows = (snapshot.data ?? []).take(3).toList();

                          if (statsSnapshot.connectionState ==
                                  ConnectionState.waiting ||
                              snapshot.connectionState ==
                                  ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          if (rows.isEmpty) {
                            return const _AdminEmptyState();
                          }

                          return Column(
                            children: rows
                                .map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _RecentBorrowCard(data: item),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                    ],
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.color = Colors.black,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(
            "$value",
            style: TextStyle(
              color: color,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentBorrowCard extends StatelessWidget {
  const _RecentBorrowCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminBorrowDetailPage(data: data)),
        );
      },
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            AssetVisual(image: data["assetImage"]?.toString() ?? "", size: 50),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data["userName"]?.toString() ?? "-",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    data["assetName"]?.toString() ?? "-",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            StatusChip(status: data["status"]?.toString() ?? "Menunggu"),
          ],
        ),
      ),
    );
  }
}

class _AdminEmptyState extends StatelessWidget {
  const _AdminEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        children: [
          Icon(Icons.assignment_turned_in_outlined, color: Color(0xFF8A8D9D)),
          SizedBox(height: 10),
          Text("Belum ada pengajuan terbaru."),
        ],
      ),
    );
  }
}

class _AdminProfile extends StatelessWidget {
  const _AdminProfile();

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 48),
            Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(
                color: Color(0xFF313498),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                color: Colors.white,
                size: 54,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "Admin Lab",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text("Kelola peminjaman alat laboratorium"),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await auth.logout();

                  if (!context.mounted) {
                    return;
                  }

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const SplashPage()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text("Logout"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
