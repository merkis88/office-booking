import 'package:wordpice/features/archive/presentation/models/archive_item.dart';

abstract class ArchiveRepository {
  Future<List<ArchiveItem>> getArchivedPlaces();
  Future<void> restorePlace({required int placeId});
}
