import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/drama/data/mock_drama_repository.dart';
import '../features/drama/presentation/drama_list_page.dart';

class DuanjuApp extends StatelessWidget {
  const DuanjuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = MockDramaRepository();

    return MaterialApp(
      title: '短剧互动',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: DramaListPage(repository: repository),
    );
  }
}
