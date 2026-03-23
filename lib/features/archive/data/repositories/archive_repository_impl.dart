import 'package:wordpice/features/archive/data/datasources/archive_data_source.dart';
import 'package:wordpice/features/archive/domain/repositories/archive_repository.dart';
import 'package:wordpice/features/archive/presentation/models/archive_item.dart';

class ArchiveRepositoryImpl implements ArchiveRepository {
  ArchiveRepositoryImpl(this._dataSource);

  final ArchiveDataSource _dataSource;

  @override
  Future<List<ArchiveItem>> getArchivedPlaces() {
    return _dataSource.getArchivedPlaces();
  }

  @override
  Future<void> restorePlace({required int placeId}) {
    return _dataSource.restorePlace(placeId: placeId);
  }
}
