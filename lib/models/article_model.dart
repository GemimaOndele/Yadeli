/// Article d'un établissement (produit, plat, médicament, etc.)
class ArticleModel {
  final String id;
  final String name;
  final String? photoPath;
  final double price;
  final String establishmentId;
  final bool available; // false = indisponible ou presque vendu
  final String? unavailableMessage; // message de l'établissement si indisponible

  ArticleModel({
    required this.id,
    required this.name,
    this.photoPath,
    required this.price,
    required this.establishmentId,
    this.available = true,
    this.unavailableMessage,
  });
}
