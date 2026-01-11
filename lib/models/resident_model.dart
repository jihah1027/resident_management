import 'household_model.dart';

class Resident {
  final String? id; 
  final String name;
  final int age;
  final String phone;
  final String address;
  final String incomeRange;
  final String? mukim;
  final String? kampung;
  final List<String>? bantuan;
  final List<HouseholdMember> householdMembers;
  final String lastUpdate;

  Resident({
    this.id,
    required this.name,
    required this.age,
    required this.phone,
    required this.address,
    required this.incomeRange,
    this.mukim,
    this.kampung,
    this.bantuan,
    required this.householdMembers,
    required this.lastUpdate,
  });

  factory Resident.fromJson(Map<String, dynamic> json) {
    List<String> bantuanList = [];
    if (json['bantuan'] != null && json['bantuan'].toString().isNotEmpty) {
      bantuanList = json['bantuan'].toString().split(',');
    }

    var list = json['household_members'] as List? ?? [];
    List<HouseholdMember> members = list.map((i) => HouseholdMember.fromJson(i)).toList();

    return Resident(
      id: json['id'].toString(),
      name: json['name'] ?? "",
      age: int.tryParse(json['age'].toString()) ?? 0,
      phone: json['phone'] ?? "",
      address: json['address'] ?? "",
      incomeRange: json['incomeRange'] ?? "",
      mukim: json['mukim'],
      kampung: json['kampung'],
      bantuan: bantuanList,
      householdMembers: members,
      lastUpdate: json['lastUpdate'] ?? "",
    );
  }
}