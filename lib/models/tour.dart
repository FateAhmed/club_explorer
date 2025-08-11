import 'dart:convert';

class TourModel {
  String title;
  String overview;
  String description;
  String routeMapImage;
  String startLocation;
  String endLocation;
  List<DateTime> startDate;
  List<DateTime> endDate;
  List<String> season;
  String temperatureRange;
  bool guided;
  List<String> languagesOffered;
  List<Package> packages;
  List<Itinerary> itinerary;
  List<String> includedItems;
  List<String> excludedItems;
  String createdBy;
  DateTime createdAt;
  DateTime updatedAt;
  String endLocationId;
  String startLocationId;
  String id;
  List<TourPoint> tourPoints;

  TourModel({
    required this.title,
    required this.overview,
    required this.description,
    required this.routeMapImage,
    required this.startLocation,
    required this.endLocation,
    required this.startDate,
    required this.endDate,
    required this.season,
    required this.temperatureRange,
    required this.guided,
    required this.languagesOffered,
    required this.packages,
    required this.itinerary,
    required this.includedItems,
    required this.excludedItems,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.endLocationId,
    required this.startLocationId,
    required this.id,
    required this.tourPoints,
  });

  factory TourModel.fromRawJson(String str) => TourModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TourModel.fromJson(Map<String, dynamic> json) {
    return TourModel(
      title: json["title"],
      overview: json["overview"],
      description: json["description"],
      routeMapImage: json["routeMapImage"],
      startLocation: json["startLocation"],
      endLocation: json["endLocation"],
      startDate: List<DateTime>.from(json["startDate"].map((x) => DateTime.parse(x))),
      endDate: List<DateTime>.from(json["endDate"].map((x) => DateTime.parse(x))),
      season: List<String>.from(json["season"].map((x) => x)),
      temperatureRange: json["temperatureRange"],
      guided: json["guided"],
      languagesOffered: List<String>.from(json["languagesOffered"].map((x) => x)),
      packages: List<Package>.from(json["packages"].map((x) => Package.fromJson(x))),
      itinerary: List<Itinerary>.from(json["itinerary"].map((x) => Itinerary.fromJson(x))),
      includedItems: List<String>.from(json["includedItems"].map((x) => x)),
      excludedItems: List<String>.from(json["excludedItems"].map((x) => x)),
      createdBy: json["createdBy"],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
      endLocationId: json["endLocationId"],
      startLocationId: json["startLocationId"],
      id: json["id"],
      tourPoints: json["tourPoints"] == null
          ? []
          : List<TourPoint>.from(json["tourPoints"].map((x) => TourPoint.fromMap(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "title": title,
        "overview": overview,
        "description": description,
        "routeMapImage": routeMapImage,
        "startLocation": startLocation,
        "endLocation": endLocation,
        "startDate": List<dynamic>.from(startDate.map((x) => x.toIso8601String())),
        "endDate": List<dynamic>.from(endDate.map((x) => x.toIso8601String())),
        "season": List<dynamic>.from(season.map((x) => x)),
        "temperatureRange": temperatureRange,
        "guided": guided,
        "languagesOffered": List<dynamic>.from(languagesOffered.map((x) => x)),
        "packages": List<dynamic>.from(packages.map((x) => x.toJson())),
        "itinerary": List<dynamic>.from(itinerary.map((x) => x.toJson())),
        "includedItems": List<dynamic>.from(includedItems.map((x) => x)),
        "excludedItems": List<dynamic>.from(excludedItems.map((x) => x)),
        "createdBy": createdBy,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "endLocationId": endLocationId,
        "startLocationId": startLocationId,
        "id": id,
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
    return TourPoint(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      lat: map['position']['lat'] as double,
      lng: map['position']['lng'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory TourPoint.fromJson(String source) => TourPoint.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Itinerary {
  String id;
  int day;
  String title;
  String description;
  String distance;
  String image;

  Itinerary({
    required this.id,
    required this.day,
    required this.title,
    required this.description,
    required this.distance,
    required this.image,
  });

  factory Itinerary.fromRawJson(String str) => Itinerary.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Itinerary.fromJson(Map<String, dynamic> json) => Itinerary(
        id: json["_id"],
        day: json["day"],
        title: json["title"],
        description: json["description"],
        distance: json["distance"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "day": day,
        "title": title,
        "description": description,
        "distance": distance,
        "image": image,
      };
}

class Package {
  String id;
  String name;
  int price;
  bool perPerson;
  String details;
  List<String> included;
  List<String> excluded;

  Package({
    required this.id,
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
        id: json["_id"],
        name: json["name"],
        price: json["price"],
        perPerson: json["perPerson"],
        details: json["details"],
        included: List<String>.from(json["included"].map((x) => x)),
        excluded: List<String>.from(json["excluded"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "price": price,
        "perPerson": perPerson,
        "details": details,
        "included": List<dynamic>.from(included.map((x) => x)),
        "excluded": List<dynamic>.from(excluded.map((x) => x)),
      };
}
