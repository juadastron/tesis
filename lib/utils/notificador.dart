import 'package:flutter/material.dart';

enum TipoNotificacion { success, error, alerta }

class Notificador {
  static void mostrar({
    required BuildContext context,
    required String mensaje,
    required TipoNotificacion tipo,
  }) {
    final Color colorFondo;
    final IconData icono;

    switch (tipo) {
      case TipoNotificacion.success:
        colorFondo = const Color(0xFF4CAF50); // Verde
        icono = Icons.check_circle;
        break;
      case TipoNotificacion.error:
        colorFondo = const Color(0xFFF44336); // Rojo
        icono = Icons.error;
        break;
      case TipoNotificacion.alerta:
        colorFondo = const Color(0xFFFFC107); // Amarillo
        icono = Icons.warning;
        break;
    }

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 30,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: colorFondo,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icono, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    mensaje,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(milliseconds: 1500), () {
      overlayEntry.remove();
    });
  }
}
