// import 'package:flutter/material.dart';

// import '../../models/users.dart';
// import '../../services/auth_service.dart';
// import '../../services/borrow_service.dart';
// import '../widgets/asset_visual.dart';
// import '../widgets/status_chip.dart';
// import 'asset_admin.dart';
// import 'profile_admin.dart';
// import 'report_admin.dart';
// import 'request_admin.dart';

// class DashboardAdmin extends StatefulWidget {
//   const DashboardAdmin({super.key, this.initialIndex = 0});

//   final int initialIndex;

//   @override
//   State<DashboardAdmin> createState() => _DashboardAdminState();
// }

// class _DashboardAdminState extends State<DashboardAdmin> {
//   late int _selectedIndex;
//   final _auth = AuthService();
//   UserModel? _admin;
//   bool _loadingAdmin = true;

//   @override
//   void initState() {
//     super.initState();
//     _selectedIndex = widget.initialIndex;
//     _loadAdmin();
//   }

//   Future<void> _loadAdmin() async {
//     final user = await _auth.currentUser();

//     if (!mounted) {
//       return;
//     }

//     setState(() {
//       _admin = user;
//       _loadingAdmin = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loadingAdmin) {
//       return const Scaffold(
//         backgroundColor: Color(0xFFE8EDF7),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     final lab = _admin?.lab ?? "";

//     final pages = [
//       _AdminDashboardContent(lab: lab, onOpenRequests: () => _setIndex(2)),
//       AssetAdminPage(embedded: true, lab: lab),
//       RequestAdminPage(embedded: true, lab: lab),
//       ProfileAdmin(admin: _admin, onUpdated: _loadAdmin),
//     ];

//     return Scaffold(
//       backgroundColor: const Color(0xFFE8EDF7),
//       body: IndexedStack(index: _selectedIndex, children: pages),
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: _selectedIndex,
//         onDestinationSelected: _setIndex,
//         destinations: const [
//           NavigationDestination(
//             icon: Icon(Icons.home_rounded),
//             label: "Beranda",
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.inventory_2_rounded),
//             label: "Barang",
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.assignment_rounded),
//             label: "Peminjaman",
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.person_rounded),
//             label: "Profile",
//           ),
//         ],
//       ),
//     );
//   }

//   void _setIndex(int index) {
//     setState(() => _selectedIndex = index);
//   }
// }

// class _AdminDashboardContent extends StatefulWidget {
//   const _AdminDashboardContent({required this.lab, required this.onOpenRequests});

//   final String lab;
//   final VoidCallback onOpenRequests;

//   @override
//   State<_AdminDashboardContent> createState() => _AdminDashboardContentState();
// }

// class _AdminDashboardContentState extends State<_AdminDashboardContent> {
//   final _service = BorrowService();

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       bottom: false,
//       child: RefreshIndicator(
//         onRefresh: () async => setState(() {}),
//         child: ListView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: EdgeInsets.zero,
//           children: [
//             Container(
//               height: 86,
//               color: const Color(0xFF313498),
//               padding: const EdgeInsets.symmetric(horizontal: 18),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Dashboard Admin",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w900,
//                           ),
//                         ),
//                         const SizedBox(height: 3),
//                         Text(
//                           widget.lab.isEmpty ? "-" : widget.lab,
//                           style: const TextStyle(color: Colors.white, fontSize: 14),
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     tooltip: "Laporan",
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => ReportAdminPage(lab: widget.lab),
//                         ),
//                       );
//                     },
//                     icon: const Icon(
//                       Icons.bar_chart_rounded,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(18),
//               child: FutureBuilder<Map<String, int>>(
//                 future: _service.getStats(lab: widget.lab),
//                 builder: (context, statsSnapshot) {
//                   final stats = statsSnapshot.data ?? {};

//                   return Column(
//                     children: [
//                       GridView.count(
//                         crossAxisCount: 2,
//                         crossAxisSpacing: 14,
//                         mainAxisSpacing: 14,
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         childAspectRatio: 1.45,
//                         children: [
//                           _StatCard(
//                             label: "Total Alat",
//                             value: stats["totalAssets"] ?? 0,
//                           ),
//                           _StatCard(
//                             label: "Peminjaman Aktif",
//                             value: stats["activeBorrows"] ?? 0,
//                             color: Colors.red,
//                           ),
//                           _StatCard(
//                             label: "Menunggu Konfirmasi",
//                             value: stats["pendingBorrows"] ?? 0,
//                             color: const Color(0xFFF2A20E),
//                           ),
//                           _StatCard(
//                             label: "Akan kembali Hari ini",
//                             value: stats["dueToday"] ?? 0,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 26),
//                       InkWell(
//                         borderRadius: BorderRadius.circular(10),
//                         onTap: widget.onOpenRequests,
//                         child: Ink(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 14,
//                             vertical: 11,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: const Row(
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   "Peminjaman Terbaru",
//                                   style: TextStyle(
//                                     fontSize: 19,
//                                     fontWeight: FontWeight.w900,
//                                   ),
//                                 ),
//                               ),
//                               Icon(Icons.chevron_right_rounded),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       FutureBuilder<List<Map<String, dynamic>>>(
//                         future: _service.getAllBorrows(
//                           status: "Menunggu",
//                           lab: widget.lab,
//                         ),
//                         builder: (context, snapshot) {
//                           final rows = (snapshot.data ?? []).take(3).toList();

//                           if (statsSnapshot.connectionState ==
//                                   ConnectionState.waiting ||
//                               snapshot.connectionState ==
//                                   ConnectionState.waiting) {
//                             return const Padding(
//                               padding: EdgeInsets.all(24),
//                               child: Center(child: CircularProgressIndicator()),
//                             );
//                           }

//                           if (rows.isEmpty) {
//                             return const _AdminEmptyState();
//                           }

//                           return Column(
//                             children: rows
//                                 .map(
//                                   (item) => Padding(
//                                     padding: const EdgeInsets.only(bottom: 8),
//                                     child: _RecentBorrowCard(data: item),
//                                   ),
//                                 )
//                                 .toList(),
//                           );
//                         },
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // class _StatCard extends StatelessWidget {
// //   const _StatCard({
// //     required this.label,
// //     required this.value,
// //     this.color = Colors.black,
// //   });

// //   final String label;
// //   final int value;
// //   final Color color;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.all(14),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(8),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
// //           const SizedBox(height: 12),
// //           Text(
// //             "$value",
// //             style: TextStyle(
// //               color: color,
// //               fontSize: 23,
// //               fontWeight: FontWeight.w900,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// class _StatCard extends StatelessWidget {
//   const _StatCard({
//     required this.label,
//     required this.value,
//     this.color = Colors.black,
//   });

//   final String label;
//   final int value;
//   final Color color;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.center,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Flexible(
//             child: Text(
//               label,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w800,
//                 height: 1.1,
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             "$value",
//             style: TextStyle(
//               color: color,
//               fontSize: 23,
//               fontWeight: FontWeight.w900,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _RecentBorrowCard extends StatelessWidget {
//   const _RecentBorrowCard({required this.data});

//   final Map<String, dynamic> data;

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(8),
//       onTap: () async {
//         await Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => AdminBorrowDetailPage(data: data)),
//         );
//       },
//       child: Ink(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           children: [
//             AssetVisual(image: data["assetImage"]?.toString() ?? "", size: 50),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     data["userName"]?.toString() ?? "-",
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w900,
//                     ),
//                   ),
//                   Text(
//                     data["assetName"]?.toString() ?? "-",
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                 ],
//               ),
//             ),
//             StatusChip(status: data["status"]?.toString() ?? "Menunggu"),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _AdminEmptyState extends StatelessWidget {
//   const _AdminEmptyState();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: const Column(
//         children: [
//           Icon(Icons.assignment_turned_in_outlined, color: Color(0xFF8A8D9D)),
//           SizedBox(height: 10),
//           Text("Belum ada pengajuan terbaru."),
//         ],
//       ),
//     );
//   }
// }

// =============================================================================================

// import 'package:flutter/material.dart';

// import '../../models/users.dart';
// import '../../services/auth_service.dart';
// import '../../services/borrow_service.dart';
// import '../widgets/asset_visual.dart';
// import '../widgets/status_chip.dart';
// import 'asset_admin.dart';
// import 'profile_admin.dart';
// import 'report_admin.dart';
// import 'request_admin.dart';

// class DashboardAdmin extends StatefulWidget {
//   const DashboardAdmin({super.key, this.initialIndex = 0});

//   final int initialIndex;

//   @override
//   State<DashboardAdmin> createState() => _DashboardAdminState();
// }

// class _DashboardAdminState extends State<DashboardAdmin> {
//   late int _selectedIndex;
//   final _auth = AuthService();
//   UserModel? _admin;
//   bool _loadingAdmin = true;

//   @override
//   void initState() {
//     super.initState();
//     _selectedIndex = widget.initialIndex;
//     _loadAdmin();
//   }

//   Future<void> _loadAdmin() async {
//     final user = await _auth.currentUser();

//     if (!mounted) {
//       return;
//     }

//     setState(() {
//       _admin = user;
//       _loadingAdmin = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loadingAdmin) {
//       return const Scaffold(
//         backgroundColor: Color(0xFFE8EDF7),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     final lab = _admin?.lab ?? "";

//     final pages = [
//       _AdminDashboardContent(lab: lab, onOpenRequests: () => _setIndex(2)),
//       AssetAdminPage(embedded: true, lab: lab),
//       RequestAdminPage(embedded: true, lab: lab),
//       ProfileAdmin(admin: _admin, onUpdated: _loadAdmin),
//     ];

//     return Scaffold(
//       backgroundColor: const Color(0xFFE8EDF7),
//       body: IndexedStack(index: _selectedIndex, children: pages),
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: _selectedIndex,
//         onDestinationSelected: _setIndex,
//         destinations: const [
//           NavigationDestination(
//             icon: Icon(Icons.home_rounded),
//             label: "Beranda",
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.inventory_2_rounded),
//             label: "Barang",
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.assignment_rounded),
//             label: "Peminjaman",
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.person_rounded),
//             label: "Profile",
//           ),
//         ],
//       ),
//     );
//   }

//   void _setIndex(int index) {
//     setState(() => _selectedIndex = index);
//   }
// }

// class _AdminDashboardContent extends StatefulWidget {
//   const _AdminDashboardContent({required this.lab, required this.onOpenRequests});

//   final String lab;
//   final VoidCallback onOpenRequests;

//   @override
//   State<_AdminDashboardContent> createState() => _AdminDashboardContentState();
// }

// class _AdminDashboardContentState extends State<_AdminDashboardContent> {
//   final _service = BorrowService();

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       bottom: false,
//       child: RefreshIndicator(
//         onRefresh: () async => setState(() {}),
//         child: ListView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: EdgeInsets.zero,
//           children: [
//             Container(
//               height: 86,
//               color: const Color(0xFF313498),
//               padding: const EdgeInsets.symmetric(horizontal: 18),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Dashboard Admin",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w900,
//                           ),
//                         ),
//                         const SizedBox(height: 3),
//                         Text(
//                           widget.lab.isEmpty ? "-" : widget.lab,
//                           style: const TextStyle(color: Colors.white, fontSize: 14),
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     tooltip: "Laporan",
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => ReportAdminPage(lab: widget.lab),
//                         ),
//                       );
//                     },
//                     icon: const Icon(
//                       Icons.bar_chart_rounded,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(18),
//               child: FutureBuilder<Map<String, int>>(
//                 future: _service.getStats(lab: widget.lab),
//                 builder: (context, statsSnapshot) {
//                   final stats = statsSnapshot.data ?? {};

//                   return Column(
//                     children: [
//                       GridView.count(
//                         crossAxisCount: 2,
//                         crossAxisSpacing: 14,
//                         mainAxisSpacing: 14,
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         childAspectRatio: 1.45,
//                         children: [
//                           _StatCard(
//                             label: "Total Alat",
//                             value: stats["totalAssets"] ?? 0,
//                           ),
//                           _StatCard(
//                             label: "Peminjaman Aktif",
//                             value: stats["activeBorrows"] ?? 0,
//                             color: Colors.red,
//                           ),
//                           _StatCard(
//                             label: "Menunggu Konfirmasi",
//                             value: stats["pendingBorrows"] ?? 0,
//                             color: const Color(0xFFF2A20E),
//                           ),
//                           _StatCard(
//                             label: "Akan kembali Hari ini",
//                             value: stats["dueToday"] ?? 0,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 26),
//                       InkWell(
//                         borderRadius: BorderRadius.circular(10),
//                         onTap: widget.onOpenRequests,
//                         child: Ink(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 14,
//                             vertical: 11,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: const Row(
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   "Peminjaman Terbaru",
//                                   style: TextStyle(
//                                     fontSize: 19,
//                                     fontWeight: FontWeight.w900,
//                                   ),
//                                 ),
//                               ),
//                               Icon(Icons.chevron_right_rounded),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       FutureBuilder<List<Map<String, dynamic>>>(
//                         future: _service.getAllBorrows(
//                           status: "Menunggu",
//                           lab: widget.lab,
//                         ),
//                         builder: (context, snapshot) {
//                           final rows = (snapshot.data ?? []).take(3).toList();

//                           if (statsSnapshot.connectionState ==
//                                   ConnectionState.waiting ||
//                               snapshot.connectionState ==
//                                   ConnectionState.waiting) {
//                             return const Padding(
//                               padding: EdgeInsets.all(24),
//                               child: Center(child: CircularProgressIndicator()),
//                             );
//                           }

//                           if (rows.isEmpty) {
//                             return const _AdminEmptyState();
//                           }

//                           return Column(
//                             children: rows
//                                 .map(
//                                   (item) => Padding(
//                                     padding: const EdgeInsets.only(bottom: 8),
//                                     child: _RecentBorrowCard(data: item),
//                                   ),
//                                 )
//                                 .toList(),
//                           );
//                         },
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _StatCard extends StatelessWidget {
//   const _StatCard({
//     required this.label,
//     required this.value,
//     this.color = Colors.black,
//   });

//   final String label;
//   final int value;
//   final Color color;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.center,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Flexible(
//             child: Text(
//               label,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w800,
//                 height: 1.1,
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             "$value",
//             style: TextStyle(
//               color: color,
//               fontSize: 23,
//               fontWeight: FontWeight.w900,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _RecentBorrowCard extends StatelessWidget {
//   const _RecentBorrowCard({required this.data});

//   final Map<String, dynamic> data;

//   @override
//   Widget build(BuildContext context) {
//     final quantity = (data["quantity"] as int?) ?? 1;

//     return InkWell(
//       borderRadius: BorderRadius.circular(8),
//       onTap: () async {
//         await Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => AdminBorrowDetailPage(data: data)),
//         );
//       },
//       child: Ink(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           children: [
//             AssetVisual(image: data["assetImage"]?.toString() ?? "", size: 50),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     data["userName"]?.toString() ?? "-",
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w900,
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           data["assetName"]?.toString() ?? "-",
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                       ),
//                       Container(
//                         margin: const EdgeInsets.only(left: 6),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 7,
//                           vertical: 1,
//                         ),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFEDEBFA),
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: Text(
//                           "x$quantity",
//                           style: const TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w800,
//                             color: Color(0xFF5B39D4),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             StatusChip(status: data["status"]?.toString() ?? "Menunggu"),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _AdminEmptyState extends StatelessWidget {
//   const _AdminEmptyState();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: const Column(
//         children: [
//           Icon(Icons.assignment_turned_in_outlined, color: Color(0xFF8A8D9D)),
//           SizedBox(height: 10),
//           Text("Belum ada pengajuan terbaru."),
//         ],
//       ),
//     );
//   }
// }

// ============================================================================================

import 'package:flutter/material.dart';

import '../../models/users.dart';
import '../../services/auth_service.dart';
import '../../services/borrow_service.dart';
import '../widgets/asset_visual.dart';
import '../widgets/status_chip.dart';
import 'asset_admin.dart';
import 'profile_admin.dart';
import 'report_admin.dart';
import 'request_admin.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  late int _selectedIndex;
  final _auth = AuthService();
  UserModel? _admin;
  bool _loadingAdmin = true;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadAdmin();
  }

  Future<void> _loadAdmin() async {
    final user = await _auth.currentUser();

    if (!mounted) {
      return;
    }

    setState(() {
      _admin = user;
      _loadingAdmin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingAdmin) {
      return const Scaffold(
        backgroundColor: Color(0xFFE8EDF7),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final lab = _admin?.lab ?? "";

    final pages = [
      _AdminDashboardContent(lab: lab, onOpenRequests: () => _setIndex(2)),
      AssetAdminPage(embedded: true, lab: lab),
      RequestAdminPage(embedded: true, lab: lab),
      ProfileAdmin(admin: _admin, onUpdated: _loadAdmin),
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
            icon: Icon(Icons.inventory_2_rounded),
            label: "Barang",
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
  const _AdminDashboardContent({required this.lab, required this.onOpenRequests});

  final String lab;
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
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Dashboard Admin",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.lab.isEmpty ? "-" : widget.lab,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: "Laporan",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportAdminPage(lab: widget.lab),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.bar_chart_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: FutureBuilder<Map<String, int>>(
                future: _service.getStats(lab: widget.lab),
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
                                  "Peminjaman Terbaru",
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
                        future: _service.getAllBorrows(
                          status: "Menunggu",
                          lab: widget.lab,
                        ),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 8),
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
    final quantity = (data["quantity"] as int?) ?? 1;

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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          data["assetName"]?.toString() ?? "-",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEBFA),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "x$quantity",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF5B39D4),
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
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