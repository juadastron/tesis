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

String? validarNumeros(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Campo requerido';
  }

  final numero = int.tryParse(value);
  if (numero == null || numero < 0) {
    return 'Debe contener solo números válidos';
  }

  return null; // ✅ Todo bien
}
String? validarIMEI(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Campo requerido';
  }

  if (!RegExp(r'^\d{15}$').hasMatch(value)) {
    return 'El IMEI debe tener exactamente 15 dígitos';
  }

  if (!_verificarLuhn(value)) {
    return 'IMEI inválido';
  }

  return null;
}

// Algoritmo de Luhn para validar IMEI
bool _verificarLuhn(String imei) {
  int sum = 0;
  for (int i = 0; i < 15; i++) {
    int digit = int.parse(imei[14 - i]);
    if (i % 2 == 1) {
      digit *= 2;
      if (digit > 9) digit -= 9;
    }
    sum += digit;
  }
  return sum % 10 == 0;
}


String? validarNumeroCelularEcuador(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Campo requerido';
  }

  final regex = RegExp(r'^09\d{8}$');
  if (!regex.hasMatch(value)) {
    return 'Número de celular no válido';
  }

  final prefijosValidos = {
    '099', '098', '096', // Claro
    '095', '094',        // Movistar
    '093', '092'         // CNT
  };

  final prefijo = value.substring(0, 3);
  if (!prefijosValidos.contains(prefijo)) {
    return 'Prefijo no válido para Ecuador';
  }

  return null; // ✅ Válido
}
