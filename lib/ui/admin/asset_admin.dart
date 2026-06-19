import 'package:flutter/material.dart';

import '../../models/asset.dart';
import '../../services/borrow_service.dart';
import '../widgets/asset_visual.dart';

class AssetAdminPage extends StatelessWidget {
  const AssetAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = BorrowService();

    return Scaffold(
      backgroundColor: const Color(0xFFE8EDF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF313498),
        foregroundColor: Colors.white,
        title: const Text(
          "Data Alat",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: FutureBuilder<List<AssetModel>>(
        future: service.getAssets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final assets = snapshot.data ?? [];

          if (assets.isEmpty) {
            return const Center(child: Text("Belum ada data alat."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(18),
            itemCount: assets.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final asset = assets[index];
              final available = asset.stock > 0 && asset.status == "available";

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDAD6E3)),
                ),
                child: Row(
                  children: [
                    AssetVisual(image: asset.image, size: 56),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            asset.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(asset.lab, style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 5),
                          Text(
                            available
                                ? "Tersedia ${asset.stock} unit"
                                : "Kosong",
                            style: TextStyle(
                              color: available
                                  ? const Color(0xFF00A84F)
                                  : Colors.red,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
