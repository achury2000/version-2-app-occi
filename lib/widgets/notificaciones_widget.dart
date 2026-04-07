import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notificaciones_provider.dart';
import '../models/notificacion.dart';

/// Widget que muestra las notificaciones en la pantalla
/// Debe colocarse en el nivel superior de la app para máxima cobertura
class NotificacionesWidget extends StatelessWidget {
  final Widget child;

  const NotificacionesWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Consumer<NotificacionesProvider>(
            builder: (context, provider, _) {
              return Column(
                children: provider.notificaciones
                    .map((notif) => _NotificacionCard(notificacion: notif))
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Card individual de notificación con animación
class _NotificacionCard extends StatefulWidget {
  final Notificacion notificacion;

  const _NotificacionCard({
    Key? key,
    required this.notificacion,
  }) : super(key: key);

  @override
  State<_NotificacionCard> createState() => _NotificacionCardState();
}

class _NotificacionCardState extends State<_NotificacionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: () => context
              .read<NotificacionesProvider>()
              .removerNotificacion(widget.notificacion.id),
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              context
                  .read<NotificacionesProvider>()
                  .removerNotificacion(widget.notificacion.id);
            }
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            decoration: BoxDecoration(
              color: widget.notificacion.color.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: widget.notificacion.color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    widget.notificacion.icono,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.notificacion.titulo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.notificacion.mensaje,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => context
                        .read<NotificacionesProvider>()
                        .removerNotificacion(widget.notificacion.id),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
