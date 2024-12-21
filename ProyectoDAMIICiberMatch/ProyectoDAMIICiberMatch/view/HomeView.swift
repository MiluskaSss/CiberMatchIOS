//
//  Hme.swift
//  ProyectoDAMIICiberMatch
//
//  Created by DAMII on 21/12/24.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo con color negro y un toque morado neón
                Color.black
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.8), Color.purple.opacity(0.6)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .edgesIgnoringSafeArea(.all)
                    )

                VStack {
                    // Eliminamos Spacer() para que el título esté más cerca de la parte superior
                    Text("Bienvenido a CineMatch")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                        .minimumScaleFactor(0.5) // El texto puede reducirse hasta el 50% de su tamaño original
                        .lineLimit(1) // Evita que el texto ocupe varias líneas
                        .padding(.top, 30) // Ajuste fino para que el título quede más cerca de la parte superior
                    
                    // Imagen como icono debajo del título, aumentando su tamaño
                    Image("Logo-Photoroom") // Reemplazar con el nombre del asset que subiste
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250) // Tamaño de la imagen más grande
                        .padding(.top, 20) // Espacio entre el título y la imagen

                    Spacer() // Espacio intermedio para centrar los elementos

                    // Descripción centrada con texto relacionado con la app de CineMatch
                    Text("¡Descubre películas y series recomendadas especialmente para ti! Conéctate con otros cinéfilos y vive la experiencia CineMatch.")
                        .multilineTextAlignment(.center)
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)
                    // Botón con degradado morado neón y azul oscuro
                    NavigationLink(destination: LoginView()) {
                    Text("¡Accede al Cine!")
                    .fontWeight(.bold)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.pink.opacity(0.5), Color.purple.opacity(0.7)]),
                    startPoint: .leading,
                    endPoint: .trailing))
                    // Degradado morado neón y azul oscuro
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 5) // Sombra azul tenue
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40) // Espaciado abajo
                }
                .padding() // Asegura que todo el contenido tenga el espaciado adecuado
            }
        }
    }
}

#Preview {
    HomeView()
}
