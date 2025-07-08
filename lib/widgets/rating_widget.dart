import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int maxRating;

  const RatingWidget({
    super.key,
    required this.value,
    required this.onChanged,
    this.maxRating = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxRating, (index) {
        final starValue = index + 1;
        final isFilled = starValue <= value;
        
        return GestureDetector(
          onTap: () => onChanged(starValue),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              isFilled ? Icons.star : Icons.star_border,
              size: 32,
              color: isFilled 
                  ? Colors.amber 
                  : Theme.of(context).colorScheme.outline,
            ),
          ),
        );
      }),
    );
  }
}