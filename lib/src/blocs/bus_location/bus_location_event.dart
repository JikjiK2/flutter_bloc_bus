abstract class BusLocationEvent {
  const BusLocationEvent();
}

class LoadBusLocations extends BusLocationEvent {
  final String routeId;

  const LoadBusLocations({required this.routeId});
}
