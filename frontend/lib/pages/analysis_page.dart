import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  bool _loading = true;
  String? _error;

  int _healthScore = 0;
  bool _isOrganic = false;
  String _label = '';
  String _interpretation = '';
  Map<String, String> _metrics = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await ApiService().getAnalysis();
      if (!mounted) return;
      setState(() {
        _healthScore = (data['healthScore'] as num).toInt();
        _isOrganic = data['isOrganic'] as bool;
        _label = data['label'] ?? '';
        _interpretation = data['interpretation'] ?? '';
        _metrics = Map<String, String>.from(data['metrics'] as Map);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load audit analysis.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Color(0xFF374151))),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry Analysis'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Model Prediction',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'ML-based classification of soil history',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
            ),
            const SizedBox(height: 32),

            // --- RESULT CARD ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF1B4332),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    _label.toUpperCase().replaceAll('_', ' '),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: _healthScore / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.white10,
                          color: _isOrganic ? const Color(0xFF52B788) : const Color(0xFFEF4444),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '$_healthScore%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Confidence',
                            style: TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            
            // --- DETAILED INTERPRETATION ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isOrganic ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _isOrganic ? const Color(0xFFDCFCE7) : const Color(0xFFFFEDD5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isOrganic ? Icons.eco : Icons.warning_amber_rounded,
                        color: _isOrganic ? const Color(0xFF059669) : const Color(0xFFC2410C),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isOrganic ? 'ORGANIC VERIFIED' : 'CHEMICAL TRACES DETECTED',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _isOrganic ? const Color(0xFF059669) : const Color(0xFFC2410C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _interpretation,
                    style: TextStyle(
                      color: _isOrganic ? const Color(0xFF065F46) : const Color(0xFF9A3412), 
                      fontSize: 14, 
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Audit Detail Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 16),

            // --- METRICS LIST ---
            ..._metrics.entries.map((entry) => _AuditDetailRow(
              label: entry.key.toUpperCase(),
              status: entry.value,
            )),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.file_download_outlined),
                label: const Text('Export Audit Report (PDF)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuditDetailRow extends StatelessWidget {
  final String label;
  final String status;

  const _AuditDetailRow({required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final bool isOptimal = status.toLowerCase().contains('optimal') || status.toLowerCase().contains('good');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isOptimal ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isOptimal ? const Color(0xFF059669) : const Color(0xFFB91C1C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
