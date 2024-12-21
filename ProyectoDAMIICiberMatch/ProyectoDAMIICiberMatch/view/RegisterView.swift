import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegisterView: View {
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var displayName: String = "" // Campo para el nombre del usuario
    @State private var errorMessage: String = ""
    @State private var isRegistering: Bool = false
    @State private var showSuccessAlert: Bool = false // Para controlar la alerta de éxito
    @State private var showLoginView: Bool = false // Controla la navegación hacia el login
    @State private var showPassword: Bool = false // Controla la visibilidad de la contraseña
    
    private let db = Firestore.firestore() // Instancia de Firestore
    
    var body: some View {
        VStack {
            if showLoginView {
                // Vista de Login
                LoginView() // Aquí debes tener la vista de login que quieres mostrar
            } else {
                // Vista de Registro
                ZStack {
                    // Fondo degradado de negro a morado
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black, Color.purple]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        Spacer() // Esto asegura que el contenido se centre verticalmente
                        
                        Text("¡CineMatch!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        // Ícono debajo del título
                        ZStack {
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .foregroundColor(.white)
                            
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.purple)
                                .offset(x: 35, y: -35)
                        }
                        
                        // Subtítulo
                        Text("Regístrate en CineMatch, descubre sus increíbles funciones y vive una experiencia única llena de creatividad y entretenimiento.")
                            .font(.system(size: 16))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.gray)
                            .padding(.horizontal, 30)
                        
                        // Nombre de usuario
                        TextField("Nombre de usuario", text: $displayName)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.white, lineWidth: 1))
                            .padding(.horizontal)
                            .autocapitalization(.none)
                            .textInputAutocapitalization(.never)
                            .foregroundColor(Color.white.opacity(0.9)) // Color más fuerte para el texto
                        
                        // Email
                        TextField("Correo electrónico", text: $username)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.white, lineWidth: 1))
                            .padding(.horizontal)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .foregroundColor(Color.white.opacity(0.9)) // Color más fuerte para el texto
                        
                        // Contraseña
                        ZStack {
                            HStack {
                                if showPassword {
                                    TextField("Contraseña", text: $password)
                                        .padding()
                                        .frame(height: 50)
                                        .foregroundColor(Color.white.opacity(0.9)) // Color más fuerte para el texto
                                        .onChange(of: password) { newValue in
                                            if newValue.count > 10 {
                                                password = String(newValue.prefix(10)) // Limitar a 10 caracteres
                                            }
                                        }
                                } else {
                                    SecureField("Contraseña", text: $password)
                                        .padding()
                                        .frame(height: 50)
                                        .foregroundColor(Color.white.opacity(0.9)) // Color más fuerte para el texto
                                        .onChange(of: password) { newValue in
                                            if newValue.count > 10 {
                                                password = String(newValue.prefix(10)) // Limitar a 10 caracteres
                                            }
                                        }
                                }

                                Button(action: {
                                    showPassword.toggle()
                                }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.white)
                                }
                                .padding(.trailing, 15)
                            }
                            .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.white, lineWidth: 1))
                            .padding(.horizontal)
                        }
                        
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding(.top, 10)
                        }
                        
                        Button(action: registerUser) {
                            Text(isRegistering ? "Registrando..." : "Crear cuenta")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        .disabled(isRegistering || username.isEmpty || password.isEmpty || displayName.isEmpty)
                        
                        HStack {
                            Text("¿Ya tienes cuenta?")
                                .foregroundColor(.white)
                            Button(action: {
                                showLoginView = true
                            }) {
                                Text("Inicia sesión")
                                    .foregroundColor(.blue)
                                    .fontWeight(.bold)
                            }
                        }
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                    .padding(.top, 50)
                    .alert(isPresented: $showSuccessAlert) {
                        Alert(
                            title: Text("Registro exitoso"),
                            message: Text("¡Tu cuenta ha sido creada con éxito!"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
            }
        }
    }
    
    private func registerUser() {
        guard !username.isEmpty, !password.isEmpty, !displayName.isEmpty else {
            errorMessage = "Por favor, completa todos los campos."
            return
        }
        
        // Validar que la contraseña tenga entre 6 y 10 caracteres
        guard password.count >= 6 && password.count <= 10 else {
            errorMessage = "La contraseña debe tener entre 6 y 10 caracteres."
            return
        }
        
        isRegistering = true
        errorMessage = ""
        
        Auth.auth().createUser(withEmail: username, password: password) { result, error in
            isRegistering = false
            
            if let error = error {
                errorMessage = error.localizedDescription
            } else if let user = result?.user {
                saveUserToFirestore(userID: user.uid)
            }
        }
    }
    
    private func saveUserToFirestore(userID: String) {
        let userData: [String: Any] = [
            "userID": userID,
            "email": username,
            "displayName": displayName,
            "createdAt": Timestamp()
        ]
        
        db.collection("users").document(userID).setData(userData) { error in
            if let error = error {
                errorMessage = "Error al guardar el usuario: \(error.localizedDescription)"
            } else {
                print("Usuario guardado correctamente en Firestore.")
                showSuccessAlert = true
            }
        }
    }
}

// Vista de Login
struct LoginFormView: View {
    var body: some View {
        VStack {
            Text("Iniciar sesión")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
        }
        .navigationTitle("LoginView")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    RegisterView()
}

