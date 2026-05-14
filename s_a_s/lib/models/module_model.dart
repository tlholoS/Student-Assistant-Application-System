/*
* Student Numbers: 224102916, 224099548, 223095490, 224004511, 224022386, 224097774, 224052285, 224019969, 224008698, 224053964
* Student Names: Ramahlosi PD, Bere AM, Motlhakane M, Modisana MD, Simelane LW, Freeman C, Seitshiro TT, Lewis DC, Molefi MD, Mfuphi L

*/

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