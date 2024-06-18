import 'package:get_it/get_it.dart';
import 'package:beyblade/pages/data/navigation_service.dart';

final GetIt sl = GetIt.instance;

void setupLocator() {
  sl.registerLazySingleton(() => NavigationService());
}