//
//  RegisterView.swift
//  ProyectoDAMIICiberMatch
//
//  Created by DAMII on 30/11/24.
//

import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var isRegistering: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("¡Bienvenido a MealsApp!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Username Field
            TextField("Correo electrónico", text: $username)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                .padding(.horizontal)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
            
            // Password Field
            SecureField("Contraseña", text: $password)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                .padding(.horizontal)
            
            // Error message
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
            
            // Register/Sign Up Button
            Button(action: registerUser) {
                Text(isRegistering ? "Registrando..." : "Crear cuenta")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .disabled(isRegistering || username.isEmpty || password.isEmpty) // Deshabilitar si no hay datos
            
            // Switch to Login Link
            HStack {
                Text("¿Ya tienes cuenta?")
                Button(action: {
                    // Aquí podrías agregar la lógica para cambiar a la vista de login
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
    LoginView()
}
