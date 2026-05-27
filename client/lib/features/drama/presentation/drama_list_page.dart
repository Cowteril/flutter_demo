import 'package:flutter/material.dart';

import '../../player/presentation/drama_player_page.dart';
import '../data/drama_repository.dart';
import '../domain/models/drama.dart';

class DramaListPage extends StatefulWidget {
  const DramaListPage({required this.repository, super.key});

  final DramaRepository repository;

  @override
  State<DramaListPage> createState() => _DramaListPageState();
}

class _DramaListPageState extends State<DramaListPage> {
  late final Future<List<Drama>> _dramasFuture = widget.repository.listDramas();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('短剧互动客户端')),
      body: SafeArea(
        child: FutureBuilder<List<Drama>>(
          future: _dramasFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final dramas = snapshot.data!;

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: dramas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _DramaTile(
                  drama: dramas[index],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => DramaPlayerPage(drama: dramas[index]),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _DramaTile extends StatelessWidget {
  const _DramaTile({required this.drama, required this.onTap});

  final Drama drama;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Color(drama.coverColor);

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE6E2D8)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 88,
                height: 112,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.movie_creation_outlined,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      drama.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      drama.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetaChip(
                          icon: Icons.video_library_outlined,
                          label: '${drama.episodeCount} 集',
                        ),
                        _MetaChip(
                          icon: Icons.bolt_outlined,
                          label: '${drama.highlights.length} 个高光',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE6E2D8)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15),
            const SizedBox(width: 4),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
