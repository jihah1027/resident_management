class HouseholdMember {
  String name;
  String relation;
  String age;
  String status;

  HouseholdMember({
    required this.name,
    required this.relation,
    required this.age,
    required this.status,
  });

  // TRANSLATOR: From JSON (PHP) to Flutter Object
  factory HouseholdMember.fromJson(Map<String, dynamic> json) {
    return HouseholdMember(
      name: json['name'] ?? "",
      relation: json['relation'] ?? "",
      age: json['age']?.toString() ?? "0",
      status: json['status'] ?? "",
    );
  }

  // TRANSLATOR: From Flutter Object to JSON (to send to PHP)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relation': relation,
      'age': age,
      'status': status,
    };
  }
}