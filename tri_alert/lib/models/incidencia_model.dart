import 'package:cloud_firestore/cloud_firestore.dart';

class IncidenciaModel {
  final String id;
  final String tipo;
  final String titulo;
  final String descripcion;
  final String ubicacion;
  final String estado; // 'Reportado' | 'En Progreso' | 'Resuelto'
  final String? fotoUrl;
  final DateTime fecha;
  final String usuarioId;

  const IncidenciaModel({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.ubicacion,
    required this.estado,
    required this.fecha,
    required this.usuarioId,
    this.fotoUrl,
  });

  factory IncidenciaModel.fromMap(Map<String, dynamic> map, String id) {
    return IncidenciaModel(
      id: id,
      tipo: map['tipo'] ?? '',
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      ubicacion: map['ubicacion'] ?? '',
      estado: map['estado'] ?? 'Reportado',
      fotoUrl: map['fotoUrl'],
      fecha: (map['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      usuarioId: map['usuarioId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'tipo': tipo,
        'titulo': titulo,
        'descripcion': descripcion,
        'ubicacion': ubicacion,
        'estado': estado,
        'fotoUrl': fotoUrl,
        'fecha': Timestamp.fromDate(fecha),
        'usuarioId': usuarioId,
      };

  IncidenciaModel copyWith({String? estado, String? fotoUrl}) {
    return IncidenciaModel(
      id: id,
      tipo: tipo,
      titulo: titulo,
      descripcion: descripcion,
      ubicacion: ubicacion,
      estado: estado ?? this.estado,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      fecha: fecha,
      usuarioId: usuarioId,
    );
  }
}
