import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:anotherrunner/l10n/app_localizations.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  // Função para abrir os links no navegador ou app de e-mail
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Não foi possível abrir o link: $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.credits),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Puxa a sua foto de perfil do GitHub automaticamente
              const CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage('https://github.com/matheussilvagarcia.png'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Matheus Silva Garcia',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.developedBy,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48),

              // Botão de E-mail
              _buildLinkButton(
                icon: Icons.email,
                label: l10n.contactMe,
                onPressed: () => _launchUrl('mailto:email@matheussilvagarcia.com'),
              ),
              const SizedBox(height: 16),

              // Botão do GitHub
              _buildLinkButton(
                icon: Icons.code,
                label: l10n.githubProfile,
                onPressed: () => _launchUrl('https://github.com/matheussilvagarcia'),
              ),
              const SizedBox(height: 16),

              // Botão do Portfólio
              _buildLinkButton(
                icon: Icons.language,
                label: l10n.visitPortfolio,
                onPressed: () => _launchUrl('https://matheussilvagarcia.com/'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget reaproveitável para criar os botões com o mesmo padrão visual
  Widget _buildLinkButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}