import 'dart:convert';

class TourModel {
  String title;
  String searchId;
  String overview;
  String? description;
  String? routeMapImage;
  String startLocation;
  String endLocation;
  List<DateTime> startDate;
  List<DateTime> endDate;
  List<String>? season;
  String? temperatureRange;
  bool guided;
  List<String>? languagesOffered;
  List<Package>? packages;
  List<Itinerary>? itinerary;
  List<String>? includedItems;
  List<String>? excludedItems;
  String? createdBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  String endLocationId;
  String startLocationId;
  String id;
  List<TourPoint>? tourPoints;

  TourModel({
    required this.title,
    required this.searchId,
    required this.overview,
    this.description,
    this.routeMapImage,
    required this.startLocation,
    required this.endLocation,
    required this.startDate,
    required this.endDate,
    this.season,
    this.temperatureRange,
    required this.guided,
    this.languagesOffered,
    this.packages,
    this.itinerary,
    this.includedItems,
    this.excludedItems,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    required this.endLocationId,
    required this.startLocationId,
    required this.id,
    this.tourPoints,
  });

  factory TourModel.fromRawJson(String str) => TourModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TourModel.fromJson(Map<String, dynamic> json) {
    return TourModel(
      title: json["title"] ?? '',
      searchId: json["searchId"] ?? '',
      overview: json["overview"] ?? '',
      description: json["description"],
      routeMapImage: json["routeMapImage"],
      startLocation: json["startLocation"] ?? '',
      endLocation: json["endLocation"] ?? '',
      startDate: json["startDate"] != null
          ? List<DateTime>.from(json["startDate"].map((x) => DateTime.parse(x)))
          : [],
      endDate:
          json["endDate"] != null ? List<DateTime>.from(json["endDate"].map((x) => DateTime.parse(x))) : [],
      season: json["season"] != null ? List<String>.from(json["season"].map((x) => x)) : null,
      temperatureRange: json["temperatureRange"],
      guided: json["guided"] ?? true,
      languagesOffered:
          json["languagesOffered"] != null ? List<String>.from(json["languagesOffered"].map((x) => x)) : null,
      packages: json["packages"] != null
          ? List<Package>.from(json["packages"].map((x) => Package.fromJson(x)))
          : null,
      itinerary: json["itinerary"] != null
          ? List<Itinerary>.from(json["itinerary"].map((x) => Itinerary.fromJson(x)))
          : null,
      includedItems:
          json["includedItems"] != null ? List<String>.from(json["includedItems"].map((x) => x)) : null,
      excludedItems:
          json["excludedItems"] != null ? List<String>.from(json["excludedItems"].map((x) => x)) : null,
      createdBy: json["createdBy"]?.toString(),
      createdAt: json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
      updatedAt: json["updatedAt"] != null ? DateTime.parse(json["updatedAt"]) : null,
      endLocationId: json["endLocationId"] ?? '',
      startLocationId: json["startLocationId"] ?? '',
      id: json["_id"]?.toString() ?? json["id"]?.toString() ?? '',
      tourPoints: json["tourPoints"] != null
          ? List<TourPoint>.from(json["tourPoints"].map((x) => TourPoint.fromMap(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "title": title,
        "searchId": searchId,
        "overview": overview,
        if (description != null) "description": description,
        if (routeMapImage != null) "routeMapImage": routeMapImage,
        "startLocation": startLocation,
        "endLocation": endLocation,
        "startDate": List<dynamic>.from(startDate.map((x) => x.toIso8601String())),
        "endDate": List<dynamic>.from(endDate.map((x) => x.toIso8601String())),
        if (season != null) "season": List<dynamic>.from(season!.map((x) => x)),
        if (temperatureRange != null) "temperatureRange": temperatureRange,
        "guided": guided,
        if (languagesOffered != null) "languagesOffered": List<dynamic>.from(languagesOffered!.map((x) => x)),
        if (packages != null) "packages": List<dynamic>.from(packages!.map((x) => x.toJson())),
        if (itinerary != null) "itinerary": List<dynamic>.from(itinerary!.map((x) => x.toJson())),
        if (includedItems != null) "includedItems": List<dynamic>.from(includedItems!.map((x) => x)),
        if (excludedItems != null) "excludedItems": List<dynamic>.from(excludedItems!.map((x) => x)),
        if (createdBy != null) "createdBy": createdBy,
        if (createdAt != null) "createdAt": createdAt!.toIso8601String(),
        if (updatedAt != null) "updatedAt": updatedAt!.toIso8601String(),
        "endLocationId": endLocationId,
        "startLocationId": startLocationId,
        "id": id,
        if (tourPoints != null) "tourPoints": List<dynamic>.from(tourPoints!.map((x) => x.toMap())),
      };
}

class TourPoint {
  String id;
  String name;
  String description;
  double lat;
  double lng;

  TourPoint({
    required this.id,
    required this.name,
    required this.description,
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'lat': lat,
      'lng': lng,
    };
  }

  factory TourPoint.fromMap(Map<String, dynamic> map) {
    final position = map['position'] as Map<String, dynamic>?;
    return TourPoint(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      lat: (position?['lat'] ?? 0.0).toDouble(),
      lng: (position?['lng'] ?? 0.0).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory TourPoint.fromJson(String source) => TourPoint.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Itinerary {
  int day;
  String title;
  String description;
  String distance;
  String image;

  Itinerary({
    required this.day,
    required this.title,
    required this.description,
    required this.distance,
    required this.image,
  });

  factory Itinerary.fromRawJson(String str) => Itinerary.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Itinerary.fromJson(Map<String, dynamic> json) => Itinerary(
        day: json["day"] ?? 0,
        title: json["title"] ?? '',
        description: json["description"] ?? '',
        distance: json["distance"] ?? '',
        image: json["image"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "day": day,
        "title": title,
        "description": description,
        "distance": distance,
        "image": image,
      };
}

class Package {
  String name;
  int price;
  bool perPerson;
  String details;
  List<String> included;
  List<String> excluded;

  Package({
    required this.name,
    required this.price,
    required this.perPerson,
    required this.details,
    required this.included,
    required this.excluded,
  });

  factory Package.fromRawJson(String str) => Package.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Package.fromJson(Map<String, dynamic> json) => Package(
        name: json["name"]?.toString() ?? '',
        price: (json["price"] ?? 0).toInt(),
        perPerson: json["perPerson"] ?? false,
        details: json["details"]?.toString() ?? '',
        included:
            json["included"] != null ? List<String>.from(json["included"].map((x) => x.toString())) : [],
        excluded:
            json["excluded"] != null ? List<String>.from(json["excluded"].map((x) => x.toString())) : [],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "price": price,
        "perPerson": perPerson,
        "details": details,
        "included": List<dynamic>.from(included.map((x) => x)),
        "excluded": List<dynamic>.from(excluded.map((x) => x)),
      };
}
