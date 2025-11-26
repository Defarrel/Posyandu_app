import 'package:flutter/material.dart';
import 'package:posyandu_app/core/constant/constants.dart';

class CustomAppBarCari extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final String filterValue;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onFilterChanged;

  const CustomAppBarCari({
    super.key,
    required this.searchController,
    required this.filterValue,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(230);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: SlightDownCurveClipper(),
      child: Container(
        height: preferredSize.height,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/core/assets/kiri.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Cari Data Balita",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: searchController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.primary,
                          ),
                          hintText: "Cari Nama / NIK Balita",
                          hintStyle: const TextStyle(color: Colors.black54),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: onSearchChanged,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: filterValue,
                            icon: const Icon(
                              Icons.filter_list,
                              color: AppColors.primary,
                            ),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: "Semua",
                                child: Text("Semua"),
                              ),
                              DropdownMenuItem(
                                value: "Balita",
                                child: Text("Balita"),
                              ),
                              DropdownMenuItem(
                                value: "Baduta",
                                child: Text("Baduta"),
                              ),
                            ],
                            onChanged: onFilterChanged,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SlightDownCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 25);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 10,
      size.width,
      size.height - 25,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
