import 'package:equatable/equatable.dart';

enum AddressLabel { work, home, school, other }

class DeliveryAddress extends Equatable {
  const DeliveryAddress({
    required this.id,
    required this.nameAddress,
    required this.address,
    required this.phoneNumber,
    required this.label,
    required this.isDefault,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String nameAddress;
  final String address;
  final String phoneNumber;
  final AddressLabel label;
  final bool isDefault;
  final double latitude;
  final double longitude;

  DeliveryAddress copyWith({
    String? id,
    String? nameAddress,
    String? address,
    String? phoneNumber,
    AddressLabel? label,
    bool? isDefault,
    double? latitude,
    double? longitude,
  }) {
    return DeliveryAddress(
      id: id ?? this.id,
      nameAddress: nameAddress ?? this.nameAddress,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      label: label ?? this.label,
      isDefault: isDefault ?? this.isDefault,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name_address': nameAddress,
      'address': address,
      'phone_number': phoneNumber,
      'label': label.index,
      'is_default': isDefault ? 1 : 0,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory DeliveryAddress.fromMap(Map<String, dynamic> map) {
    final rawLabel = map['label'];
    final labelIndex = rawLabel is int
        ? rawLabel
        : int.tryParse(rawLabel?.toString() ?? '') ?? 3;

    final rawDefault = map['is_default'];
    final isDefault = rawDefault is int
        ? rawDefault == 1
        : (int.tryParse(rawDefault?.toString() ?? '0') == 1);

    final rawLat = map['latitude'];
    final rawLng = map['longitude'];

    return DeliveryAddress(
      id: map['id'] as String,
      nameAddress: map['name_address'] as String,
      address: map['address'] as String,
      phoneNumber: map['phone_number'] as String,
      label: AddressLabel.values[labelIndex.clamp(0, AddressLabel.values.length - 1)],
      isDefault: isDefault,
      latitude: rawLat is num
          ? rawLat.toDouble()
          : double.tryParse(rawLat?.toString() ?? '') ?? 0,
      longitude: rawLng is num
          ? rawLng.toDouble()
          : double.tryParse(rawLng?.toString() ?? '') ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nameAddress,
        address,
        phoneNumber,
        label,
        isDefault,
        latitude,
        longitude,
      ];
}
