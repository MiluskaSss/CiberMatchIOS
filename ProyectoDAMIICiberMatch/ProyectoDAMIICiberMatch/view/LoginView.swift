import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var isLoggingIn: Bool = false
    @State private var isLoggedIn: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("¡Bienvenido de nuevo!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // Campo de correo electrónico
                TextField("Correo electrónico", text: $email)
                    .padding()
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)

                // Campo de contraseña
                SecureField("Contraseña", text: $password)
                    .padding()

                // Mensaje de error
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                // Botón para iniciar sesión
                Button(action: loginUser) {
                    Text(isLoggingIn ? "Iniciando sesión..." : "Iniciar Sesión")
                }
                .disabled(isLoggingIn || email.isEmpty || password.isEmpty)

                // Redirección si el usuario inicia sesión
                NavigationLink(
                    destination: SalaView()
                        .navigationBarBackButtonHidden(true), // Oculta la flecha de regreso
                    isActive: $isLoggedIn
                ) {
                    EmptyView()
                }

                // Opción de redirección a la vista de registro
                HStack {
                    Text("¿No tienes cuenta?")
                    NavigationLink("Registrarse", destination: RegisterView()) // Aquí agregamos el enlace a la vista de registro
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }

                Spacer()
            }
            .padding()
        }
    }
    private func loginUser() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor, ingresa tu correo y contraseña."
            return
        }
        isLoggingIn = true
        errorMessage = ""

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoggingIn = false

            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isLoggedIn = true // Esto activa la navegación a SalaView
                print("Usuario inició sesión: \(String(describing: result?.user.email))")
            }
        }
    }
}

#Preview {
    LoginView()
}
