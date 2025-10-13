// lib/features/jobs/data/datasources/job_local_datasource.dart
import '../../domain/entities/category.dart';
import '../../domain/entities/company.dart';
import '../../domain/entities/job_post.dart';

class JobLocalDataSource {
  // Dữ liệu mẫu giống ảnh
  List<JobPost> getJobs({String? category, String? searchQuery}) {
    final allJobs = [
      JobPost(
        id: '1',
        companyId: 'fpt',
        title: 'Backend developer - Java',
        description: 'Develop backend with Java for e-commerce.',
        status: JobStatus.open,
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
        updatedAt: DateTime.now(),
      ),
      JobPost(
        id: '2',
        companyId: 'viet',
        title: 'Backend developer - Java',
        description: 'Develop backend with Java for retail.',
        status: JobStatus.open,
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
        updatedAt: DateTime.now(),
      ),
    ];

    return allJobs.where((job) {
      if (searchQuery != null && !job.title.toLowerCase().contains(searchQuery.toLowerCase())) return false;
      if (category != null && category != 'All') return true; // Filter sau
      return true;
    }).toList();
  }

  Company getCompany(String companyId) {
    return companyId == 'fpt'
        ? const Company(id: 'fpt', name: 'FPT Shop', taxCode: '123456', address: 'Da Nang')
        : const Company(id: 'viet', name: 'Viet Shop', taxCode: '789012', address: 'Da Nang');
  }

  List<Category> getCategories() {
    return [
      const Category(id: 'all', name: 'All', description: 'All categories'),
      const Category(id: 'dev', name: 'Dev', description: 'Developer'),
      const Category(id: 'tester', name: 'Tester', description: 'QA Tester'),
      const Category(id: 'pm', name: 'Project Manager', description: 'Project Management'),
      const Category(id: 'qa', name: 'QA', description: 'Quality Assurance'),
    ];
  }
}