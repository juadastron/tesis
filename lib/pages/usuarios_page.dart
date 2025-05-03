import '../core/config.dart';
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
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Editar Usuario', style: GoogleFonts.montserrat()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    labelText: "Nombre",
                    labelStyle: GoogleFonts.montserrat(), // 👈
                  ),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: GoogleFonts.montserrat(), // 👈
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: null, // o `rolController.text` si es edición
                  decoration: InputDecoration(
                    labelText: "Rol",
                    labelStyle: GoogleFonts.montserrat(),
                  ),
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.black,
                  ),
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
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar', style: GoogleFonts.montserrat()),
              ),
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
                child: Text("Guardar", style: GoogleFonts.montserrat()),
              ),
            ],
          );
        },
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
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Nuevo Usuario', style: GoogleFonts.montserrat()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    labelText: "Nombre",
                    labelStyle: GoogleFonts.montserrat(), // 👈
                  ),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: GoogleFonts.montserrat(), // 👈
                  ),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    labelStyle: GoogleFonts.montserrat(), // 👈
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: null, 
                  decoration: InputDecoration(
                    labelText: "Rol",
                    labelStyle: GoogleFonts.montserrat(),
                  ),
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.black,
                  ),
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
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancelar', style: GoogleFonts.montserrat()),
              ),
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
                child: Text("Guardar", style: GoogleFonts.montserrat()),
              ),
            ],
          );
        },
      );
    },
  );
}

class _UsuariosPageState extends State<UsuariosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios Registrados' , style: GoogleFonts.montserrat(
          color: const Color.fromARGB(255, 255, 255, 255),
        )),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
      body: FutureBuilder<List<Usuario>>(
        future: obtenerUsuarios(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: GoogleFonts.montserrat()));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay usuarios registrados.', style: GoogleFonts.montserrat()));
          }

          final usuarios = snapshot.data!;

          return ListView.builder(
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final usuario = usuarios[index];
              return ListTile(
                title: Text(usuario.nombre, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                subtitle: Text('${usuario.email} | Rol: ${usuario.rol}', style: GoogleFonts.montserrat()),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () {
                        editarUsuarioModal(context, usuario, () {
                          setState(() {});
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
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
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                        );

                        if (confirm == true) {
                          final eliminado = await eliminarUsuario(usuario.id!);
                          if (eliminado) {
                            setState(() {});
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6A1B9A),
        onPressed: () {
          mostrarFormularioNuevoUsuario(context, () {
            setState(() {});
          });
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
