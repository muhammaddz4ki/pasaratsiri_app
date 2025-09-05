import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pasaratsiri_app/features/buyer/screens/add_review_screen.dart'; // Sesuaikan path ini jika perlu

enum ReviewState { loading, reviewed, notReviewed }

class ReviewStatusButton extends StatefulWidget {
  final String productId;
  final String orderId;

  const ReviewStatusButton({
    super.key,
    required this.productId,
    required this.orderId,
  });

  @override
  State<ReviewStatusButton> createState() => _ReviewStatusButtonState();
}

class _ReviewStatusButtonState extends State<ReviewStatusButton> {
  ReviewState _reviewState = ReviewState.loading;

  @override
  void initState() {
    super.initState();
    _checkReviewStatus();
  }

  Future<void> _checkReviewStatus() async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final reviewDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .collection('reviews')
          .doc(widget.orderId)
          .get();

      if (mounted) {
        setState(() {
          if (reviewDoc.exists) {
            _reviewState = ReviewState.reviewed;
          } else {
            _reviewState = ReviewState.notReviewed;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _reviewState = ReviewState.notReviewed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_reviewState) {
      case ReviewState.loading:
        return const Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        );

      case ReviewState.reviewed:
        return Align(
          alignment: Alignment.centerRight,
          child: Chip(
            avatar: Icon(
              Icons.check_circle,
              color: Colors.green.shade800,
              size: 18,
            ),
            label: const Text('Ulasan Dikirim'),
            backgroundColor: Colors.green.shade50,
            labelStyle: TextStyle(
              color: Colors.green.shade800,
              fontWeight: FontWeight.w500,
            ),
            side: BorderSide(color: Colors.green.shade100),
          ),
        );

      case ReviewState.notReviewed:
        return SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            icon: const Icon(Icons.rate_review_outlined),
            label: const Text('Beri Ulasan'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddReviewScreen(
                    productId: widget.productId,
                    orderId: widget.orderId,
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.green.shade700,
              side: BorderSide(color: Colors.green.shade200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        );
    }
  }
}
