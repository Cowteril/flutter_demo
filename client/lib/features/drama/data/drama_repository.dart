import '../domain/models/drama.dart';

abstract class DramaRepository {
  Future<List<Drama>> listDramas();

  Future<Drama?> findDrama(String id);
}
