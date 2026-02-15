import 'package:flutter/material.dart';
import 'booking_flow_screen.dart';

/// Service de déménagement — plusieurs options avec formulaire adapté
class DemenagementScreen extends StatefulWidget {
  final VoidCallback onOrderPlaced;

  const DemenagementScreen({super.key, required this.onOrderPlaced});

  @override
  State<DemenagementScreen> createState() => _DemenagementScreenState();
}

class _DemenagementScreenState extends State<DemenagementScreen> {
  String? _selectedService;
  final _volumeController = TextEditingController();
  final _floorFromController = TextEditingController();
  final _floorToController = TextEditingController();
  bool _needHelpers = false;
  int _helperCount = 0;

  static const _services = [
    _DemenagementOption(id: 'camion_petit', title: 'Camion petit', subtitle: 'Studio, 1-2 pièces', price: 15000),
    _DemenagementOption(id: 'camion_moyen', title: 'Camion moyen', subtitle: '2-3 pièces', price: 25000),
    _DemenagementOption(id: 'camion_grand', title: 'Camion grand', subtitle: 'Maison, 4+ pièces', price: 40000),
    _DemenagementOption(id: 'aides_manutention', title: 'Aides à la manutention', subtitle: 'Porteurs supplémentaires', price: 5000),
  ];

  @override
  void dispose() {
    _volumeController.dispose();
    _floorFromController.dispose();
    _floorToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Service de déménagement"), backgroundColor: Colors.brown[700]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Choisissez le type de service", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._services.map((s) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: RadioListTile<String>(
                title: Text(s.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text("${s.subtitle} • ${s.price} XAF"),
                value: s.id,
                groupValue: _selectedService,
                onChanged: (v) => setState(() => _selectedService = v),
                activeColor: Colors.brown[700],
              ),
            )),
            const SizedBox(height: 24),
            const Text("Volume approximatif (m³) ou nombre de pièces", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _volumeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Ex: 20 m³ ou 3 pièces",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _floorFromController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Étage départ",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _floorToController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Étage arrivée",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text("Besoin d'aides à la manutention"),
              value: _needHelpers,
              onChanged: (v) => setState(() => _needHelpers = v),
              activeColor: Colors.brown[700],
            ),
            if (_needHelpers) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text("Nombre d'aides : "),
                  IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => setState(() => _helperCount = (_helperCount - 1).clamp(0, 10))),
                  Text("$_helperCount", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => _helperCount = (_helperCount + 1).clamp(0, 10))),
                ],
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedService == null ? null : () => _goToBooking(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.brown[700], padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("CONTINUER VERS L'ADRESSE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToBooking() {
    final option = _services.firstWhere((s) => s.id == _selectedService);
    var price = option.price.toDouble();
    if (_needHelpers && _helperCount > 0) {
      price += 5000 * _helperCount;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => BookingFlowScreen(
      initialCategory: 'Déménagement',
      demenagementDetails: {
        'service': _selectedService,
        'volume': _volumeController.text,
        'floor_from': _floorFromController.text,
        'floor_to': _floorToController.text,
        'helpers': _helperCount,
      },
      overridePrice: price,
    ))).then((_) => widget.onOrderPlaced());
  }
}

class _DemenagementOption {
  final String id;
  final String title;
  final String subtitle;
  final int price;
  const _DemenagementOption({required this.id, required this.title, required this.subtitle, required this.price});
}
