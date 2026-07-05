import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../models/asset.dart';
import '../../services/borrow_service.dart';
import '../widgets/asset_visual.dart';

class AssetAdminPage extends StatefulWidget {
  const AssetAdminPage({
    super.key,
    required this.lab,
    this.embedded = false,
  });

  final String lab;
  final bool embedded;

  @override
  State<AssetAdminPage> createState() => _AssetAdminPageState();
}

class _AssetAdminPageState extends State<AssetAdminPage> {
  final _service = BorrowService();
  final _searchCtrl = TextEditingController();

  Key _listKey = UniqueKey();
  String _query = "";

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _refresh() => setState(() => _listKey = UniqueKey());

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        if (widget.embedded)
          SafeArea(
            bottom: false,
            child: Container(
              height: 76,
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
                          "Data Barang",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (widget.lab.isNotEmpty)
                          Text(
                            widget.lab,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: "Tambah alat",
                    onPressed: () => _showAssetSheet(context),
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (value) =>
                setState(() => _query = value.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: "Cari alat...",
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = "");
                      },
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<AssetModel>>(
            key: _listKey,
            future: _service.getAssets(lab: widget.lab),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final assets = (snapshot.data ?? []).where((asset) {
                if (_query.isEmpty) {
                  return true;
                }
                return asset.name.toLowerCase().contains(_query) ||
                    asset.category.toLowerCase().contains(_query);
              }).toList();

              if (assets.isEmpty) {
                return Center(
                  child: Text(
                    _query.isEmpty
                        ? "Belum ada data alat."
                        : "Alat \"$_query\" tidak ditemukan.",
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
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
                              Text(
                                asset.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
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
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded),
                          onSelected: (value) {
                            if (value == "edit") {
                              _showAssetSheet(context, existing: asset);
                            } else if (value == "delete") {
                              _confirmDelete(context, asset);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: "edit",
                              child: Row(
                                children: [
                                  Icon(Icons.edit_rounded, size: 20),
                                  SizedBox(width: 10),
                                  Text("Edit"),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: "delete",
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                                  SizedBox(width: 10),
                                  Text("Hapus", style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );

    if (widget.embedded) {
      return ColoredBox(color: const Color(0xFFE8EDF7), child: body);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE8EDF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF313498),
        foregroundColor: Colors.white,
        title: Text(
          "Data Alat - ${widget.lab.isEmpty ? '-' : widget.lab}",
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: "Tambah alat",
            onPressed: () => _showAssetSheet(context),
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
      body: body,
    );
  }

  Future<void> _confirmDelete(BuildContext context, AssetModel asset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Hapus alat?"),
        content: Text("Alat \"${asset.name}\" akan dihapus permanen dari data lab."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Batal"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirmed == true && asset.id != null) {
      await _service.deleteAsset(asset.id!);
      _refresh();
    }
  }

  Future<String> _persistPickedImage(String sourcePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final assetsDir = Directory(p.join(directory.path, "asset_images"));

    if (!await assetsDir.exists()) {
      await assetsDir.create(recursive: true);
    }

    final fileName = "asset_${DateTime.now().millisecondsSinceEpoch}${p.extension(sourcePath)}";
    final savedFile = await File(sourcePath).copy(p.join(assetsDir.path, fileName));

    return savedFile.path;
  }

  Future<void> _showAssetSheet(BuildContext context, {AssetModel? existing}) async {
    final isEdit = existing != null;

    final nameCtrl = TextEditingController(text: existing?.name ?? "");
    final descCtrl = TextEditingController(text: existing?.description ?? "");
    final stockCtrl = TextEditingController(text: "${existing?.stock ?? 1}");

    String? imagePath =
        (existing != null && existing.image.isNotEmpty) ? existing.image : null;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> pickImage() async {
              final picker = ImagePicker();
              final picked = await picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 80,
              );

              if (picked == null) {
                return;
              }

              final savedPath = await _persistPickedImage(picked.path);

              setSheetState(() => imagePath = savedPath);
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? "Edit Alat" : "Tambah Alat - ${widget.lab}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: pickImage,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EDF7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFDAD6E3)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imagePath == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_rounded, color: Color(0xFF8A8D9D)),
                                  SizedBox(height: 4),
                                  Text(
                                    "Pilih foto",
                                    style: TextStyle(fontSize: 11, color: Color(0xFF8A8D9D)),
                                  ),
                                ],
                              )
                            : Image.file(
                                File(imagePath!),
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text(
                      "Ketuk gambar untuk memilih dari galeri",
                      style: TextStyle(fontSize: 12, color: Color(0xFF8A8D9D)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Nama alat"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: "Deskripsi"),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: stockCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Stok"),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: () async {
                        if (nameCtrl.text.trim().isEmpty) {
                          return;
                        }

                        final stock = int.tryParse(stockCtrl.text.trim()) ?? 0;
                        final status = stock > 0 ? "available" : "unavailable";

                        if (isEdit) {
                          await _service.updateAsset(
                            AssetModel(
                              id: existing.id,
                              name: nameCtrl.text.trim(),
                              category: existing.category,
                              lab: existing.lab,
                              description: descCtrl.text.trim(),
                              stock: stock,
                              image: imagePath ?? "",
                              status: status,
                            ),
                          );
                        } else {
                          await _service.addAsset(
                            AssetModel(
                              name: nameCtrl.text.trim(),
                              category: "",
                              lab: widget.lab,
                              description: descCtrl.text.trim(),
                              stock: stock,
                              image: imagePath ?? "",
                              status: status,
                            ),
                          );
                        }

                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext, true);
                        }
                      },
                      child: Text(isEdit ? "Simpan Perubahan" : "Simpan"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (saved == true) {
      _refresh();
    }
  }
}