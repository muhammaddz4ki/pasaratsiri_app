class TrainingModule {
  final String id;
  final String title;
  final String category;
  final String thumbnailUrl;
  final String content; // Bisa berisi teks markdown atau link video

  TrainingModule({
    required this.id,
    required this.title,
    required this.category,
    required this.thumbnailUrl,
    required this.content,
  });
}
