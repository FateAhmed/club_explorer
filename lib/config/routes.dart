import 'package:explorify/config/env.dart';

class WebRoutes {
  WebRoutes._();

  // Tour routes
  static String tourDetail(String tourId) => '${env.webUrl}/tour/tour-detail/$tourId';
  static String tourBooking(String tourId) => '${env.webUrl}/tour/booking/$tourId';
  static String tours() => '${env.webUrl}/tour';

  // Vehicle routes
  static String vehicleDetail(String vehicleId) => '${env.webUrl}/vehicle/$vehicleId';
  static String vehicles() => '${env.webUrl}/vehicles';

  // Hotel routes
  static String hotelDetail(String hotelId) => '${env.webUrl}/hotel/$hotelId';
  static String hotels({String? region}) =>
      region != null ? '${env.webUrl}/hotels?region=$region' : '${env.webUrl}/hotels';

  // User routes
  static String profile() => '${env.webUrl}/profile';
  static String bookings() => '${env.webUrl}/bookings';
}
