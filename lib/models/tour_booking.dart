class TourBookingModel {
  final String id;
  final String tourId;
  final String userId;
  final String packageSelected;
  final int totalParticipants;
  final double packagePrice;
  final String status;
  final DateTime? selectedStartDate;
  final DateTime? bookingDate;
  final List<BookingParticipant>? participants;

  TourBookingModel({
    required this.id,
    required this.tourId,
    required this.userId,
    required this.packageSelected,
    required this.totalParticipants,
    required this.packagePrice,
    required this.status,
    this.selectedStartDate,
    this.bookingDate,
    this.participants,
  });

  factory TourBookingModel.fromJson(Map<String, dynamic> json) {
    return TourBookingModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      tourId: json['tourId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      packageSelected: json['packageSelected']?.toString() ?? '',
      totalParticipants: (json['totalParticipants'] ?? 1).toInt(),
      packagePrice: (json['packagePrice'] ?? 0).toDouble(),
      status: json['status']?.toString() ?? 'pending',
      selectedStartDate: json['selectedStartDate'] != null
          ? DateTime.tryParse(json['selectedStartDate'].toString())
          : null,
      bookingDate: json['bookingDate'] != null
          ? DateTime.tryParse(json['bookingDate'].toString())
          : null,
      participants: json['participants'] != null
          ? List<BookingParticipant>.from(
              (json['participants'] as List).map((p) => BookingParticipant.fromJson(p)))
          : null,
    );
  }
}

class BookingParticipant {
  final String? name;
  final BookingVehicle? selectedVehicle;

  BookingParticipant({this.name, this.selectedVehicle});

  factory BookingParticipant.fromJson(Map<String, dynamic> json) {
    return BookingParticipant(
      name: json['name']?.toString(),
      selectedVehicle: json['selectedVehicle'] != null
          ? BookingVehicle.fromJson(json['selectedVehicle'])
          : null,
    );
  }
}

class BookingVehicle {
  final String? vehicleName;
  final String? vehicleImage;
  final double vehiclePrice;

  BookingVehicle({
    this.vehicleName,
    this.vehicleImage,
    required this.vehiclePrice,
  });

  factory BookingVehicle.fromJson(Map<String, dynamic> json) {
    return BookingVehicle(
      vehicleName: json['vehicleName']?.toString(),
      vehicleImage: json['vehicleImage']?.toString(),
      vehiclePrice: (json['vehiclePrice'] ?? 0).toDouble(),
    );
  }
}
