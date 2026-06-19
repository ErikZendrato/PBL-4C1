import 'package:flutter/material.dart';

import '../../models/asset.dart';
import '../../models/users.dart';
import '../../services/auth_service.dart';
import '../../services/borrow_service.dart';
import 'detail_asset.dart';
import 'history.dart';
import 'profile.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _auth = AuthService();
  late int _selectedIndex;
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _userFuture = _auth.currentUser();
  }

  void _refreshUser() {
    setState(() {
      _userFuture = _auth.currentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _userFuture,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final pages = [
          _DashboardContent(user: user),
          HistoryPage(embedded: true, userId: user?.id),
          ProfilePage(
            embedded: true,
            user: user,
            onProfileChanged: _refreshUser,
          ),
        ];

        return Scaffold(
          backgroundColor: const Color(0xFFF5F4FA),
          body: IndexedStack(index: _selectedIndex, children: pages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_rounded),
                label: "Beranda",
              ),
              NavigationDestination(
                icon: Icon(Icons.assignment_rounded),
                label: "Aktivitas",
              ),
              NavigationDestination(
                icon: Icon(Icons.person_rounded),
                label: "Profile",
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  _DashboardContent({required this.user});

  final UserModel? user;
  final _service = BorrowService();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<AssetModel>>(
        future: _service.getAssets(),
        builder: (context, snapshot) {
          final assets = snapshot.data ?? [];
          final counts = _countByLab(assets);

          return RefreshIndicator(
            onRefresh: () async {
              await _service.getAssets();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            "Hi, ${user?.name ?? "User Demo"}",
                            key: ValueKey(user?.name ?? "demo"),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Pilih Laboratorium",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.86,
                          ),
                      delegate: SliverChildListDelegate.fixed([
                        _LabCard(
                          title: "Lab Multimedia",
                          count: counts["Lab Multimedia"] ?? 0,
                          icon: Icons.collections_rounded,
                          background: const Color(0xFFF0E8FF),
                          color: const Color(0xFF743DFF),
                        ),
                        _LabCard(
                          title: "Lab RPL",
                          count: counts["Lab RPL"] ?? 0,
                          icon: Icons.desktop_windows_rounded,
                          background: const Color(0xFFE2F5F2),
                          color: const Color(0xFF004F8E),
                        ),
                        _LabCard(
                          title: "Lab Jaringan",
                          count: counts["Lab Jaringan"] ?? 0,
                          icon: Icons.hub_rounded,
                          background: const Color(0xFFE8EEFF),
                          color: const Color(0xFF0E459E),
                        ),
                        _LabCard(
                          title: "Lab Informatika",
                          count: counts["Lab Informatika"] ?? 0,
                          icon: Icons.groups_rounded,
                          background: const Color(0xFFFFEAD9),
                          color: const Color(0xFFE86A1B),
                        ),
                      ]),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, int> _countByLab(List<AssetModel> assets) {
    final counts = <String, int>{};

    for (final asset in assets) {
      counts[asset.lab] = (counts[asset.lab] ?? 0) + 1;
    }

    return counts;
  }
}

class _LabCard extends StatelessWidget {
  const _LabCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.background,
    required this.color,
  });

  final String title;
  final int count;
  final IconData icon;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailAssetPage(title)),
        );
      },
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Hero(
                tag: "lab-$title",
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 58, color: color),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 3),
            Text("$count Alat", style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
