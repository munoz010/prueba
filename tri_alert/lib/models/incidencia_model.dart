import 'package:cloud_firestore/cloud_firestore.dart';

class IncidenciaModel {
  final String id;
  final String tipo;
  final String titulo;
  final String descripcion;
  final String ubicacion;
  final String estado;
  final String? fotoUrl;      // imagen original (alta calidad)
  final String? fotoThumbUrl; // thumbnail (baja calidad, carga rápida)
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
    this.fotoThumbUrl,
  });

  factory IncidenciaModel.fromMap(Map<String, dynamic> map, String id) {
    return IncidenciaModel(
      id:           id,
      tipo:         map['tipo']         ?? '',
      titulo:       map['titulo']       ?? '',
      descripcion:  map['descripcion']  ?? '',
      ubicacion:    map['ubicacion']    ?? '',
      estado:       map['estado']       ?? 'Reportado',
      fotoUrl:      map['fotoUrl'],
      fotoThumbUrl: map['fotoThumbUrl'], // null en incidencias viejas → usa fotoUrl
      fecha:        (map['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      usuarioId:    map['usuarioId']    ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'tipo':         tipo,
    'titulo':       titulo,
    'descripcion':  descripcion,
    'ubicacion':    ubicacion,
    'estado':       estado,
    'fotoUrl':      fotoUrl,
    'fotoThumbUrl': fotoThumbUrl,
    'fecha':        Timestamp.fromDate(fecha),
    'usuarioId':    usuarioId,
  };

  IncidenciaModel copyWith({String? estado, String? fotoUrl, String? fotoThumbUrl}) {
    return IncidenciaModel(
      id:           id,
      tipo:         tipo,
      titulo:       titulo,
      descripcion:  descripcion,
      ubicacion:    ubicacion,
      estado:       estado       ?? this.estado,
      fotoUrl:      fotoUrl      ?? this.fotoUrl,
      fotoThumbUrl: fotoThumbUrl ?? this.fotoThumbUrl,
      fecha:        fecha,
      usuarioId:    usuarioId,
    );
  }
}
