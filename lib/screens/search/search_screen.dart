import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/database_service.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import 'hospital_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseService();
  final _searchCtrl = TextEditingController();
  final _mapController = MapController();

  List<HospitalModel> _all = [];
  List<HospitalModel> _filtered = [];
  bool _loading = true;
  bool _mapView = false;
  LatLng? _userLocation;
  String _selectedType = 'All';

  final _types = ['All', 'Hospital', 'Clinic'];

  @override
  void initState() {
    super.initState();
    _loadData();
    _getLocation();
  }

  Future<void> _loadData() async {
    try {
      final hospitals = await _db.getHospitals();
      if (mounted) {
        setState(() {
          _all = hospitals;
          _filtered = hospitals;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) return;
      }

      final pos = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userLocation = LatLng(pos.latitude, pos.longitude);
        });
      }
    } catch (_) {}
  }

  void _search(String q) {
    setState(() {
      _filtered = _all.where((h) {
        final matchesType = _selectedType == 'All' ||
            h.type.toLowerCase() == _selectedType.toLowerCase();
        if (q.isEmpty) return matchesType;
        final lq = q.toLowerCase();
        return matchesType &&
            (h.name.toLowerCase().contains(lq) ||
                h.address.toLowerCase().contains(lq) ||
                h.services.any((s) => s.toLowerCase().contains(lq)));
      }).toList();
    });
  }

  void _filterType(String type) {
    setState(() => _selectedType = type);
    _search(_searchCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Search header ───────────────────────────────────────────────
          Container(
            color: AppColors.surface,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 24,
              right: 24,
              bottom: 16,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: _search,
                        decoration: InputDecoration(
                          hintText: 'Search hospitals, doctors, services...',
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppColors.textHint, size: 20),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded,
                                      size: 18, color: AppColors.textHint),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    _search('');
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Map/List toggle
                    GestureDetector(
                      onTap: () => setState(() => _mapView = !_mapView),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _mapView
                              ? AppColors.primary
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Icon(
                          _mapView ? Icons.list_rounded : Icons.map_rounded,
                          color: _mapView ? Colors.white : AppColors.textPrimary,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Type filter chips
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _types.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final t = _types[i];
                      final sel = _selectedType == t;
                      return GestureDetector(
                        onTap: () => _filterType(t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.primary
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sel
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            t,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: sel
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Results count ───────────────────────────────────────────────
          if (!_loading && !_mapView)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(
                children: [
                  Text(
                    '${_filtered.length} result${_filtered.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

          // ── Content ─────────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? _shimmerList()
                : _mapView
                    ? _buildMap()
                    : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _shimmerList() {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const ShimmerBox(height: 100),
    );
  }

  Widget _buildList() {
    if (_filtered.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No results found',
        subtitle: 'Try searching with different keywords.',
        actionLabel: 'Clear Search',
        onAction: () {
          _searchCtrl.clear();
          _search('');
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => HospitalCard(hospital: _filtered[i]),
    );
  }

  Widget _buildMap() {
    // Default to Philippines center if no location
    final center = _userLocation ?? const LatLng(14.4445, 121.0035);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 14,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.medihub',
        ),
        MarkerLayer(
          markers: [
            // User location
            if (_userLocation != null)
              Marker(
                point: _userLocation!,
                width: 24,
                height: 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 6)
                    ],
                  ),
                ),
              ),
            // Hospital markers
            ..._filtered.map((h) => Marker(
                  point: LatLng(h.lat, h.lng),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => _showHospitalSheet(h),
                    child: Container(
                      decoration: BoxDecoration(
                        color: h.type == 'hospital'
                            ? AppColors.primary
                            : AppColors.accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (h.type == 'hospital'
                                    ? AppColors.primary
                                    : AppColors.accent)
                                .withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.local_hospital_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ],
    );
  }

  void _showHospitalSheet(HospitalModel hospital) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: HospitalCard(hospital: hospital),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}