class ReviewEligibilityModel {
  final bool hasPurchased;
  final bool hasReviewed;
  final bool canReview;

  ReviewEligibilityModel({
    required this.hasPurchased,
    required this.hasReviewed,
    required this.canReview,
  });

  factory ReviewEligibilityModel.fromJson(Map<String, dynamic> json) {
    return ReviewEligibilityModel(
      hasPurchased: json['purchased'] ?? false,
      hasReviewed: json['hasReviewed'] ?? (json['purchased'] == true && json['canReview'] == false),
      canReview: json['canReview'] ?? false,
    );
  }

  factory ReviewEligibilityModel.empty() {
    return ReviewEligibilityModel(
      hasPurchased: false,
      hasReviewed: false,
      canReview: false,
    );
  }
}
