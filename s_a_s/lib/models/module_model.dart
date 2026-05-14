class ModuleModel {
  final String id;
  final String moduleCode;
  final String moduleName;

  ModuleModel({required this.id, required this.moduleCode, required this.moduleName});

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'] as String,
      moduleCode: json['module_code'] as String,
      moduleName: json['module_name'] as String,
    );
  }
}