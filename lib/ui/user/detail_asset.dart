import 'package:flutter/material.dart';

import '../../models/asset.dart';
import '../../services/borrow_service.dart';
import '../widgets/asset_visual.dart';
import 'borrow.dart';

class DetailAssetPage extends StatelessWidget {
  DetailAssetPage(this.lab, {super.key});

  final String lab;
  final _service = BorrowService();

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
              lab,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              "Daftar alat di $lab",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<AssetModel>>(
        future: _service.getAssets(lab: lab),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final assets = snapshot.data ?? [];

          if (assets.isEmpty) {
            return const _EmptyAssets();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(10, 14, 10, 24),
            itemCount: assets.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (_, index) => _AssetListCard(asset: assets[index]),
          );
        },
      ),
    );
  }
}

class _AssetListCard extends StatelessWidget {
  const _AssetListCard({required this.asset});

  final AssetModel asset;

  @override
  Widget build(BuildContext context) {
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
                  Text(
                    available
                        ? "Tersedia ${asset.stock} unit"
                        : "Kosong akan tersedia\npada 25 mei 2026",
                    style: TextStyle(
                      color: available
                          ? const Color(0xFF00A84F)
                          : const Color(0xFFE80028),
                      fontSize: 12,
                      height: 1.25,
                    ),
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
      MaterialPageRoute(builder: (_) => AssetDetailView(asset: asset)),
    );
  }
}

class AssetDetailView extends StatelessWidget {
  const AssetDetailView({super.key, required this.asset});

  final AssetModel asset;

  @override
  Widget build(BuildContext context) {
    final available = asset.stock > 0 && asset.status == "available";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B39D4),
        foregroundColor: Colors.white,
        title: const Text(
          "Detail Asset",
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
                    _InfoPill(
                      icon: Icons.inventory_2_rounded,
                      text: available ? "Stok ${asset.stock}" : "Kosong",
                      color: available
                          ? const Color(0xFF00A84F)
                          : const Color(0xFFE80028),
                    ),
                    const SizedBox(width: 10),
                    _InfoPill(
                      icon: Icons.category_rounded,
                      text: asset.category,
                      color: const Color(0xFF5B39D4),
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
