import 'package:flutter/material.dart';

import '../../services/borrow_service.dart';
import '../widgets/asset_visual.dart';
import '../widgets/status_chip.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, this.embedded = false, this.userId});

  final bool embedded;
  final int? userId;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  final _service = BorrowService();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        _Header(tabController: _tabController),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _BorrowList(
                userId: widget.userId,
                activeOnly: true,
                service: _service,
              ),
              _BorrowList(
                userId: widget.userId,
                activeOnly: false,
                service: _service,
              ),
            ],
          ),
        ),
      ],
    );

    if (widget.embedded) {
      return ColoredBox(color: const Color(0xFFF5F4FA), child: content);
    }

    return Scaffold(backgroundColor: const Color(0xFFF5F4FA), body: content);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Container(
            height: 68,
            color: const Color(0xFF5B39D4),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            alignment: Alignment.centerLeft,
            child: const Text(
              "Aktivitas Peminjam",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            color: const Color(0xFFEDEAF3),
            child: TabBar(
              controller: tabController,
              labelColor: const Color(0xFF5B39D4),
              unselectedLabelColor: const Color(0xFFB8B5BE),
              indicatorColor: const Color(0xFF5B39D4),
              tabs: const [
                Tab(text: "Aktif"),
                Tab(text: "Riwayat"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BorrowList extends StatefulWidget {
  const _BorrowList({
    required this.userId,
    required this.activeOnly,
    required this.service,
  });

  final int? userId;
  final bool activeOnly;
  final BorrowService service;

  @override
  State<_BorrowList> createState() => _BorrowListState();
}

class _BorrowListState extends State<_BorrowList> {
  @override
  Widget build(BuildContext context) {
    if (widget.userId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: widget.service.getUserBorrows(userId: widget.userId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final rows = (snapshot.data ?? []).where((item) {
          final status = item["status"]?.toString() ?? "";
          final active = status == "Menunggu" || status == "Dipinjam";

          return widget.activeOnly ? active : !active;
        }).toList();

        if (rows.isEmpty) {
          return _EmptyState(
            title: widget.activeOnly
                ? "Belum ada aktivitas aktif."
                : "Riwayat masih kosong.",
          );
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
            itemCount: rows.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (_, index) => _BorrowCard(data: rows[index]),
          ),
        );
      },
    );
  }
}

class _BorrowCard extends StatelessWidget {
  const _BorrowCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final status = data["status"]?.toString() ?? "Menunggu";
    final quantity = (data["quantity"] as int?) ?? 1;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDAD6E3)),
      ),
      child: Row(
        children: [
          AssetVisual(image: data["assetImage"]?.toString() ?? "", size: 54),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data["assetName"]?.toString() ?? "-",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
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
                const SizedBox(height: 3),
                Text(
                  _formatRange(
                    data["borrowDate"]?.toString() ?? "",
                    data["returnDate"]?.toString() ?? "",
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 7),
                StatusChip(status: status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatRange(String start, String end) {
    return "${_formatDate(start)} - ${_formatDate(end)}";
  }

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    const months = [
      "januari",
      "februari",
      "maret",
      "april",
      "mei",
      "juni",
      "juli",
      "agustus",
      "september",
      "oktober",
      "november",
      "desember",
    ];

    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.assignment_outlined,
              size: 66,
              color: Color(0xFF9D98AD),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}