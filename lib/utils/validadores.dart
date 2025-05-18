String? validarNombre(String? value) {
  final regex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ ]+$');
  if (value == null || value.isEmpty) return 'El nombre es obligatorio';
  if (!regex.hasMatch(value)) return 'Solo se permiten letras';
  return null;
}

String? validarCorreo(String? value) {
  final regex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');
  if (value == null || value.isEmpty) return 'El correo es obligatorio';
  if (!regex.hasMatch(value)) return 'Correo no válido';
  return null;
}