class Company {
  final String id; // UUID
  final String name;
  final String taxCode;
  final String address;

  const Company({
    required this.id,
    required this.name,
    required this.taxCode,
    required this.address,
  });
}