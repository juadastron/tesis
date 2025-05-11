import 'package:flutter/material.dart';
import '../services/usuarios_service.dart';
import '../models/usuario_model.dart';
import 'package:google_fonts/google_fonts.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

void editarUsuarioModal(
  BuildContext context,
  Usuario usuario,
  VoidCallback onUpdate,
) {
  final nombreController = TextEditingController(text: usuario.nombre);
  final emailController = TextEditingController(text: usuario.email);
  final rolController = TextEditingController(text: usuario.rol);

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: const Color(0xFFF5F0FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Editar Usuario',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: "Nombre",
                  labelStyle: GoogleFonts.montserrat(),
                ),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: GoogleFonts.montserrat(),
                ),
              ),
              DropdownButtonFormField<String>(
                value:
                    rolController.text.isNotEmpty ? rolController.text : null,
                decoration: InputDecoration(
                  labelText: "Rol",
                  labelStyle: GoogleFonts.montserrat(),
                ),
                style: GoogleFonts.montserrat(color: Colors.black),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(
                    value: 'voluntario',
                    child: Text('Voluntario'),
                  ),
                ],
                onChanged: (value) {
                  rolController.text = value!;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.montserrat(color: Colors.deepPurple),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final actualizado = await actualizarUsuario(
                        Usuario(
                          id: usuario.id,
                          nombre: nombreController.text,
                          email: emailController.text,
                          rol: rolController.text,
                        ),
                      );

                      if (actualizado) {
                        Navigator.pop(context);
                        onUpdate();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Error al actualizar",
                              style: GoogleFonts.montserrat(),
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Guardar",
                      style: GoogleFonts.montserrat(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void mostrarFormularioNuevoUsuario(BuildContext context, VoidCallback onCrear) {
  final nombreController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final rolController = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) {
      return Dialog(
        backgroundColor: const Color(0xFFF5F0FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nuevo Usuario',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: "Nombre",
                  labelStyle: GoogleFonts.montserrat(),
                ),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: GoogleFonts.montserrat(),
                ),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  labelStyle: GoogleFonts.montserrat(),
                ),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Rol",
                  labelStyle: GoogleFonts.montserrat(),
                ),
                style: GoogleFonts.montserrat(color: Colors.black),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(
                    value: 'voluntario',
                    child: Text('Voluntario'),
                  ),
                ],
                onChanged: (value) {
                  rolController.text = value!;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.montserrat(color: Colors.deepPurple),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final creado = await crearUsuario(
                        Usuario(
                          nombre: nombreController.text,
                          email: emailController.text,
                          password: passwordController.text,
                          rol: rolController.text,
                        ),
                      );

                      if (creado) {
                        Navigator.pop(ctx);
                        onCrear();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Error al crear",
                              style: GoogleFonts.montserrat(),
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Guardar",
                      style: GoogleFonts.montserrat(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _UsuariosPageState extends State<UsuariosPage> {
  List<Usuario> todosLosUsuarios = [];
  List<Usuario> usuariosFiltrados = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  Future<void> cargarUsuarios() async {
    final lista = await obtenerUsuarios();
    setState(() {
      todosLosUsuarios = lista;
      usuariosFiltrados = lista;
    });
  }

  void filtrarUsuarios(String query) {
    final filtrados =
        todosLosUsuarios.where((usuario) {
          final nombreUsuario = usuario.nombre.toLowerCase();
          final input = query.toLowerCase();
          return nombreUsuario.contains(input);
        }).toList();

    setState(() {
      usuariosFiltrados = filtrados;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Usuarios Registrados',
          style: GoogleFonts.montserrat(
            color: const Color(0xFF6A1B9A),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: filtrarUsuarios,
              style: GoogleFonts.montserrat(),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre...',
                hintStyle: GoogleFonts.montserrat(),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 20.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.deepPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(
                    color: Colors.deepPurple,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child:
                usuariosFiltrados.isEmpty
                    ? Center(
                      child: Text(
                        'No hay usuarios registrados.',
                        style: GoogleFonts.montserrat(),
                      ),
                    )
                    : ListView.builder(
                      itemCount: usuariosFiltrados.length,
                      itemBuilder: (context, index) {
                        final usuario = usuariosFiltrados[index];
                        return ListTile(
                          title: Text(
                            usuario.nombre,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${usuario.email} | Rol: ${usuario.rol}',
                            style: GoogleFonts.montserrat(),
                          ),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                onPressed: () {
                                  editarUsuarioModal(context, usuario, () {
                                    cargarUsuarios();
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (ctx) => AlertDialog(
                                          title: const Text('Confirmar'),
                                          content: const Text(
                                            '¿Deseas eliminar este usuario?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () =>
                                                      Navigator.pop(ctx, false),
                                              child: const Text('Cancelar'),
                                            ),
                                            ElevatedButton(
                                              onPressed:
                                                  () =>
                                                      Navigator.pop(ctx, true),
                                              child: const Text('Eliminar'),
                                            ),
                                          ],
                                        ),
                                  );

                                  if (confirm == true) {
                                    final eliminado = await eliminarUsuario(
                                      usuario.id!,
                                    );
                                    if (eliminado) {
                                      cargarUsuarios();
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Error al eliminar"),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6A1B9A),
        onPressed: () {
          mostrarFormularioNuevoUsuario(context, () {
            cargarUsuarios();
          });
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
