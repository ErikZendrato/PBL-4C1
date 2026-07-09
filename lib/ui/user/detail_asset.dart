import 'package:flutter/material.dart';

import '../../models/asset.dart';
import '../../services/borrow_service.dart';
import '../widgets/asset_visual.dart';
import 'borrow.dart';

class DetailAssetPage extends StatefulWidget {
  const DetailAssetPage(this.lab, {super.key});

  final String lab;

  @override
  State<DetailAssetPage> createState() => _DetailAssetPageState();
}

class _DetailAssetPageState extends State<DetailAssetPage> {
  final _service = BorrowService();
  final _searchCtrl = TextEditingController();

  late Future<List<AssetModel>> _assetsFuture;
  String _query = "";

  @override
  void initState() {
    super.initState();
    _assetsFuture = _service.getAssets(lab: widget.lab);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FA),
      appBar: AppBar(
        toolbarHeight: 84,
        backgroundColor: const Color(0xFF5B39D4),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.lab,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              "Daftar alat di ${widget.lab}",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
            child: _SearchField(
              controller: _searchCtrl,
              onChanged: (value) => setState(() => _query = value.trim()),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<AssetModel>>(
              future: _assetsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final assets = snapshot.data ?? [];

                if (assets.isEmpty) {
                  return const _EmptyAssets();
                }

                final filtered = _query.isEmpty
                    ? assets
                    : assets
                        .where(
                          (a) => a.name.toLowerCase().contains(
                                _query.toLowerCase(),
                              ),
                        )
                        .toList();

                if (filtered.isEmpty) {
                  return _EmptySearch(query: _query);
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (_, index) =>
                      _AssetListCard(asset: filtered[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: "Cari Alat....",
        hintStyle: const TextStyle(color: Color(0xFF9D98AD)),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Color(0xFF5B39D4),
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () {
                  controller.clear();
                  onChanged("");
                },
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF5B39D4), width: 1.4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF5B39D4), width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF5B39D4), width: 2),
        ),
      ),
    );
  }
}

class _AssetListCard extends StatefulWidget {
  const _AssetListCard({required this.asset});

  final AssetModel asset;

  @override
  State<_AssetListCard> createState() => _AssetListCardState();
}

class _AssetListCardState extends State<_AssetListCard> {
  final _service = BorrowService();

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;
    final available = asset.stock > 0 && asset.status == "available";

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _openDetail(context),
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 9,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: "asset-${asset.id}",
              child: AssetVisual(image: asset.image, size: 58),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  if (available)
                    Text(
                      "Tersedia ${asset.stock} unit",
                      style: const TextStyle(
                        color: Color(0xFF00A84F),
                        fontSize: 12,
                        height: 1.25,
                      ),
                    )
                  else
                    FutureBuilder<String?>(
                      future: asset.id == null
                          ? Future.value(null)
                          : _service.getNearestReturnDate(asset.id!),
                      builder: (context, snapshot) {
                        final text =
                            snapshot.connectionState == ConnectionState.waiting
                            ? "Kosong"
                            : _availabilityText(snapshot.data);

                        return Text(
                          text,
                          style: const TextStyle(
                            color: Color(0xFFE80028),
                            fontSize: 12,
                            height: 1.25,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 46,
              child: FilledButton(
                onPressed: available ? () => _openDetail(context) : null,
                child: const Text("Pinjam"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AssetDetailView(asset: widget.asset)),
    );
  }
}

class AssetDetailView extends StatefulWidget {
  const AssetDetailView({super.key, required this.asset});

  final AssetModel asset;

  @override
  State<AssetDetailView> createState() => _AssetDetailViewState();
}

class _AssetDetailViewState extends State<AssetDetailView> {
  final _service = BorrowService();

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;
    final available = asset.stock > 0 && asset.status == "available";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B39D4),
        foregroundColor: Colors.white,
        title: const Text(
          "Detail Barang",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Hero(
                    tag: "asset-${asset.id}",
                    child: AssetVisual(image: asset.image, size: 128),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  asset.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  asset.lab,
                  style: const TextStyle(color: Color(0xFF6F6790)),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    if (available)
                      _InfoPill(
                        icon: Icons.inventory_2_rounded,
                        text: "Stok ${asset.stock}",
                        color: const Color(0xFF00A84F),
                      )
                    else
                      FutureBuilder<String?>(
                        future: asset.id == null
                            ? Future.value(null)
                            : _service.getNearestReturnDate(asset.id!),
                        builder: (context, snapshot) {
                          final text =
                              snapshot.connectionState ==
                                  ConnectionState.waiting
                              ? "Kosong"
                              : _availabilityText(snapshot.data, short: true);

                          return _InfoPill(
                            icon: Icons.inventory_2_rounded,
                            text: text,
                            color: const Color(0xFFE80028),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  "Deskripsi",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  asset.description,
                  style: const TextStyle(
                    height: 1.45,
                    color: Color(0xFF3E3854),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: available
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BorrowPage(asset: asset),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.event_available_rounded),
              label: const Text("Ajukan Peminjaman"),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAssets extends StatelessWidget {
  const _EmptyAssets();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Color(0xFF9D98AD),
            ),
            SizedBox(height: 14),
            Text(
              "Belum ada alat di lab ini.",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Color(0xFF9D98AD),
            ),
            const SizedBox(height: 14),
            Text(
              'Alat "$query" tidak ditemukan.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

String _availabilityText(String? returnDate, {bool short = false}) {
  if (returnDate == null || returnDate.isEmpty) {
    return "Kosong";
  }

  final formatted = _formatDate(returnDate);

  if (short) {
    return "Kosong, kembali $formatted";
  }

  return "Kosong, akan tersedia\npada $formatted";
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