import 'package:flutter/material.dart';

import '../../domain/entities/company.dart';
import '../../domain/usecases/get_company_details_usecase.dart';

class JobCompanyTab extends StatefulWidget {
  final String companyId;
  final GetCompanyDetailsUseCase useCase;

  const JobCompanyTab({
    super.key,
    required this.companyId,
    required this.useCase,
  });

  @override
  State<JobCompanyTab> createState() => _JobCompanyTabState();
}

class _JobCompanyTabState extends State<JobCompanyTab> {
  Company? _company;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  Future<void> _loadCompany() async {
    try {
      final company = await widget.useCase(widget.companyId);
      setState(() => _company = company);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi tải công ty: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_company == null) {
      return const Center(child: Text("Không có thông tin công ty"));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _company!.logoUrl ?? '',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.business_outlined, size: 60, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              _company!.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 28),
          _buildInfoSection(
            icon: Icons.location_on_outlined,
            label: 'Địa chỉ',
            value: _company!.address,
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            icon: Icons.phone_outlined,
            label: 'Điện thoại',
            value: _company!.phone ?? 'Đang cập nhật',
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            icon: Icons.email_outlined,
            label: 'Email',
            value: _company!.email?? 'Đang cập nhật',
          ),
          const SizedBox(height: 28),
          Text(
            'Mô tả',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              _company!.description ?? "Không có mô tả",
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
