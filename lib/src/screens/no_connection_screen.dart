import 'package:climapp_cc20262/src/controller/list_city_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Tela exibida quando ocorre um erro de conexão durante o carregamento
/// das cidades em [ListCityController.loadCities].
///
/// Apresenta uma mensagem de erro amigável e um botão que aciona
/// [ListCityController.loadCities] para nova tentativa de conexão.
class NoConnectionScreen extends StatelessWidget {
  const NoConnectionScreen({super.key});

  // ── Constantes de estilo ────────────────────────────────────────────────────

  static const _gradientColors = <Color>[Color(0xFF00457D), Color(0xFF05051F)];
  static const _buttonColor = Color(0xFF7693FF);
  static const _iconColor = Color(0xFFADC4FF);
  static const _iconSize = 96.0;
  static const _titleFontSize = 22.0;
  static const _bodyFontSize = 15.0;
  static const _spacingSmall = 12.0;
  static const _spacingMedium = 24.0;
  static const _spacingLarge = 40.0;

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: _gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIcon(),
                  const SizedBox(height: _spacingLarge),
                  _buildTitle(),
                  const SizedBox(height: _spacingSmall),
                  _buildErrorMessage(context),
                  const SizedBox(height: _spacingMedium),
                  _buildHint(),
                  const SizedBox(height: _spacingLarge),
                  _buildRetryButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Widgets privados ────────────────────────────────────────────────────────

  Widget _buildIcon() {
    return const Icon(
      Icons.wifi_off_rounded,
      size: _iconSize,
      color: _iconColor,
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Sem conexão',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: _titleFontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Exibe a mensagem de erro vinda do controller, quando disponível.
  Widget _buildErrorMessage(BuildContext context) {
    final errorMessage =
        context.select<ListCityController, String>((c) => c.errorMessage);

    if (errorMessage.isEmpty) return const SizedBox.shrink();

    return Text(
      errorMessage,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: _bodyFontSize,
      ),
    );
  }

  Widget _buildHint() {
    return const Text(
      'Verifique sua conexão com a internet e tente novamente.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white54,
        fontSize: _bodyFontSize,
      ),
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _onRetryPressed(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: _buttonColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: _bodyFontSize + 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Tentar novamente'),
      ),
    );
  }

  // ── Handlers ─────────────────────────────────────────────────────────────────

  /// Dispara nova tentativa de carregamento das cidades.
  Future<void> _onRetryPressed(BuildContext context) async {
    final controller = context.read<ListCityController>();
    await controller.loadCities();
  }
}
