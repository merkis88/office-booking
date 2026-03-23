import 'package:wordpice/features/archive/presentation/models/archive_item.dart';

abstract class ArchiveDataSource {
  Future<List<ArchiveItem>> getArchivedPlaces();
  Future<void> restorePlace({required int placeId});
}
