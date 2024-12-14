import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var isRegistering: Bool = false
    
    let labelColor = Color(red: 0.05, green: 0.1, blue: 0.2) // Azul oscuro para las etiquetas de texto
    let textColor = Color.black // Color negro para el texto ingresado

    var body: some View {
        ZStack {
            // Fondo con gradiente azul oscuro y turquesa
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.2, blue: 0.3), // Azul oscuro
                    Color(red: 0.1, green: 0.4, blue: 0.5)  // Turquesa
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                // Contenedor principal reducido
                VStack(spacing: 12) {
                    // Imagen de perfil
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60) // Tamaño más pequeño
                        .foregroundColor(.black)
                        .padding(.top, 20)
                    
                    // Título
                    Text("Registrarse")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 15)
                    
                    // Formulario
                    VStack(spacing: 10) {
                        // Campo de correo
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Correo electrónico")
                                .fontWeight(.semibold)
                                .foregroundColor(labelColor)
                                .font(.footnote)
                            TextField("", text: $username)
                                .padding(.vertical, 8)
                                .foregroundColor(textColor)
                                .background(Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(labelColor), alignment: .bottom)
                        }

                        // Campo de contraseña
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Contraseña")
                                .fontWeight(.semibold)
                                .foregroundColor(labelColor)
                                .font(.footnote)
                            SecureField("", text: $password)
                                .padding(.vertical, 8)
                                .foregroundColor(textColor)
                                .background(Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(labelColor), alignment: .bottom)
                        }
                    }
                    .padding(.horizontal, 16)

                    // Mensaje de error
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.top, 5)
                    }

                    // Botón de registro
                    Button(action: registerUser) {
                        Text(isRegistering ? "Registrando..." : "Crear cuenta")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(labelColor)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 16)
                    .disabled(isRegistering || username.isEmpty || password.isEmpty)
                    
                    // Enlace a iniciar sesión
                    HStack {
                        Text("¿Ya tienes cuenta?")
                            .font(.footnote)
                        Button(action: {
                            // Acción para cambiar a la vista de login
                        }) {
                            Text("Inicia sesión")
                                .font(.footnote)
                                .foregroundColor(.blue)
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 4)
                .frame(width: 300) // Ajuste del ancho del contenedor
                
                Spacer()
            }
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
                print("Usuario registrado con éxito: \(String(describing: result?.user.email))")
            }
        }
    }
}

#Preview {
    RegisterView()
}
