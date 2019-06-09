import 'dart:convert';

TagModel tagFromJson(String str) => TagModel.fromMap(json.decode(str));

String tagToJson(TagModel data) => json.encode(data.toMap());

class TagModel {
  int id;
  String nmTag;
  String nmUsuario;
  String nmRepositorio;

  TagModel({
    this.id,
    this.nmTag,
    this.nmUsuario,
    this.nmRepositorio,
  });

  factory TagModel.fromMap(Map<String, dynamic> json) => new TagModel(
        id: json["id"],
        nmTag: json["nmTag"],
        nmUsuario: json["nmUsuario"],
        nmRepositorio: json["nmRepositorio"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "nmTag": nmTag,
        "nmUsuario": nmUsuario,
        "nmRepositorio": nmRepositorio,
      };
}
