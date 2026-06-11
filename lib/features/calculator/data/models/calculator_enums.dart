enum FeedSubType {
  roughageHay,
  silage,
  concentrates,
  prestarter,
  compoundFeed,
  unknown;

  static FeedSubType fromString(String? value) {
    if (value == null) return FeedSubType.unknown;
    return FeedSubType.values.firstWhere(
      (e) => e.name == value || _toSnakeCase(e.name) == value,
      orElse: () => FeedSubType.unknown,
    );
  }
}

enum VetSubType {
  vaccination,
  antibiotics,
  insemination,
  vitamins,
  vetVisit,
  unknown;

  static VetSubType fromString(String? value) {
    if (value == null) return VetSubType.unknown;
    return VetSubType.values.firstWhere(
      (e) => e.name == value || _toSnakeCase(e.name) == value,
      orElse: () => VetSubType.unknown,
    );
  }
}

enum UtilitySubType {
  electricityIncubation,
  waterSupply,
  heating,
  ventilation,
  unknown;

  static UtilitySubType fromString(String? value) {
    if (value == null) return UtilitySubType.unknown;
    return UtilitySubType.values.firstWhere(
      (e) => e.name == value || _toSnakeCase(e.name) == value || value.startsWith('elec_'),
      orElse: () => UtilitySubType.unknown,
    );
  }
}

enum OtherSubType {
  logistics,
  tagsChips,
  slaughterShearing,
  bedding,
  unknown;

  static OtherSubType fromString(String? value) {
    if (value == null) return OtherSubType.unknown;
    return OtherSubType.values.firstWhere(
      (e) => e.name == value || _toSnakeCase(e.name) == value,
      orElse: () => OtherSubType.unknown,
    );
  }
}

enum ProductSubType {
  milk,
  eggsCommercial,
  eggsIncubation,
  meatCarcass,
  dayOldChicks,
  youngStock,
  wool,
  fatTail,
  manure,
  liveWeight,
  honey,
  shubat,
  kumys,
  propolis,
  pollen,
  fur,
  unknown;

  static ProductSubType fromString(String? value) {
    if (value == null) return ProductSubType.unknown;
    return ProductSubType.values.firstWhere(
      (e) => e.name == value || _toSnakeCase(e.name) == value,
      orElse: () => ProductSubType.unknown,
    );
  }
}

enum TaskType {
  vaccination,
  vetCheck,
  breeding,
  feeding,
  general,
  unknown;

  static TaskType fromString(String? value) {
    if (value == null) return TaskType.unknown;
    return TaskType.values.firstWhere(
      (e) => e.name == value || _toSnakeCase(e.name) == value,
      orElse: () => TaskType.unknown,
    );
  }
}

String _toSnakeCase(String input) {
  return input.replaceAllMapped(
      RegExp(r'([A-Z])'), (match) => '_${match.group(1)!.toLowerCase()}');
}
