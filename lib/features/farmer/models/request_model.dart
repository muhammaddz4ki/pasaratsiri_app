enum RequestStatus { Pending, Approved, Rejected }

class RequestModel {
  final String id;
  final String title;
  final String description;
  final RequestStatus status;
  final DateTime submittedDate;

  RequestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.submittedDate,
  });
}
