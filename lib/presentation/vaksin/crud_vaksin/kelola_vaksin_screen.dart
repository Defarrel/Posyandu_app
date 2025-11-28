import 'package:flutter/material.dart';
import 'package:posyandu_app/core/components/custom_snackbar.dart';
import 'package:posyandu_app/core/constant/colors.dart';
import 'package:posyandu_app/data/models/response/vaksin/vaksin_master_response_model.dart';
import 'package:posyandu_app/data/repository/vaksin_master_repository.dart';
import 'package:posyandu_app/presentation/vaksin/crud_vaksin/tambah_vaksin_screen.dart';

class KelolaVaksinScreen extends StatefulWidget {
  const KelolaVaksinScreen({super.key});

  @override
  State<KelolaVaksinScreen> createState() => _KelolaVaksinScreenState();
}

class _KelolaVaksinScreenState extends State<KelolaVaksinScreen> {
  final VaksinMasterRepository _repo = VaksinMasterRepository();
  final TextEditingController _searchController = TextEditingController();

  List<VaksinMasterResponseModel> _list = [];
  String _search = "";
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchVaksinMaster();
  }

  Future<void> _fetchVaksinMaster() async {
    setState(() => _loading = true);

    final result = await _repo.getAllVaksin();

    result.fold(
      (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(
            message: "Gagal memuat data: $err",
            type: SnackBarType.error,
          ),
        );
        setState(() => _loading = false);
      },
      (data) {
        setState(() {
          _list = data;
          _loading = false;
        });
      },
    );
  }

  Future<void> _hapusVaksin(int id) async {
    final konfirmasi = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Hapus Vaksin"),
        content: const Text("Yakin ingin menghapus vaksin ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      final result = await _repo.deleteVaksin(id);

      result.fold(
        (err) => ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.show(message: "Gagal: $err", type: SnackBarType.error),
        ),
        (msg) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar.show(
              message: "Vaksin berhasil dihapus",
              type: SnackBarType.success,
            ),
          );
          _fetchVaksinMaster();
        },
      );
    }
  }

  Widget _buildVaksinCard(VaksinMasterResponseModel v) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.vaccines_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        v.namaVaksin,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        v.kode,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(
                      Icons.child_care,
                      size: 16,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Usia: ${v.usiaBulan} bulan",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),

                if ((v.keterangan ?? "").isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    v.keterangan!,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ],
            ),
          ),

          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.primary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TambahVaksinScreen(isEdit: true, model: v),
                    ),
                  ).then((_) => _fetchVaksinMaster());
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _hapusVaksin(v.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _list.where((v) {
      return v.namaVaksin.toLowerCase().contains(_search.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Kelola Vaksin",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahVaksinScreen()),
          ).then((_) => _fetchVaksinMaster());
        },
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari vaksin...",
                prefixIcon: const Icon(Icons.search),
                fillColor: Colors.grey.shade200,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _fetchVaksinMaster,
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : filtered.isEmpty
                    ? const Center(
                        child: Text(
                          "Tidak ada data vaksin",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) =>
                            _buildVaksinCard(filtered[index]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
