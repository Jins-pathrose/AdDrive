 class Fleet {
    final int id;
    final String fleetName;
    final String? fleetProfile;

    Fleet({
      required this.id,
      required this.fleetName,
      this.fleetProfile,
    });

    factory Fleet.fromJson(Map<String, dynamic> json) {
      return Fleet(
        id: json['id'],
        fleetName: json['fleet_name'],
        fleetProfile: json['fleet_profile'],
      );
    }
  }