class Notes {
  String? id;
  String body;
  List<String> tags;
  String? owner;
  String title;

  Notes({
    this.id,
    required this.body,
    required this.tags,
    this.owner,
    required this.title,
  });

  factory Notes.fromJson(Map<String, dynamic> json) => Notes(
        id: json["id"],
        body: json["body"],
        tags: List<String>.from(json["tags"].map((x) => x)),
        owner: json["owner"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "body": body,
        "tags": List<dynamic>.from(tags.map((x) => x)),
        "owner": owner,
        "title": title,
      };
}
