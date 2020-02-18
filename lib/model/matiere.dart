class Matiere {
  final int id;
  String titre;
  String get fullPromo => titre;


  Matiere({
    this.id, 
    this.titre
    });

  factory Matiere.fromJson(Map<String, dynamic> json) => new Matiere(
    id: json["id"],
    titre: json["titre"]

  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "titre": titre
  };
}