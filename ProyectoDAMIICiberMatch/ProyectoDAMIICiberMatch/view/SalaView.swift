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
        NavigationView {
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
                    
                    // NavigationLink para redirigir a MovieListView
                    NavigationLink(destination: MovieListView(salaCodigo: $salaCodigo)) {
                        Text("Ir a la lista de películas")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                    .transition(.opacity)
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
                creatorID = Auth.auth().currentUser?.uid
            }
        }
    }

    static func generarCodigoAleatorio() -> String {
        let caracteres = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in caracteres.randomElement()! })
    }

    private func guardarSalaEnFirebase() {
        guard let creatorID = creatorID else { return }
        
        db.collection("salas").document(salaCodigo).setData([
            "codigo": salaCodigo,
            "creadorID": creatorID,
            "usuariosConectados": [creatorID]
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

    @State private var navigateToMovieList = false

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
        .navigationDestination(isPresented: $navigateToMovieList) {
            MovieListView(salaCodigo: $salaCodigo) // Redirige a la vista de lista de películas
        }
    }

    private func ingresarASala() {
        guard let usuarioID = usuarioID else { return }
        
        // Asegúrate de que el código de sala no esté vacío
        guard !salaCodigo.isEmpty else {
            mensaje = "Por favor ingresa un código de sala válido."
            return
        }

        isLoading = true
        
        print("Código ingresado: \(salaCodigo)")  // Imprimir el código ingresado

        db.collection("salas").document(salaCodigo).getDocument { document, error in
            if let document = document, document.exists {
                // Si la sala existe, actualiza la lista de usuarios conectados
                db.collection("salas").document(salaCodigo).updateData([
                    "usuariosConectados": FieldValue.arrayUnion([usuarioID])
                ]) { error in
                    isLoading = false
                    if let error = error {
                        print("Error al ingresar a la sala: \(error.localizedDescription)")
                    } else {
                        isSalaValida = true
                        // Ahora que hemos ingresado a la sala, comenzamos a escuchar la sala
                        escucharSala()
                    }
                }
            } else {
                // Si la sala no existe, muestra un mensaje
                isLoading = false
                isSalaValida = false
                mensaje = "La sala no existe."
            }
        }
    }

    private func escucharSala() {
        // Verificamos si la variable salaCodigo no está vacía
        guard !salaCodigo.isEmpty else {
            print("El código de la sala está vacío.")
            return
        }
        
        print("Escuchando sala con código: \(salaCodigo)")  // Imprimir el código de la sala cuando se llama a la función escucharSala
        
        db.collection("salas").document(salaCodigo).addSnapshotListener { document, error in
            if let document = document {
                if document.exists {
                    // Si el documento existe, imprimimos su contenido
                    print("Documento de la sala escuchado: \(document.data() ?? [:])")
                    
                    // Imprimimos el código de la sala desde Firestore
                    print("Código escuchado desde Firestore: \(salaCodigo)")

                    if let usuarios = document.data()?["usuariosConectados"] as? [String], usuarios.count > 1 {
                        DispatchQueue.main.async {
                            print("Valor escuchado de usuarios conectados: \(usuarios)")  // Imprimir los usuarios conectados
                            navigateToMovieList = true // Redirige al usuario a MovieListView
                        }
                    }
                } else {
                    print("El documento de la sala no existe.")
                }
            } else if let error = error {
                print("Error al escuchar los cambios en la sala: \(error.localizedDescription)")
            }
        }
    }
}

import SwiftUI
import Firebase
import FirebaseFirestore

struct MovieListView: View {
    @StateObject var viewModel: MovieListViewModel = MovieListViewModel()
    @State private var currentIndex: Int = 0
    @State private var offset: CGSize = .zero
    @State private var isDragging: Bool = false
    @State private var showLogoutAlert: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToLogin: Bool = false
    @Binding var salaCodigo: String // Aquí usamos Binding<String>

    
    @State private var salaCode: String? = nil // Almacenamos el código de la sala
    
    let baseImageURL = "https://image.tmdb.org/t/p/w500"
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        
                        Menu {
                            Button(action: {
                                print("Perfil seleccionado")
                            }) {
                                Label("Perfil", systemImage: "person.circle")
                                    .foregroundColor(.yellow)
                            }
                            
                            Button(action: {
                                showLogoutAlert = true
                            }) {
                                Label("Cerrar sesión", systemImage: "arrow.right.circle.fill")
                                    .foregroundColor(.red)
                            }
                        } label: {
                            Image(systemName: "line.horizontal.3.decrease.circle.fill")
                                .font(.title)
                                .foregroundColor(.yellow)
                                .padding()
                        }
                    }
                    .padding(.top, -105)
                    
                    Text("Películas")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                        .padding(.top, -100)
                    
                    if viewModel.movies.isEmpty {
                        ProgressView("Cargando películas...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .foregroundColor(.yellow)
                            .padding(.top, 20)
                    } else {
                        ZStack {
                            ForEach(viewModel.movies.indices, id: \.self) { index in
                                if index == currentIndex {
                                    MovieCardView(movie: viewModel.movies[index])
                                        .offset(x: offset.width)
                                        .rotationEffect(.degrees(Double(offset.width / 10)))
                                        .gesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    offset = value.translation
                                                    isDragging = true
                                                }
                                                .onEnded { value in
                                                    isDragging = false
                                                    
                                                    if abs(offset.width) > 150 {
                                                        withAnimation(.spring()) {
                                                            currentIndex += 1
                                                            offset = .zero
                                                        }
                                                    } else {
                                                        withAnimation(.spring()) {
                                                            offset = .zero
                                                        }
                                                    }
                                                }
                                        )
                                        .animation(.spring(), value: offset)
                                }
                            }
                            
                            // Botón "Me gusta"
                            Button(action: {
                                likeMovie(movie: viewModel.movies[currentIndex]) // Llamamos la función pasando el objeto completo Movie
                                currentIndex += 1
                            }) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.green)
                                    .padding()
                            }
                            .position(x: UIScreen.main.bounds.width - 50, y: 300)

                            
                            // Botón "No me gusta"
                            Button(action: {
                                currentIndex += 1
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.red)
                                    .padding()
                            }
                            .position(x: 60, y: 300)
                        }
                        .frame(height: 500)
                        .padding(.top, -50)
                    }
                }
                .onAppear {
                    viewModel.getPopularMovies()
                }
                .alert(isPresented: $showLogoutAlert) {
                    Alert(
                        title: Text("Cerrar sesión"),
                        message: Text("¿Estás seguro de que deseas cerrar sesión?"),
                        primaryButton: .destructive(Text("Cerrar sesión")) {
                            logoutUser()
                        },
                        secondaryButton: .cancel()
                    )
                }
                .background(
                    NavigationLink(destination: LoginView(), isActive: $navigateToLogin) {
                        EmptyView()
                    }
                )
            }
        }
    }
    
    private func likeMovie(movie: Movie) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        let salaCode = salaCodigo // `salaCodigo` es un Binding, por lo que directamente lo usamos aquí
        let salaDoc = db.collection("salas").document(salaCode)
        
        salaDoc.getDocument { document, error in
            if let document = document, document.exists {
                let creatorId = document.data()?["creadorID"] as? String
                
                // Recuperamos los arrays existentes
                if var currentCreatorLikes = document.data()?["creatorLikes"] as? [Int],
                   var currentUserLikes = document.data()?["userLikes"] as? [Int],
                   var currentCoincidences = document.data()?["coincidencia"] as? [Int] {
                    
                    // Si el usuario es el creador de la sala
                    if userId == creatorId {
                        // Añadir el "like" del creador de la sala
                        if !currentCreatorLikes.contains(movie.id) {
                            currentCreatorLikes.append(movie.id)
                        }
                    } else {
                        // Añadir el "like" del usuario
                        if !currentUserLikes.contains(movie.id) {
                            currentUserLikes.append(movie.id)
                        }
                    }
                    
                    // Actualizar el array de coincidencias
                    currentCoincidences = Array(Set(currentCreatorLikes).intersection(Set(currentUserLikes)))
                    
                    // Actualizamos los arrays con los nuevos "likes" y coincidencias
                    salaDoc.updateData([
                        "creatorLikes": currentCreatorLikes,
                        "userLikes": currentUserLikes,
                        "coincidencia": currentCoincidences
                    ]) { error in
                        if let error = error {
                            print("Error al agregar el 'like' o la 'coincidencia': \(error.localizedDescription)")
                        } else {
                            print("'Like' y 'coincidencia' añadidos correctamente.")
                        }
                    }
                } else {
                    // Si los arrays no existen, crearlos
                    var creatorLikes = [Int]()
                    var userLikes = [Int]()
                    var coincidencias = [Int]()
                    
                    if userId == creatorId {
                        creatorLikes.append(movie.id) // El creador da el primer "like"
                    } else {
                        userLikes.append(movie.id) // Un usuario normal da su "like"
                    }
                    
                    // Establecer los datos iniciales
                    salaDoc.updateData([
                        "creatorLikes": creatorLikes,
                        "userLikes": userLikes,
                        "coincidencia": coincidencias
                    ]) { error in
                        if let error = error {
                            print("Error al inicializar los 'likes' o 'coincidencia': \(error.localizedDescription)")
                        } else {
                            print("Documento creado y 'like' añadido correctamente.")
                        }
                    }
                }
            } else {
                // Si el documento no existe, creamos uno nuevo con el código de la sala
                let creatorLikes = userId == document?.data()?["creadorID"] as? String ? [movie.id] : []
                let userLikes = userId != document?.data()?["creadorID"] as? String ? [movie.id] : []
                let coincidencias = Array(Set(creatorLikes).intersection(Set(userLikes))) // Calcular coincidencias
                
                salaDoc.setData([
                    "salaCode": salaCode,  // Guardamos el código de la sala
                    "creatorLikes": creatorLikes,
                    "userLikes": userLikes,
                    "coincidencia": coincidencias // Guardar coincidencias
                ]) { error in
                    if let error = error {
                        print("Error al crear el documento en 'salas': \(error.localizedDescription)")
                    } else {
                        print("Documento creado y 'like' añadido correctamente.")
                    }
                }
            }
        }
        
        // Escuchar cambios en el documento en tiempo real
        salaDoc.addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("Error al escuchar cambios: \(error.localizedDescription)")
            } else if let documentSnapshot = documentSnapshot, documentSnapshot.exists {
                let data = documentSnapshot.data()
                let creatorLikes = data?["creatorLikes"] as? [Int] ?? []
                let userLikes = data?["userLikes"] as? [Int] ?? []
                let coincidencias = Array(Set(creatorLikes).intersection(Set(userLikes)))
                
                print("Coincidencias actualizadas: \(coincidencias)")
                // Aquí puedes hacer lo que necesites con las coincidencias, como actualizar la UI.
                // Si hay coincidencias, mostrar animación
                            if !coincidencias.isEmpty {
                                showMatchAnimation()
                            }
            }
        }
    }
    // Función para mostrar animación de "Match"
    private func showMatchAnimation() {
        // Crear un UILabel que aparecerá con la animación de "Match"
        let matchLabel = UILabel()
        matchLabel.text = "¡Match!"
        matchLabel.font = UIFont.boldSystemFont(ofSize: 32)
        matchLabel.textColor = .white
        matchLabel.textAlignment = .center
        matchLabel.alpha = 0.0
        
        // Agregar el label al top view
        if let topController = UIApplication.shared.keyWindow?.rootViewController {
            topController.view.addSubview(matchLabel)
            
            // Configurar el tamaño y posición
            matchLabel.frame = CGRect(x: 0, y: 100, width: topController.view.frame.width, height: 50)
            
            // Animación de aparición
            UIView.animate(withDuration: 0.5, animations: {
                matchLabel.alpha = 1.0
            }) { _ in
                // Después de mostrar la animación, desaparecer
                UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: {
                    matchLabel.alpha = 0.0
                }) { _ in
                    matchLabel.removeFromSuperview()  // Eliminar el label después de la animación
                }
            }
        }
    }
    private func logoutUser() {
        do {
            try Auth.auth().signOut()
            navigateToLogin = true
        } catch {
            print("Error al cerrar sesión: \(error.localizedDescription)")
        }
    }
}


struct MovieCardView: View {
    let movie: Movie
    let baseImageURL = "https://image.tmdb.org/t/p/w500"
    
    var body: some View {
        VStack {
            if let posterURL = URL(string: baseImageURL + movie.poster) {
                AsyncImage(url: posterURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250, height: 375)
                    } else if phase.error != nil {
                        Text("Error al cargar la imagen")
                            .foregroundColor(.red)
                    } else {
                        ProgressView()
                    }
                }
                .cornerRadius(16)
                .shadow(radius: 10)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(movie.title)
                    .font(.headline)
                    .foregroundColor(.yellow)
                Text(movie.overview)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(3)
            }
            .padding(.top, 8)
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 20)
        .background(Color.black)
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}

#Preview {
    SalaView()
}
