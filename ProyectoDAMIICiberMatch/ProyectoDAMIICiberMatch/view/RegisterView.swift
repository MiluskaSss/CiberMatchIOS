import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var isRegistering: Bool = false
    
    var body: some View {
        ZStack {
            // Fondo Gradiente
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#001f3d"), Color(hex: "#0066cc"), Color(hex: "#000000")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all) // Asegura que el gradiente ocupe toda la pantalla
            
            VStack {
                Spacer()
                
                Text("¡Bienvenido a MealsApp!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white) // Color blanco para el título
                    .padding(.bottom, 30)
                    .multilineTextAlignment(.center) // Centrado del título
                
                // Caja de registro
                VStack(spacing: 20) {
                    // Username Field
                    TextField("Correo electrónico", text: $username)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.gray.opacity(0.4), lineWidth: 2)) // Light gray border
                        .padding(.horizontal, 20)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .foregroundColor(Color(hex: "#1A1A1A")) // Normal text color
                        .shadow(color: Color(hex: "#00FFFF"), radius: 10, x: 0, y: 0) // Neon blue glow around the border
                    
                    // Password Field
                    SecureField("Contraseña", text: $password)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.gray.opacity(0.4), lineWidth: 2)) // Light gray border
                        .padding(.horizontal, 20)
                        .foregroundColor(Color(hex: "#1A1A1A")) // Normal text color
                        .shadow(color: Color(hex: "#00FFFF"), radius: 10, x: 0, y: 0) // Neon blue glow around the border
                    
                    // Error message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(Color(hex: "#FF4C61")) // Rojo Claro
                            .padding(.top, 10)
                    }
                    
                    // Register/Sign Up Button
                    Button(action: registerUser) {
                        Text(isRegistering ? "Registrando..." : "Crear cuenta")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(hex: "#0028ff")) // Azul Brillante
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            .opacity(isRegistering ? 0.6 : 1.0) // Reduce opacity when registering
                    }
                    .disabled(isRegistering || username.isEmpty || password.isEmpty) // Deshabilitar si no hay datos
                    
                    // Switch to Login Link
                    HStack {
                        Text("¿Ya tienes cuenta?")
                            .foregroundColor(Color.gray)
                        Button(action: {
                            // Aquí podrías agregar la lógica para cambiar a la vista de login
                        }) {
                            Text("Inicia sesión")
                                .foregroundColor(Color(hex: "#0066cc")) // Azul
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.top, 20)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.white)) // Fondo blanco de la caja
                .shadow(radius: 10) // Sombra
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding(.top, 50)
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Asegura que el VStack ocupe todo el espacio disponible
            .multilineTextAlignment(.center) // Centrado del contenido
        }
    }
    
    private func registerUser() {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor, ingresa un correo y una contraseña."
            return
        }
        
        isRegistering = true
        errorMessage = ""
        
        Auth.auth().createUser(withEmail: username, password: password) { result, error in
            isRegistering = false
            
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                // Aquí puedes redirigir al usuario a la pantalla principal de la aplicación
                print("Usuario registrado con éxito: \(String(describing: result?.user.email))")
            }
        }
    }
}

#Preview {
    RegisterView()
}
