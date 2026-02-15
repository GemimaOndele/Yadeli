import 'package:flutter/material.dart';
import '../models/establishment_model.dart';
import '../models/article_model.dart';
import '../services/demo_data_service.dart';
import '../services/external_reviews_service.dart';
import '../services/cart_service.dart';
import '../services/user_activity_service.dart';
import '../services/favorites_service.dart';

/// Profil établissement — photos, infos, distance, avis Google/Trustpilot
class EstablishmentProfileScreen extends StatefulWidget {
  final EstablishmentModel? establishment;
  final String? establishmentId;

  const EstablishmentProfileScreen({super.key, this.establishment, this.establishmentId});

  @override
  State<EstablishmentProfileScreen> createState() => _EstablishmentProfileScreenState();
}

class _EstablishmentProfileScreenState extends State<EstablishmentProfileScreen> {
  AggregatedReviews? _reviews;
  List<ArticleModel> _articles = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final e = widget.establishment ?? (widget.establishmentId != null ? DemoDataService.getEstablishmentById(widget.establishmentId!) : null);
    if (e == null) return;
    UserActivityService.logEstablishmentViewed(e.id, e.name, e.category);
    final r = await ExternalReviewsService.getAggregatedReviews(e);
    final articles = DemoDataService.getArticlesByEstablishment(e.id);
    if (mounted) {
      setState(() {
        _reviews = r;
        _articles = articles;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.establishment ?? (widget.establishmentId != null ? DemoDataService.getEstablishmentById(widget.establishmentId!) : null);
    if (e == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Établissement"), backgroundColor: Colors.green[700]),
        body: const Center(child: Text("Établissement introuvable")),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(e.name),
        backgroundColor: Colors.green[700],
        actions: [
          FutureBuilder<bool>(
            future: FavoritesService.isFavoriteEstablishment(e.id),
            builder: (context, snap) => IconButton(
              icon: Icon(snap.data == true ? Icons.favorite : Icons.favorite_border, color: snap.data == true ? Colors.red : null),
              onPressed: () async {
                final wasFav = snap.data == true;
                if (wasFav) {
                  await FavoritesService.removeFavoriteEstablishment(e.id);
                } else {
                  await FavoritesService.addFavoriteEstablishment({'id': e.id, 'name': e.name, 'category': e.category, 'address': e.address});
                }
                if (mounted) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(wasFav ? "Retiré des favoris" : "Ajouté aux favoris"), behavior: SnackBarBehavior.floating));
                }
              },
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            height: 180,
            color: Colors.grey[300],
            child: e.photoPath != null && e.photoPath!.startsWith('assets/')
                ? Image.asset(e.photoPath!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: Icon(Icons.store, size: 80, color: Colors.grey[500])))
                : Center(child: Icon(Icons.store, size: 80, color: Colors.grey[500])),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Chip(label: Text(e.category), backgroundColor: Colors.green[100]),
                    const SizedBox(width: 8),
                    Row(children: [Icon(Icons.star, size: 18, color: Colors.amber[700]), const SizedBox(width: 4), Text(e.rating.toStringAsFixed(1))]),
                    if (e.positiveReviewsCount > 0) ...[const SizedBox(width: 8), Text("${e.positiveReviewsCount} avis Yadeli", style: TextStyle(fontSize: 12, color: Colors.grey[600]))],
                  ],
                ),
                if (_reviews != null) ...[
                  const SizedBox(height: 8),
                  Text("Avis agrégés (Yadeli + Google + Trustpilot): ${_reviews!.averageRating.toStringAsFixed(1)} ★ (${_reviews!.totalCount} avis)", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
                const SizedBox(height: 12),
                Text(e.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(children: [Icon(Icons.location_on, size: 20, color: Colors.green[700]), const SizedBox(width: 8), Expanded(child: Text(e.address))]),
                if (e.openingHours != null && e.closingHours != null) ...[
                  const SizedBox(height: 8),
                  Row(children: [Icon(Icons.schedule, size: 20, color: Colors.green[700]), const SizedBox(width: 8), Text("Ouvert ${e.openingHours} - ${e.closingHours}", style: TextStyle(color: Colors.grey[700]))]),
                ],
                if (e.personality != null) ...[
                  const SizedBox(height: 8),
                  Text(e.personality!, style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700])),
                ],
                if (e.quote != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8), border: Border(left: BorderSide(color: Colors.green[700]!, width: 4))),
                    child: Text('"${e.quote}"', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.green[900])),
                  ),
                ],
                if (e.distanceKm > 0) ...[
                  const SizedBox(height: 8),
                  Row(children: [Icon(Icons.straighten, size: 20, color: Colors.green[700]), const SizedBox(width: 8), Text("${e.distanceKm.toStringAsFixed(1)} km de vous")]),
                ],
                if (_reviews != null && (_reviews!.googleReviews.isNotEmpty || _reviews!.trustpilotReviews.isNotEmpty)) ...[
                  const SizedBox(height: 16),
                  const Text("Avis Google / Trustpilot", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...(_reviews!.googleReviews.take(2).map((r) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(Icons.star, color: Colors.amber[700], size: 20),
                      title: Text(r.text, style: const TextStyle(fontSize: 13)),
                      subtitle: Text("${r.source} • ${r.rating.toStringAsFixed(1)} ★", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    ),
                  ))),
                  ...(_reviews!.trustpilotReviews.take(2).map((r) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(Icons.star, color: Colors.amber[700], size: 20),
                      title: Text(r.text, style: const TextStyle(fontSize: 13)),
                      subtitle: Text("${r.source} • ${r.rating.toStringAsFixed(1)} ★", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    ),
                  ))),
                ],
                if (_articles.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text("Articles proposés", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 12, mainAxisSpacing: 12),
                    itemCount: _articles.length,
                    itemBuilder: (context, i) => _buildArticleCard(_articles[i], e),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(ArticleModel a, EstablishmentModel e) {
    return FutureBuilder<bool>(
      future: FavoritesService.isFavoriteArticle(a.id),
      builder: (context, favSnap) {
        final isFav = favSnap.data ?? false;
        return GestureDetector(
          onTap: () async {
            if (a.available) {
              await CartService.addItem(CartItem(id: a.id, category: e.category, name: a.name, price: a.price, establishmentId: e.id));
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ajouté au panier : ${a.name}"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(a.unavailableMessage ?? "Cet article est indisponible"), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating));
            }
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: a.photoPath != null && a.photoPath!.startsWith('assets/')
                          ? Image.asset(a.photoPath!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.inventory_2, size: 48, color: Colors.grey[400]))
                          : Icon(Icons.inventory_2, size: 48, color: Colors.grey[400]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                          Text("${a.price.round()} XAF", style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 12)),
                          if (!a.available) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(4)),
                              child: Text(a.unavailableMessage ?? "Indisponible", style: TextStyle(fontSize: 10, color: Colors.orange[900])),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(top: 4, right: 4, child: GestureDetector(
                  onTap: () async {
                    if (isFav) {
                      await FavoritesService.removeFavoriteArticle(a.id);
                    } else {
                      await FavoritesService.addFavoriteArticle({'id': a.id, 'name': a.name, 'price': a.price, 'establishmentId': a.establishmentId});
                    }
                    if (mounted) setState(() {});
                  },
                  child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : Colors.grey, size: 24),
                )),
                if (!a.available)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black38,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.block, color: Colors.white, size: 32),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(a.unavailableMessage ?? "Indisponible", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
