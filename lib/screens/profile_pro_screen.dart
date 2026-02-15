import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'report_client_screen.dart';
import '../services/account_service.dart';

const _proCompanyKey = 'yadeli_pro_company';
const _proSiretKey = 'yadeli_pro_siret';
const _proAddressKey = 'yadeli_pro_address';

class ProfileProScreen extends StatefulWidget {
  const ProfileProScreen({super.key});

  @override
  State<ProfileProScreen> createState() => _ProfileProScreenState();
}

class _ProfileProScreenState extends State<ProfileProScreen> {
  final _companyController = TextEditingController();
  final _siretController = TextEditingController();
  final _addressController = TextEditingController();
  bool _hasProProfile = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _hasProProfile = await AccountService.hasProProfile();
    final prefs = await SharedPreferences.getInstance();
    _companyController.text = prefs.getString(_proCompanyKey) ?? '';
    _siretController.text = prefs.getString(_proSiretKey) ?? '';
    _addressController.text = prefs.getString(_proAddressKey) ?? '';
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _companyController.dispose();
    _siretController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil professionnel"), backgroundColor: Colors.green[700]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Facturation entreprise", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700])),
            const SizedBox(height: 8),
            const Text("Configurez vos informations professionnelles pour la facturation."),
            const SizedBox(height: 24),
            TextField(
              controller: _companyController,
              decoration: InputDecoration(
                labelText: "Nom de l'entreprise",
                prefixIcon: const Icon(Icons.business),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _siretController,
              decoration: InputDecoration(
                labelText: "N° SIRET / RC",
                prefixIcon: const Icon(Icons.badge),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: "Adresse de facturation",
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            const Divider(),
            const Text("Section professionnel", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.orange),
              title: const Text("Signaler un client"),
              subtitle: const Text("Comportement déplacé avec preuve (vidéo, audio, image)"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportClientScreen())),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_companyController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez remplir le nom de l'entreprise"), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating));
                    return;
                  }
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString(_proCompanyKey, _companyController.text);
                  await prefs.setString(_proSiretKey, _siretController.text);
                  await prefs.setString(_proAddressKey, _addressController.text);
                  await AccountService.setHasProProfile(true);
                  if (mounted) {
                    setState(() => _hasProProfile = true);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil professionnel enregistré"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Enregistrer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            if (_hasProProfile) ...[
              const SizedBox(height: 24),
              const Divider(),
              const Text("Supprimer le profil professionnel", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Cela supprimera uniquement votre profil professionnel (facturation entreprise). Votre compte client restera actif.", style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Supprimer le profil pro"),
                      content: const Text("Supprimer le profil professionnel ? Votre compte client ne sera pas affecté."),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Supprimer", style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (ok == true && mounted) {
                    await AccountService.deleteProProfile();
                    _companyController.clear();
                    _siretController.clear();
                    _addressController.clear();
                    setState(() => _hasProProfile = false);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil professionnel supprimé"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
                  }
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text("Supprimer le profil professionnel", style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
