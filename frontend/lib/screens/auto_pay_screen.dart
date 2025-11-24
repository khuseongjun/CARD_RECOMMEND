import 'package:flutter/material.dart';
import 'package:card_buddy/services/auto_pay_service.dart';
import 'package:card_buddy/theme/colors.dart';
import 'package:card_buddy/theme/typography.dart';

class AutoPayScreen extends StatefulWidget {
  const AutoPayScreen({super.key});

  @override
  State<AutoPayScreen> createState() => _AutoPayScreenState();
}

class _AutoPayScreenState extends State<AutoPayScreen> {
  final AutoPayService _autoPayService = AutoPayService();
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String? _error;

  Future<void> _simulatePayment(String type) async {
    setState(() {
      _isLoading = true;
      _result = null;
      _error = null;
    });

    try {
      final result = await _autoPayService.simulatePayment(
        userId: "user_123", 
        paymentType: type,
      );
      setState(() {
        _result = result;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR 결제"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            // QR 스캔 영역 시각화
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.grey300),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                   Icon(Icons.qr_code_2, size: 200, color: AppColors.grey300),
                   if (_isLoading)
                     const CircularProgressIndicator(),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            if (_result == null && !_isLoading)
              ElevatedButton.icon(
                onPressed: () => _simulatePayment("qr"),
                icon: const Icon(Icons.camera_alt),
                label: const Text("QR 코드 스캔하기"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  textStyle: AppTypography.t3.copyWith(fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

            if (_error != null)
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("오류: $_error", style: const TextStyle(color: Colors.red)),
              )
            else if (_result != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    _buildResultCard(_result!),
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _result = null;
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text("다시 스캔하기"),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    final tx = result['transaction'];
    final rec = result['recommendation'];
    final classification = result['classification'];

    return Card(
      elevation: 4,
      shadowColor: AppColors.shadowLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 28),
                const SizedBox(width: 8),
                Text("결제 성공!", style: AppTypography.h2.copyWith(color: Colors.green)),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle("결제 정보"),
            _buildInfoRow("가맹점", tx['merchant_name']),
            _buildInfoRow("카테고리", tx['merchant_category']),
            _buildInfoRow("금액", "${tx['amount']}원"),
            const Divider(height: 32),
            _buildSectionTitle("추천 카드 & 혜택"),
            _buildInfoRow("카드", rec['card_name']),
            _buildInfoRow("예상 혜택", "${rec['expected_benefit']}원", isHighlight: true),
            _buildInfoRow("혜택 설명", rec['benefit_description']),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.grey600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text("실적 분류: $classification", style: AppTypography.caption),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body2.copyWith(color: AppColors.grey600)),
          Text(
            value, 
            style: AppTypography.body1.copyWith(
              fontWeight: FontWeight.bold,
              color: isHighlight ? AppColors.primaryBlue : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
