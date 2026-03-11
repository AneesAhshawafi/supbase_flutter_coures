import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supbase_flutter_coures/data/models/note.dart';
import 'package:supbase_flutter_coures/services/storage_service.dart';
import 'package:supbase_flutter_coures/shared/theme/app_theme.dart';

/// Stateless card widget for displaying a [Note] in a grid.
/// All actions are passed as callbacks to keep this widget pure.
class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Action icons row ──────────────────────────────────────
              Row(
                children: [
                  _ActionIcon(
                    icon: Icons.delete_outline,
                    tooltip: 'Delete',
                    onTap: onDelete,
                  ),
                  const SizedBox(width: 6),
                  _ActionIcon(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit',
                    onTap: onEdit,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Title ─────────────────────────────────────────────────
              Text(
                note.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // ── Content ───────────────────────────────────────────────
              Expanded(
                child: Text(
                  note.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.fade,
                ),
              ),

              // ── Thumbnail ─────────────────────────────────────────────
              if (note.hasImage) ...[
                const SizedBox(height: 8),
                Expanded(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: StorageService().getPublicUrl(note.imagePath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder:
                          (context, url) => Container(
                            color: AppTheme.cardHoverColor,
                            child: const Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: AppTheme.cardHoverColor,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 28,
                              ),
                            ),
                          ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 18, color: AppTheme.mutedColor),
        ),
      ),
    );
  }
}
