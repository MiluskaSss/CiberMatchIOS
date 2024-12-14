import SwiftUI
import FirebaseAuth

struct LoginView: View {
    // Variables de estado para manejar la entrada del usuario y el flujo de la vista
    @State private var email: String = "" // Almacena el correo ingresado
    @State private var password: String = "" // Almacena la contraseña ingresada
    @State private var errorMessage: String = "" // Muestra mensajes de error en la interfaz
    @State private var isLoggingIn: Bool = false // Indica si se está procesando el inicio de sesión
    @State private var isLoggedIn: Bool = false // Controla la navegación a la vista SalaView

    var body: some View {
        NavigationView {
            ZStack {
                // Fondo con degradado de colores neón
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.2, green: 0.0, blue: 0.5), // Azul marino oscuro
                        Color(red: 0.4, green: 0.0, blue: 0.6), // Violeta
                        Color(red: 0.7, green: 0.0, blue: 0.5)  // Rosado medio oscuro
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    // Título de bienvenida
                    Text("¡Bienvenido de nuevo!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)

                    // Campo para ingresar el correo electrónico
                    TextField("Correo electrónico", text: $email)
                        .padding()
                        .background(Color.white.opacity(0.2)) // Fondo translúcido
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)

                    // Campo para ingresar la contraseña
                    SecureField("Contraseña", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.2)) // Fondo translúcido
                        .cornerRadius(8)
                        .foregroundColor(.white)

                    // Mensaje de error visible si ocurre un problema
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }

                    // Botón para iniciar sesión
                    Button(action: loginUser) {
                        Text(isLoggingIn ? "Iniciando sesión..." : "Iniciar Sesión")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    .disabled(isLoggingIn || email.isEmpty || password.isEmpty)

                    // Navegación automática a SalaView si el usuario inicia sesión
                    NavigationLink(
                        destination: SalaView()
                            .navigationBarBackButtonHidden(true),
                        isActive: $isLoggedIn
                    ) {
                        EmptyView()
                    }

                    // Opción para redirigir al registro si no tiene cuenta
                    HStack {
                        Text("¿No tienes cuenta?")
                            .foregroundColor(.white)
                        NavigationLink("Registrarse", destination: RegisterView())
                            .fontWeight(.bold)
                            .foregroundColor(.pink)
                    }

                    Spacer()
                }
                .padding()
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


