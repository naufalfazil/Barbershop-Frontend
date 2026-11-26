
import 'package:flutter/material.dart';
import '../../service/api.dart';

class HomePage extends StatefulWidget {
  final String userName;

  const HomePage({super.key, required this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color backgroundColor = Color(0xFF080808);
  static const Color cardColor = Color(0xFF191919);
  static const Color accentColor = Color(0xFFE9D209);
  static const Color primaryText = Color(0xFFF5F5F5);
  static const Color secondaryText = Color(0xFF999999);

  final TextEditingController searchController = TextEditingController();

  int selectedIndex = 0;

  List<Map<String, dynamic>> barbers = [];
  List<Map<String, dynamic>> services = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final responses = await Future.wait([
        ApiService.get('/barbers'),
        ApiService.get('/services'),
      ]);

      final barberResponse = responses[0];
      final serviceResponse = responses[1];

      final barberData = barberResponse['data'] as List;
      final serviceData = serviceResponse['data'] as List;

      if (!mounted) return;

      setState(() {
        barbers = barberData
            .map((item) => Map<String, dynamic>.from(item))
            .where((barber) => barber['statusAktif'] == 1)
            .toList();

        services = serviceData
            .map((item) => Map<String, dynamic>.from(item))
            .where((service) =>
                service['statusAktif'] == 1 &&
                service['status'] == 'published')
            .toList();

        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredServices {
    final keyword = searchController.text.toLowerCase().trim();

    if (keyword.isEmpty) {
      return services;
    }

    return services.where((service) {
      final name = (service['namaLayanan'] ?? '').toString().toLowerCase();
      return name.contains(keyword);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String formatRupiah(dynamic price) {
    final amount = double.tryParse(price.toString()) ?? 0;
    final formatted = amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );

    return 'Rp$formatted';
  }

  Widget _buildNetworkImage({
    required String? imageUrl,
    required IconData fallbackIcon,
    double iconSize = 55,
  }) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: double.infinity,
        color: const Color(0xFF303030),
        child: Icon(
          fallbackIcon,
          color: secondaryText,
          size: iconSize,
        ),
      );
    }

    return Image.network(
      imageUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          color: const Color(0xFF303030),
          child: Icon(
            fallbackIcon,
            color: secondaryText,
            size: iconSize,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: accentColor),
              )
            : errorMessage != null
                ? _buildError()
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 28),
                        _buildSearchBar(),
                        const SizedBox(height: 32),
                        _buildSectionTitle('OUR BARBERS'),
                        const SizedBox(height: 14),
                        _buildBarbers(),
                        const SizedBox(height: 32),
                        _buildSectionTitle('OUR SERVICES'),
                        const SizedBox(height: 14),
                        _buildServices(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off,
              color: secondaryText,
              size: 50,
            ),
            const SizedBox(height: 15),
            const Text(
              'Gagal mengambil data',
              style: TextStyle(
                color: primaryText,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Terjadi kesalahan.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: secondaryText),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: fetchHomeData,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.black,
              ),
              child: const Text('COBA LAGI'),
            ),
          ],
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Row(
      children: [
        const Text(
          'HEY,',
          style: TextStyle(
            color: primaryText,
            fontSize: 30,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              widget.userName.toUpperCase(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: primaryText,
                fontSize: 30,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  // SEARCH BAR - KHUSUS LAYANAN
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextField(
        controller: searchController,
        style: const TextStyle(color: primaryText, fontSize: 14),
        onChanged: (value) {
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: 'SEARCH SERVICES',
          hintStyle: const TextStyle(
            color: secondaryText,
            fontSize: 12,
            letterSpacing: 1,
          ),
          prefixIcon: const Icon(Icons.search, color: accentColor),
          filled: true,
          fillColor: cardColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF303030)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: accentColor),
          ),
        ),
      ),
    );
  }

  // JUDUL SECTION
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        title,
        style: const TextStyle(
          color: primaryText,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // BARBER LIST
  Widget _buildBarbers() {
    if (barbers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Text(
          'Belum ada barber tersedia.',
          style: TextStyle(color: secondaryText),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: barbers.length,
        itemBuilder: (context, index) {
          final barber = barbers[index];

          return Container(
            width: 190,
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: double.infinity,
                      child: _buildNetworkImage(
                        imageUrl: barber['fotoUrl']?.toString(),
                        fallbackIcon: Icons.person,
                        iconSize: 65,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  barber['namaPegawai']?.toString() ?? 'Barber',
                  style: const TextStyle(
                    color: primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  barber['deskripsi']?.toString() ?? 'Professional Barber',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: secondaryText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // SERVICE LIST
  Widget _buildServices() {
    final displayedServices = filteredServices;

    if (displayedServices.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Center(
          child: Text(
            'Layanan tidak ditemukan.',
            style: TextStyle(color: secondaryText),
          ),
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: displayedServices.length,
        itemBuilder: (context, index) {
          final service = displayedServices[index];

          return Container(
            width: 190,
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: double.infinity,
                      child: _buildNetworkImage(
                        imageUrl: service['fotoUrl']?.toString(),
                        fallbackIcon: Icons.content_cut,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  service['namaLayanan']?.toString() ?? 'Layanan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${service['durasiMenit']} minutes',
                  style: const TextStyle(
                    color: secondaryText,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  formatRupiah(service['harga']),
                  style: const TextStyle(
                    color: accentColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 35,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Halaman booking akan dibuat selanjutnya.',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'BOOK NOW',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // BOTTOM NAVIGATION
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      backgroundColor: cardColor,
      selectedItemColor: accentColor,
      unselectedItemColor: secondaryText,
      currentIndex: selectedIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        setState(() {
          selectedIndex = index;
        });

        // Navigasi halaman lain akan ditambahkan nanti.
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          label: 'Booking',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
