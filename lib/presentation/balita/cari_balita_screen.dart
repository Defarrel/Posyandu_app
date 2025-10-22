import 'package:flutter/material.dart';
import 'package:posyandu_app/presentation/home/home_root.dart';

class CariBalitaScreen extends StatefulWidget {
  const CariBalitaScreen({Key? key}) : super(key: key);

  @override
  State<CariBalitaScreen> createState() => _CariBalitaScreenState();
}

class _CariBalitaScreenState extends State<CariBalitaScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _balitaList = [
    {
      "nama": "Aisyah Putri R.",
      "nik": "3174092301120001",
      "ortu": "Rina Siregar",
    },
    {
      "nama": "Muhammad Alfarizi",
      "nik": "3275081409210002",
      "ortu": "Ahmad Fauzan",
    },
    {
      "nama": "Farel Rizky M.",
      "nik": "3301061608200003",
      "ortu": "Siti Aminah",
    },
    {
      "nama": "Nayla Syakira",
      "nik": "3202091010200004",
      "ortu": "Dedi Mulyadi",
    },
    {
      "nama": "Raka Prasetya",
      "nik": "3374062003210005",
      "ortu": "Indah Permatasari",
    },
  ];

  String _searchQuery = "";
  int? _expandedIndex; 

  @override
  Widget build(BuildContext context) {
    final filteredList = _balitaList.where((balita) {
      final query = _searchQuery.toLowerCase();
      return balita["nama"]!.toLowerCase().contains(query) ||
          balita["nik"]!.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cari Data Balita",
              style: TextStyle(
                color: Color(0xFF0085FF),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF0085FF),
            size: 18,
          ),
          onPressed: () => HomeRoot.navigateToTab(context, 1),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.menu, color: Color(0xFF0085FF)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0085FF)),
                hintText: "Masukkan Nama atau NIK Balita",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),

            const SizedBox(height: 7),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                children: const [
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Nama",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      "NIK",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Nama Ortu",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // List Balita
            Expanded(
              child: ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final balita = filteredList[index];
                  final isExpanded = _expandedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _expandedIndex = isExpanded
                            ? null
                            : index; 
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          // Nama
                          Expanded(
                            flex: 3,
                            child: Text(
                              balita["nama"]!,
                              style: const TextStyle(
                                fontSize: 13,
                              ),
                              overflow: isExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                            ),
                          ),
                          // NIK
                          Expanded(
                            flex: 4,
                            child: Text(
                              balita["nik"]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 13,
                              ),
                              overflow: isExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                            ),
                          ),
                          // Nama Ortu
                          Expanded(
                            flex: 3,
                            child: Text(
                              balita["ortu"]!,
                              style: const TextStyle(
                                fontSize: 13,
                              ),
                              overflow: isExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
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
