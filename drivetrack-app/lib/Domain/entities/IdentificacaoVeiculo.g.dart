// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'IdentificacaoVeiculo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IdentificacaoVeiculoAdapter extends TypeAdapter<IdentificacaoVeiculo> {
  @override
  final int typeId = 4;

  @override
  IdentificacaoVeiculo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IdentificacaoVeiculo(
      nome: fields[0] as String,
      placa: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, IdentificacaoVeiculo obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.nome)
      ..writeByte(1)
      ..write(obj.placa);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdentificacaoVeiculoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
