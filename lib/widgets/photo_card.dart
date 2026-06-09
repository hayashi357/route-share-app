import 'package:flutter/material.dart';
import '../models/photo_post.dart';

class PhotoCard extends StatefulWidget {
  final PhotoPost photo;
  final VoidCallback? onLike;
  final VoidCallback? onUnlike;
  final VoidCallback? onTap;

  const PhotoCard({
    required this.photo,
    this.onLike,
    this.onUnlike,
    this.onTap,
  });

  @override
  State<PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<PhotoCard> {
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                color: Colors.grey[200],
                width: double.infinity,
                child: Image.network(
                  widget.photo.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.photo.caption != null)
                    Text(
                      widget.photo.caption!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.photo.likeCount} いいね',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      IconButton(
                        icon: Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _isLiked ? Colors.red : null,
                        ),
                        onPressed: () {
                          setState(() => _isLiked = !_isLiked);
                          if (_isLiked) {
                            widget.onLike?.call();
                          } else {
                            widget.onUnlike?.call();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
