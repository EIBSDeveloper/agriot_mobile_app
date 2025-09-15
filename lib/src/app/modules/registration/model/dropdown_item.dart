import 'package:argiot/src/app/modules/task/model/named_item.dart';
import 'package:argiot/src/app/service/utils/utils.dart';

import '../../../service/utils/enums.dart';


class AppDropdownItem extends NamedItem {
  @override
  final int id;
  @override
  final String name;
  final DocTypes? doctype;
  final String? description;

  AppDropdownItem({
    required this.id,
    required this.name,
    this.doctype,
    this.description,
  });

  factory AppDropdownItem.fromJson(Map<String, dynamic> json) => AppDropdownItem(
      id: json['id'],
      doctype: json['doctype']!= null ? getDocumentTypes(json['doctype']):null,
      name: json['name'],
      description: json['description'],
    );
}
