import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/reserva.dart';

class ComprobanteReservaScreen extends StatefulWidget {
  final Reserva reserva;

  const ComprobanteReservaScreen({
    Key? key,
    required this.reserva,
  }) : super(key: key);

  @override
  State<ComprobanteReservaScreen> createState() =>
      _ComprobanteReservaScreenState();
}

class _ComprobanteReservaScreenState extends State<ComprobanteReservaScreen> {
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comprobante de Reserva'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Descarga de PDF - Próximamente'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Compartir - Próximamente'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Encabezado con logo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 48),
                    const SizedBox(height: 8),
                    const Text(
                      'OCCITOURS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Comprobante de Reserva',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Número de reserva
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reserva #',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    widget.reserva.id.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(),

              // Fecha
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fecha de Reserva:',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  Text(
                    widget.reserva.fechaReserva != null
                        ? dateFormat.format(widget.reserva.fechaReserva!)
                        : 'N/A',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Información de la actividad
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ACTIVIDAD',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.event, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Actividad: ${widget.reserva.nombreCliente ?? 'N/A'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fecha: ${widget.reserva.fechaInicio != null ? dateFormat.format(widget.reserva.fechaInicio!) : 'N/A'}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (widget.reserva.fechaFin != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Hasta: ${dateFormat.format(widget.reserva.fechaFin!)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Detalles
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'DETALLES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildDetalle('Cantidad de Personas',
                  '${widget.reserva.cantidadPersonas ?? 0}'),
              _buildDetalle('Precio Unitario',
                  '\$${(widget.reserva.precioPorPersona ?? 0).toStringAsFixed(2)}'),
              _buildDetalle('Método de Pago',
                  widget.reserva.metodoPago ?? 'No especificado'),
              _buildDetalle('Estado de Pago',
                  widget.reserva.estadoPago ?? 'Pendiente'),
              if (widget.reserva.observaciones != null &&
                  widget.reserva.observaciones!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetalle('Observaciones', widget.reserva.observaciones!),
              ],
              const Divider(height: 24),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${(widget.reserva.precioTotal ?? 0).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Estado
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getColorEstado(widget.reserva.estado ?? '').withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getColorEstado(widget.reserva.estado ?? ''),
                  ),
                ),
                child: Text(
                  'Estado: ${(widget.reserva.estado ?? 'desconocido').toUpperCase()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _getColorEstado(widget.reserva.estado ?? ''),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Pie de página
              const Text(
                'Gracias por tu confianza en Occitours',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'www.occitours.com | info@occitours.com',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Volver'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetalle(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'confirmada':
      case 'completada':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
