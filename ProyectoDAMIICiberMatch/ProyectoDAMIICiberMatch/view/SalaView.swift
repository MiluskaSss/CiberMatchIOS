//
//  SalaView.swift
//  ProyectoDAMIICiberMatch
//
//  Created by DAMII on 3/12/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct SalaView: View {
    @State private var showCrearSala = false
    @State private var showIngresarSala = false
    @State private var salaCodigo: String = CrearSalaView.generarCodigoAleatorio()
    @State private var isSalaCreada = false
    @State private var isSalaValida = true
    @State private var isLoading = false
    @State private var mensaje: String = ""
    @State private var creatorID: String?
    @State private var usuarioID: String?
    
    let db = Firestore.firestore()

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Selecciona una opción")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Botón para crear una sala
                Button(action: {
                    showCrearSala = true
                }) {
                    Text("Crear una sala")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                // Botón para ingresar a una sala existente
                Button(action: {
                    showIngresarSala = true
                }) {
                    Text("Ingresar a sala existente")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                if !isSalaValida {
                    Text(mensaje)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .navigationDestination(isPresented: $showCrearSala) {
                CrearSalaView(salaCodigo: $salaCodigo, isSalaCreada: $isSalaCreada, creatorID: $creatorID)
            }
            .navigationDestination(isPresented: $showIngresarSala) {
                IngresarSalaView(salaCodigo: $salaCodigo, isLoading: $isLoading, isSalaValida: $isSalaValida, mensaje: $mensaje, creatorID: $creatorID, usuarioID: $usuarioID)
            }
        }
        .onAppear {
            usuarioID = Auth.auth().currentUser?.uid
        }
    }
}

struct CrearSalaView: View {
    @Binding var salaCodigo: String
    @Binding var isSalaCreada: Bool
    @Binding var creatorID: String?
    
    let db = Firestore.firestore()

    var body: some View {
        VStack(spacing: 20) {
            Text("Sala creada")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Código de la sala:")
                .font(.title2)
            
            Text(salaCodigo)
                .font(.title)
                .fontWeight(.bold)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            if isSalaCreada {
                Text("¡Sala guardada en Firebase!")
                    .foregroundColor(.green)
            } else {
                Button(action: {
                    guardarSalaEnFirebase()
                }) {
                    Text("Guardar sala")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .onAppear {
            // Obtener el ID del usuario autenticado (creador)
            creatorID = Auth.auth().currentUser?.uid
        }
    }

    static func generarCodigoAleatorio() -> String {
        let caracteres = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in caracteres.randomElement()! })
    }

    private func guardarSalaEnFirebase() {
        guard let creatorID = creatorID else { return }
        
        // Guardar en Firestore la sala con su código y el ID del creador
        db.collection("salas").document(salaCodigo).setData([
            "codigo": salaCodigo,
            "creadorID": creatorID,
            "usuariosConectados": [creatorID] // Incluir al creador como el primer usuario
        ]) { error in
            if let error = error {
                print("Error al guardar la sala: \(error.localizedDescription)")
            } else {
                isSalaCreada = true
            }
        }
    }
}

struct IngresarSalaView: View {
    @Binding var salaCodigo: String
    @Binding var isLoading: Bool
    @Binding var isSalaValida: Bool
    @Binding var mensaje: String
    @Binding var creatorID: String?
    @Binding var usuarioID: String?
    
    let db = Firestore.firestore()

    var body: some View {
        VStack(spacing: 20) {
            Text("Ingresa el código de la sala")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Código de la sala", text: $salaCodigo)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .keyboardType(.numberPad)
            
            if !isSalaValida {
                Text("Código de sala inválido")
                    .foregroundColor(.red)
            }
            
            if isLoading {
                ProgressView()
            } else {
                Button(action: {
                    ingresarASala()
                }) {
                    Text("Ingresar")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }

    private func ingresarASala() {
        guard let usuarioID = usuarioID else { return }
        isLoading = true
        
        // Verificar si el código de la sala es válido
        db.collection("salas").document(salaCodigo).getDocument { document, error in
            if let document = document, document.exists {
                // Si la sala existe, agregar el usuario a la lista de usuarios conectados
                db.collection("salas").document(salaCodigo).updateData([
                    "usuariosConectados": FieldValue.arrayUnion([usuarioID])
                ]) { error in
                    isLoading = false
                    if let error = error {
                        print("Error al ingresar a la sala: \(error.localizedDescription)")
                    } else {
                        isSalaValida = true
                        // Redirigir al usuario a la sala
                        // Aquí puedes agregar la lógica para redirigir al usuario a la vista de la sala
                    }
                }
            } else {
                // Si la sala no existe
                isLoading = false
                isSalaValida = false
                mensaje = "La sala no existe."
            }
        }
    }
}

#Preview {
    SalaView()
}

