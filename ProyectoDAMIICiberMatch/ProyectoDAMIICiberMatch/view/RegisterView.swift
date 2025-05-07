//
//  RegisterView.swift
//  ProyectoDAMIICiberMatch
//
//  Created by DAMII on 30/11/24.
//

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
    
    private let db = Firestore.firestore() // Instancia de Firestore
    
    var body: some View {
        VStack(spacing: 20) {
            Text("¡Bienvenido a MealsApp!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Nombre de usuario
            TextField("Nombre de usuario", text: $displayName)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                .padding(.horizontal)
                .autocapitalization(.none)
                .textInputAutocapitalization(.never)
            
            // Email
            TextField("Correo electrónico", text: $username)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                .padding(.horizontal)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
            
            // Password
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
            
            // Botón de registro
            Button(action: registerUser) {
                Text(isRegistering ? "Registrando..." : "Crear cuenta")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .disabled(isRegistering || username.isEmpty || password.isEmpty || displayName.isEmpty)
            
            // Cambio a login
            HStack {
                Text("¿Ya tienes cuenta?")
                Button(action: {
                    // Lógica para cambiar a la vista de login
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
        .alert(isPresented: $showSuccessAlert) { // Alerta de éxito
            Alert(
                title: Text("Registro exitoso"),
                message: Text("¡Tu cuenta ha sido creada con éxito!"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func registerUser() {
        guard !username.isEmpty, !password.isEmpty, !displayName.isEmpty else {
            errorMessage = "Por favor, completa todos los campos."
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
                showSuccessAlert = true // Mostrar alerta de éxito
            }
        }
    }
}

#Preview {
    RegisterView()
}
