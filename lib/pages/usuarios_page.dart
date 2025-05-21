import 'package:flutter/material.dart';
import '../services/usuarios_service.dart';
import '../models/usuario_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/notificador.dart';
import '../utils/validadores.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

/// Animación con ScaleTransition para mostrar el dialog
Future<Future<Object?>> showAnimatedDialog({
  required BuildContext context,
  required Widget child,
}) async {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (context, anim1, anim2, _) {
      final curvedValue = Curves.easeInOut.transform(anim1.value);
      return Transform.scale(
        scale: curvedValue,
        child: Opacity(opacity: anim1.value, child: child),
      );
    },
  );
}

void editarUsuarioModal(
  BuildContext context,
  Usuario usuario,
  VoidCallback onUpdate,
) {
  final formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController(text: usuario.nombre);
  final emailController = TextEditingController(text: usuario.email);
  final rolController = TextEditingController(text: usuario.rol);

  showAnimatedDialog(
    context: context,
    child: Dialog(
      backgroundColor: const Color(0xFFF5F0FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 32,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: formKey,
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

              // Campo: Nombre
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFF4EFFA),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: nombreController,
                  validator: validarNombre,
                  decoration: InputDecoration(
                    labelText: "Nombre",
                    prefixIcon: Icon(
                      Icons.person,
                      color: Color.fromARGB(255, 70, 117, 192),
                    ),
                    labelStyle: GoogleFonts.montserrat(),
                    border: InputBorder.none,
                  ),
                ),
              ),

              // Campo: Email
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFF4EFFA),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: emailController,
                  validator: validarCorreo,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email, color: Color(0xFF6A1B9A)),
                    labelStyle: GoogleFonts.montserrat(),
                    border: InputBorder.none,
                  ),
                ),
              ),

              // Campo: Rol
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFF4EFFA),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value:
                      rolController.text.isNotEmpty ? rolController.text : null,
                  decoration: InputDecoration(
                    labelText: "Rol",
                    prefixIcon: Icon(
                      Icons.security,
                      color: Color.fromARGB(255, 70, 117, 192),
                    ),
                    labelStyle: GoogleFonts.montserrat(),
                    border: InputBorder.none,
                  ),
                  style: GoogleFonts.montserrat(color: Colors.black),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(
                      value: 'voluntario',
                      child: Text('Voluntario'),
                    ),
                  ],
                  onChanged: (value) => rolController.text = value!,
                ),
              ),

              // Botones
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
                      if (!formKey.currentState!.validate()) return;
                      final actualizado = await actualizarUsuario(
                        Usuario(
                          id: usuario.id,
                          nombre: nombreController.text,
                          email: emailController.text,
                          rol: rolController.text,
                        ),
                      );
                      if (actualizado) {
                        final userProvider = Provider.of<UserProvider>(
                          context,
                          listen: false,
                        );
                        if (usuario.id == userProvider.idUsuario) {
                          userProvider.setUser(
                            idUsuario: usuario.id!,
                            nombre: nombreController.text,
                            email: emailController.text,
                            rol: rolController.text,
                          );
                        }
                        Navigator.pop(context);
                        onUpdate();
                        Future.delayed(const Duration(milliseconds: 100), () {
                          Notificador.mostrar(
                            context: context,
                            mensaje: "Perfil actualizado correctamente",
                            tipo: TipoNotificacion.success,
                          );
                        });
                      } else {
                        FocusScope.of(context).unfocus();
                        Notificador.mostrar(
                          context: context,
                          mensaje: "Correo ya en uso por otro usuario",
                          tipo: TipoNotificacion.error,
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
      ),
    ),
  );
}

void mostrarFormularioNuevoUsuario(BuildContext context, VoidCallback onCrear) {
  final formKey = GlobalKey<FormState>();
  bool verPassword = false;
  final nombreController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final rolController = TextEditingController();

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (context, anim1, anim2, _) {
      final curvedValue = Curves.easeInOut.transform(anim1.value);
      return Transform.scale(
        scale: curvedValue,
        child: Opacity(
          opacity: anim1.value,
          child: Dialog(
            backgroundColor: const Color(0xFFF5F0FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: formKey,
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

                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFF4EFFA),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: nombreController,
                        validator: validarNombre,
                        decoration: InputDecoration(
                          labelText: "Nombre",
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Color.fromARGB(255, 70, 117, 192),
                          ),
                          labelStyle: GoogleFonts.montserrat(),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFF4EFFA),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: emailController,
                        validator: validarCorreo,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Color(0xFF6A1B9A),
                          ),
                          labelStyle: GoogleFonts.montserrat(),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFF4EFFA),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: !verPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La contraseña es obligatoria';
                          }
                          if (value.length < 6) {
                            return 'Debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Contraseña",
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.amber,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              verPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Color(0xFF6A1B9A),
                            ),
                            onPressed: () {
                              verPassword = !verPassword;
                              (context as Element).markNeedsBuild();
                            },
                          ),
                          labelStyle: GoogleFonts.montserrat(),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFF4EFFA),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Rol",
                          prefixIcon: const Icon(
                            Icons.security,
                            color: Color.fromARGB(255, 70, 117, 192),
                          ),
                          labelStyle: GoogleFonts.montserrat(),
                          border: InputBorder.none,
                        ),
                        style: GoogleFonts.montserrat(color: Colors.black),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Selecciona un rol'
                                    : null,
                        items: const [
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                          DropdownMenuItem(
                            value: 'voluntario',
                            child: Text('Voluntario'),
                          ),
                        ],
                        onChanged: (value) {
                          rolController.text = value!;
                        },
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancelar',
                            style: GoogleFonts.montserrat(
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            FocusScope.of(context).unfocus();
                            final creado = await crearUsuario(
                              Usuario(
                                nombre: nombreController.text,
                                email: emailController.text,
                                password: passwordController.text,
                                rol: rolController.text,
                              ),
                            );

                            if (creado) {
                              Navigator.pop(context);
                              onCrear();
                              Future.delayed(
                                const Duration(milliseconds: 100),
                                () {
                                  Notificador.mostrar(
                                    context: context,
                                    mensaje: "Usuario creado exitosamente",
                                    tipo: TipoNotificacion.success,
                                  );
                                },
                              );
                            } else {
                              Notificador.mostrar(
                                context: context,
                                mensaje: "Correo ya en uso",
                                tipo: TipoNotificacion.error,
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
            ),
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
    final idUsuarioLogueado = Provider.of<UserProvider>(context).idUsuario;
    final listaVisible =
        usuariosFiltrados
            .where((usuario) => usuario.id != idUsuarioLogueado)
            .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Usuarios Registrados',
          style: GoogleFonts.montserrat(color: const Color(0xFF6A1B9A)),
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
                      itemCount: listaVisible.length,
                      itemBuilder: (context, index) {
                        final usuario = listaVisible[index];
                        return ListTile(
                          title: Text(
                            usuario.nombre,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.email,
                                    size: 16,
                                    color: Colors.deepPurple,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    usuario.email,
                                    style: GoogleFonts.montserrat(fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_pin,
                                    size: 16,
                                    color: Colors.indigo,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Rol: ${usuario.rol}',
                                    style: GoogleFonts.montserrat(fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
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
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromRGBO(
                                                      244,
                                                      67,
                                                      54,
                                                      1,
                                                    ),
                                              ),
                                              onPressed:
                                                  () =>
                                                      Navigator.pop(ctx, true),
                                              child: Text(
                                                'Eliminar',
                                                style: GoogleFonts.montserrat(
                                                  color: Colors.white,
                                                ),
                                              ),
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
                                      Notificador.mostrar(
                                        context: context,
                                        mensaje: "Usuario eliminado",
                                        tipo: TipoNotificacion.success,
                                      );
                                    } else {
                                      Notificador.mostrar(
                                        context: context,
                                        mensaje: "Error al eliminar el usuario",
                                        tipo: TipoNotificacion.error,
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
