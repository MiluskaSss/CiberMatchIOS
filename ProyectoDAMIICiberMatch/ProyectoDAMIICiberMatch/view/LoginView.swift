import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var isLoggingIn: Bool = false
    @State private var isLoggedIn: Bool = false // Nueva propiedad para manejar la navegación

    private var isEmailValid: Bool {
        email.contains("@") && email.contains(".")
    }

    private var isPasswordValid: Bool {
        password.count >= 6
    }

    var body: some View {
        ZStack {
            // Fondo con gradiente neón combinando azul marino, azul y negro
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#001f3d"), Color(hex: "#0066cc"), Color(hex: "#000000")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer() // Empuja el contenido hacia abajo

                // Caja principal con fondo y bordes redondeados (centrada)
                VStack(spacing: 20) {
                    // Título centrado y colocado más abajo, ahora a la altura del campo de correo
                    VStack {
                        Text("¡Bienvenido a CineMatch!")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .shadow(radius: 10) // Sombra para dar un toque neón
                        
                        // Ícono relacionado con película en color amarillo
                        Image(systemName: "film.fill") // Ícono relacionado con película
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80) // Aumentamos el tamaño del ícono
                            .foregroundColor(.yellow) // Ícono amarillo brillante
                    }
                    .padding(.bottom, 40) // Separar más de los campos de texto

                    // Caja para los campos de texto (correo y contraseña)
                    VStack(spacing: 15) {
                        // Campo para correo
                        ZStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "envelope.fill") // Ícono de correo
                                    .foregroundColor(Color(hex: "#1A1A1A")) // Ícono más oscuro
                                    .font(.system(size: 24)) // Ajustamos el tamaño del ícono
                                    .padding(.leading, 16)
                                Spacer()
                            }
                            .frame(height: 50)

                            TextField("Correo electrónico", text: $email)
                                .padding(.leading, 40) // Espacio para el ícono
                                .padding()
                                .background(Color.white.opacity(0.8)) // Fondo blanco con opacidad
                                .cornerRadius(12)
                                .foregroundColor(.black)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .keyboardType(.emailAddress)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )
                                .shadow(color: Color.blue.opacity(0.6), radius: 8, x: 0, y: 0) // Sombra neón
                        }

                        // Campo para contraseña
                        ZStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "lock.fill") // Ícono de candado
                                    .foregroundColor(Color(hex: "#1A1A1A")) // Ícono más oscuro
                                    .font(.system(size: 24)) // Ajustamos el tamaño del ícono
                                    .padding(.leading, 16)
                                Spacer()
                            }
                            .frame(height: 50)

                            SecureField("Contraseña", text: $password)
                                .padding(.leading, 40) // Espacio para el ícono
                                .padding()
                                .background(Color.white.opacity(0.8)) // Fondo blanco con opacidad
                                .cornerRadius(12)
                                .foregroundColor(.black)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )
                                .shadow(color: Color.blue.opacity(0.6), radius: 8, x: 0, y: 0) // Sombra neón
                        }

                        // Mensaje de error
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(Color(hex: "#FF4C61")) // Rojo claro para errores
                                .fontWeight(.bold)
                        }

                        // Botón de inicio de sesión
                        Button(action: loginUser) {
                            Text(isLoggingIn ? "Iniciando sesión..." : "Iniciar sesión")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    isEmailValid && isPasswordValid ? Color(hex: "#0028ff") : Color(hex: "#0028ff")
                                )
                                .cornerRadius(12)
                                .foregroundColor(.white)
                                .shadow(radius: 10)
                                .scaleEffect(isLoggingIn ? 0.95 : 1)
                                .animation(.easeInOut(duration: 0.2), value: isLoggingIn)
                                .opacity(isEmailValid && isPasswordValid ? 1.0 : 0.7)
                                .padding(.top, 20)
                        }
                        .disabled(!isEmailValid || !isPasswordValid || isLoggingIn)
                    }

                    // Opción para registrarse
                    HStack {
                        Text("¿No tienes cuenta?")
                            .foregroundColor(.white)
                            .font(.subheadline)
                        NavigationLink(
                            destination: RegisterView(),
                            label: {
                                Text("Registrarse")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: "#0028ff")) // Color ligeramente más claro
                                    .padding(.top, 8) // Espaciado superior para que no se vea tan pegado
                            })
                    }
                }
                .padding() // Relleno alrededor de los campos de texto y botones
                .background(Color.white.opacity(0.85)) // Fondo blanco semi-transparente para los campos
                .cornerRadius(16)
                .shadow(radius: 10) // Sombra para darle un efecto de profundidad
                .frame(maxWidth: 400) // Limitar el ancho del contenedor (opcional)

                Spacer() // Empuja el contenido hacia arriba
            }
            .padding(.horizontal, 20)
            .frame(maxHeight: .infinity, alignment: .center) // Centrar el contenido verticalmente
        }
        .navigationBarBackButtonHidden(true) // Ocultar el botón de retroceso en LoginView
    }

    private func loginUser() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor, ingresa tu correo y contraseña."
            return
        }

        guard isEmailValid else {
            errorMessage = "Por favor, ingresa un correo electrónico válido."
            return
        }

        guard isPasswordValid else {
            errorMessage = "La contraseña debe tener al menos 6 caracteres."
            return
        }

        isLoggingIn = true
        errorMessage = ""

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoggingIn = false

            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isLoggedIn = true // Cambiamos el estado a true cuando el login es exitoso
                print("Usuario inició sesión: \(String(describing: result?.user.email))")
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 1 // Omitir el símbolo "#"
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let red = Double((rgbValue >> 16) & 0xFF) / 255.0
        let green = Double((rgbValue >> 8) & 0xFF) / 255.0
        let blue = Double(rgbValue & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}

#Preview {
    LoginView()
}

