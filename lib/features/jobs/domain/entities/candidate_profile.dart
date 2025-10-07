class CandidateProfile {
  final String id;
  final String userId; // FK to User
  final String cvFile; // Path to file
  final List<String> skillIds; // FK to Skill

  const CandidateProfile({
    required this.id,
    required this.userId,
    required this.cvFile,
    required this.skillIds,
  });
}