import 'package:flutter/material.dart';

import '../../services/borrow_service.dart';
import '../widgets/asset_visual.dart';

enum _ReportPeriod { weekly, monthly, yearly }

class ReportAdminPage extends StatefulWidget {
  const ReportAdminPage({super.key, this.lab = "", this.embedded = false});

  final String lab;
  final bool embedded;

  @override
  State<ReportAdminPage> createState() => _ReportAdminPageState();
}

class _ReportAdminPageState extends State<ReportAdminPage> {
  final _service = BorrowService();

  _ReportPeriod _period = _ReportPeriod.weekly;
  int _offset = 0;

  @override
  Widget build(BuildContext context) {
    final range = _rangeFor(_period, _offset);

    final content = Column(
      children: [
        SafeArea(
          bottom: false,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            color: const Color(0xFF313498),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (!widget.embedded)
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    if (!widget.embedded) const SizedBox(width: 10),
                    const Text(
                      "Laporan",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                if (widget.lab.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    widget.lab,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
              children: [
                _PeriodSelector(
                  period: _period,
                  onChanged: (value) => setState(() {
                    _period = value;
                    _offset = 0;
                  }),
                ),
                const SizedBox(height: 14),
                _RangeNavigator(
                  label: _labelFor(_period, range),
                  onPrev: () => setState(() => _offset -= 1),
                  onNext: _offset < 0 ? () => setState(() => _offset += 1) : null,
                ),
                const SizedBox(height: 18),
                FutureBuilder<Map<String, int>>(
                  future: _service.getReportSummary(
                    lab: widget.lab,
                    start: range.$1,
                    end: range.$2,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final summary = snapshot.data ?? {};
                    final total = summary.values.fold<int>(0, (a, b) => a + b);

                    return Column(
                      children: [
                        _StatCard(
                          label: "Total Pengajuan",
                          value: total,
                          color: const Color(0xFF313498),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.6,
                          children: [
                            _StatCard(
                              label: "Selesai",
                              value: summary["Selesai"] ?? 0,
                              color: const Color(0xFF2BAA55),
                            ),
                            _StatCard(
                              label: "Dipinjam",
                              value: summary["Dipinjam"] ?? 0,
                              color: const Color(0xFF1565D8),
                            ),
                            _StatCard(
                              label: "Menunggu",
                              value: summary["Menunggu"] ?? 0,
                              color: const Color(0xFFF2A20E),
                            ),
                            _StatCard(
                              label: "Ditolak",
                              value: summary["Ditolak"] ?? 0,
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  "Alat Paling Banyak Dipinjam",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _service.getTopBorrowedAssets(
                    lab: widget.lab,
                    start: range.$1,
                    end: range.$2,
                    limit: 5,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final rows = snapshot.data ?? [];

                    if (rows.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "Belum ada peminjaman pada periode ini.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF8A8D9D)),
                        ),
                      );
                    }

                    final maxTotal = rows
                        .map((r) => (r["total"] as int? ?? 0))
                        .fold<int>(0, (a, b) => a > b ? a : b);

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: rows.asMap().entries.map((entry) {
                          final index = entry.key;
                          final row = entry.value;
                          final total = row["total"] as int? ?? 0;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  child: Text(
                                    "${index + 1}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF8A8D9D),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AssetVisual(
                                  image: row["assetImage"]?.toString() ?? "",
                                  size: 40,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        row["assetName"]?.toString() ?? "-",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w800),
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: maxTotal == 0 ? 0 : total / maxTotal,
                                          minHeight: 6,
                                          backgroundColor: const Color(0xFFE8EDF7),
                                          valueColor: const AlwaysStoppedAnimation(
                                            Color(0xFF313498),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "$total",
                                  style: const TextStyle(fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (widget.embedded) {
      return ColoredBox(color: const Color(0xFFE8EDF7), child: content);
    }

    return Scaffold(backgroundColor: const Color(0xFFE8EDF7), body: content);
  }

  (DateTime, DateTime) _rangeFor(_ReportPeriod period, int offset) {
    final now = DateTime.now();

    switch (period) {
      case _ReportPeriod.weekly:
        final anchor = now.add(Duration(days: offset * 7));
        final monday = anchor.subtract(Duration(days: anchor.weekday - 1));
        final start = DateTime(monday.year, monday.month, monday.day);
        final end = start.add(const Duration(days: 6));
        return (start, end);

      case _ReportPeriod.monthly:
        final month = now.month + offset;
        final normalizedYear = now.year + ((month - 1) ~/ 12);
        final normalizedMonth = ((month - 1) % 12) + 1;
        final start = DateTime(normalizedYear, normalizedMonth, 1);
        final end = DateTime(normalizedYear, normalizedMonth + 1, 0);
        return (start, end);

      case _ReportPeriod.yearly:
        final year = now.year + offset;
        return (DateTime(year, 1, 1), DateTime(year, 12, 31));
    }
  }

  String _labelFor(_ReportPeriod period, (DateTime, DateTime) range) {
    const months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];

    final start = range.$1;
    final end = range.$2;

    switch (period) {
      case _ReportPeriod.weekly:
        if (start.month == end.month) {
          return "${start.day} - ${end.day} ${months[start.month - 1]} ${start.year}";
        }
        return "${start.day} ${months[start.month - 1]} - ${end.day} ${months[end.month - 1]} ${end.year}";

      case _ReportPeriod.monthly:
        return "${months[start.month - 1]} ${start.year}";

      case _ReportPeriod.yearly:
        return "${start.year}";
    }
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.period, required this.onChanged});

  final _ReportPeriod period;
  final ValueChanged<_ReportPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PeriodChip(
          label: "Mingguan",
          selected: period == _ReportPeriod.weekly,
          onTap: () => onChanged(_ReportPeriod.weekly),
        ),
        const SizedBox(width: 8),
        _PeriodChip(
          label: "Bulanan",
          selected: period == _ReportPeriod.monthly,
          onTap: () => onChanged(_ReportPeriod.monthly),
        ),
        const SizedBox(width: 8),
        _PeriodChip(
          label: "Tahunan",
          selected: period == _ReportPeriod.yearly,
          onTap: () => onChanged(_ReportPeriod.yearly),
        ),
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF313498) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? const Color(0xFF313498) : const Color(0xFFDAD6E3),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _RangeNavigator extends StatelessWidget {
  const _RangeNavigator({
    required this.label,
    required this.onPrev,
    this.onNext,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
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
      width: double.infinity,
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
          const SizedBox(height: 8),
          Text(
            "$value",
            style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}