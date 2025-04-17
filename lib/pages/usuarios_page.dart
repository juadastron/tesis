import '../core/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  Future<List<Map<String, dynamic>>> obtenerUsuarios() async {
    final response = await http.get(Uri.parse("${baseUrl}usuarios.php"));
    final data = jsonDecode(response.body);

    if (data['success'] == true) {
      return List<Map<String, dynamic>>.from(data['usuarios']);
    } else {
      throw Exception(data['message'] ?? 'Error al cargar usuarios');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios Registrados'),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: obtenerUsuarios(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final usuarios = snapshot.data!;

            if (usuarios.isEmpty) {
              return const Center(child: Text('No hay usuarios registrados.'));
            }

            return ListView.builder(
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final usuario = usuarios[index];
                return ListTile(
                  title: Text(usuario['nombre']),
                  subtitle: Text('${usuario['email']} | Rol: ${usuario['rol']}'),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () {
                          // Aquí iría editar
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Aquí iría eliminar
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6A1B9A),
        onPressed: () {
          // Aquí iría la función para agregar nuevo usuario
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
