import SwiftUI
import FirebaseAuth

struct LoginView: View {
    // Variables de estado para manejar la entrada del usuario y el flujo de la vista
    @State private var email: String = "" // Almacena el correo ingresado
    @State private var password: String = "" // Almacena la contraseña ingresada
    @State private var errorMessage: String = "" // Muestra mensajes de error en la interfaz
    @State private var isLoggingIn: Bool = false // Indica si se está procesando el inicio de sesión
    @State private var isLoggedIn: Bool = false // Controla la navegación a la vista SalaView

    let labelColor = Color(red: 0.05, green: 0.1, blue: 0.2) // Azul oscuro para las etiquetas de texto
    let textColor = Color.black // Color negro para el texto ingresado

    var body: some View {
        NavigationView {
            ZStack {
                // Fondo con gradiente azul oscuro y turquesa
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.05, green: 0.1, blue: 0.2), // Azul oscuro
                        Color(red: 0.1, green: 0.4, blue: 0.5)  // Turquesa
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer() // Espaciador para empujar el contenido hacia el centro

                    // Contenedor principal con fondo blanco sólido
                    VStack(spacing: 19) {
                        // Imagen de perfil
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80) // Tamaño más pequeño del icono
                            .foregroundColor(.black) // Cambiar color del icono a negro
                            .padding(.top, 20) // Menos espacio arriba para mover el icono más cerca del borde superior
                            
                        // Título de bienvenida
                        Text("Bienvenido a MealsApp")
                            .font(.title) // Tamaño de fuente reducido
                            .fontWeight(.bold)
                            .foregroundColor(.black) // Cambiar color a negro
                            .lineLimit(1) // Aseguramos que esté en una sola línea
                            .minimumScaleFactor(0.5) // Reduce el texto si es necesario para ajustarse al espacio
                            .padding(.top, 10) // Menos espacio entre el icono y el texto de bienvenida
                            .padding(.bottom, 40) // Espacio debajo del título para separar del formulario

                        // Contenedor del formulario
                        VStack(spacing: 16) {  // Reducido el espaciado entre campos
                            // Título para el correo electrónico
                            HStack {
                                Text("Correo electrónico")
                                    .fontWeight(.bold)
                                    .foregroundColor(labelColor)
                                    .padding(.leading, 02)
                                Spacer()
                            }

                            // Campo para ingresar el correo electrónico con línea abajo
                            ZStack {
                                TextField("", text: $email)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal)
                                    .foregroundColor(textColor)
                                    .font(.system(size: 18))
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .keyboardType(.emailAddress)
                                    .background(Color.clear)

                                // Línea debajo del campo
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(labelColor)
                                    .padding(.top, 20)
                            }

                            // Título para la contraseña
                            HStack {
                                Text("Contraseña")
                                    .fontWeight(.bold)
                                    .foregroundColor(labelColor)
                                    .padding(.leading, 02)
                                Spacer()
                            }

                            // Campo para ingresar la contraseña con línea abajo
                            ZStack {
                                SecureField("", text: $password)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal)
                                    .foregroundColor(textColor) // Cambiar color de texto a negro
                                    .font(.system(size: 18))
                                    .background(Color.clear)

                                // Línea debajo del campo
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(labelColor)
                                    .padding(.top, 20) // Posicionamos la línea más cerca del campo
                            }
                        }
                        .padding(.horizontal)

                        // Mensaje de error visible si ocurre un problema
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }

                        // Botón para iniciar sesión con color más oscuro que el fondo
                        Button(action: loginUser) {
                            Text(isLoggingIn ? "Iniciando sesión..." : "Iniciar sesión")
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 0.05, green: 0.1, blue: 0.2)) // Color más oscuro que el fondo
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        .disabled(isLoggingIn || email.isEmpty || password.isEmpty)

                        // Enlace para olvidar la contraseña, con color azul oscuro
                        HStack {
                            // Colocamos "Olvidaste tu contraseña?" junto a "Registrarse"
                            NavigationLink("¿Olvidaste tu contraseña?", destination: Text("Pantalla para recuperación"))
                                .fontWeight(.bold)
                                .foregroundColor(labelColor) // Azul oscuro para el texto

                            Spacer()

                            NavigationLink("Registrarse", destination: RegisterView())
                                .fontWeight(.bold)
                                .foregroundColor(.pink)
                        }
                        .padding(.top, 10)

                    }
                    .padding()
                    .background(
                        Color.white
                    )
                    .cornerRadius(20) // Bordes redondeados
                    .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: 15) // Sombra más fuerte y grande
                    .padding(.horizontal, 20)
                    .padding(.top, 40) // Se le da un pequeño espacio hacia abajo para separar del borde superior

                    Spacer() // Espaciador para empujar el contenido hacia el centro
                }
            }
        }
    }

    // Función para iniciar sesión
    private func loginUser() {
        // Valida que los campos no estén vacíos
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor, ingresa tu correo y contraseña."
            return
        }

        isLoggingIn = true
        errorMessage = ""

        // Llamada a Firebase para autenticar al usuario
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoggingIn = false

            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isLoggedIn = true
                print("Usuario inició sesión: \(String(describing: result?.user.email))")
            }
        }
    }
}

#Preview {
    LoginView()
}
