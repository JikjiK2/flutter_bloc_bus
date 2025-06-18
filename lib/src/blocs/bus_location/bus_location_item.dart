

import 'package:flutter_project/src/data/bus_location_response.dart';

abstract class BusLocationState {
  const BusLocationState();
}

class BusLocationInitial extends BusLocationState {
  const BusLocationInitial();
}

class BusLocationLoading extends BusLocationState {
  const BusLocationLoading();
}


class BusLocationError extends BusLocationState {
  final String message;

  const BusLocationError({required this.message});
}
