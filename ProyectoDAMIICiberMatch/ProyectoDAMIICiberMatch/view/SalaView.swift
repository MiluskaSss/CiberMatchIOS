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
            ZStack {
                // Fondo de gradiente
                LinearGradient(colors: [Color.blue, Color.purple], startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 40) {
                    // Título con un ícono representativo de cine
                    VStack(spacing: 10) {
                        Image(systemName: "film")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.orange)

                        Text("Bienvenido al Cine")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    // Botón para crear una sala
                    Button(action: {
                        showCrearSala = true
                    }) {
                        HStack {
                            Image(systemName: "heart.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)

                            Text("Crear una sala")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(colors: [Color.pink, Color.red], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .foregroundColor(.white)
                    }
                    
                    // Botón para ingresar a una sala existente
                    Button(action: {
                        showIngresarSala = true
                    }) {
                        HStack {
                            Image(systemName: "person.2.fill")
                                .font(.title2)
                                .foregroundColor(.white)

                            Text("Ingresar a sala existente")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(colors: [Color.orange, Color.red], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .foregroundColor(.white)
                    }
                    
                    // Mensaje de error si la sala no es válida
                    if !isSalaValida {
                        Text(mensaje)
                            .font(.body)
                            .foregroundColor(.red)
                            .padding(.top, 10)
                    }
                }
                .padding()
            }
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
                    Text("¡Sala guardada en Firebase con estado Activo!")
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
                    
                    // Botón para actualizar el código
                    Button(action: {
                        actualizarCodigo()
                    }) {
                        Text("Actualizar código")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
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
            "usuariosConectados": [creatorID],
            "estado": "Activo" // Se guarda como activo al registrar
        ]) { error in
            if let error = error {
                print("Error al guardar la sala: \(error.localizedDescription)")
            } else {
                isSalaCreada = true
            }
        }
    }

    private func actualizarCodigo() {
        // Cambiar el estado de la sala actual a "Inactivo"
        db.collection("salas").document(salaCodigo).updateData([
            "estado": "Inactivo"
        ]) { error in
            if let error = error {
                print("Error al actualizar el estado de la sala: \(error.localizedDescription)")
            } else {
                print("Estado de la sala anterior cambiado a Inactivo")
            }
        }

        // Generar un nuevo código aleatorio
        salaCodigo = Self.generarCodigoAleatorio()
        // Habilitar el botón de "Guardar sala"
        isSalaCreada = false
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
                Text(mensaje)
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
            isSalaValida = false
            return
        }

        isLoading = true
        
        print("Código ingresado: \(salaCodigo)")  // Imprimir el código ingresado

        db.collection("salas").document(salaCodigo).getDocument { document, error in
            isLoading = false
            
            if let document = document, document.exists {
                let data = document.data() ?? [:]
                let estado = data["estado"] as? String ?? "Inactivo"
                
                if estado == "Activo" {
                    // Si la sala está activa, se actualiza la lista de usuarios conectados
                    db.collection("salas").document(salaCodigo).updateData([
                        "usuariosConectados": FieldValue.arrayUnion([usuarioID])
                    ]) { error in
                        if let error = error {
                            print("Error al ingresar a la sala: \(error.localizedDescription)")
                        } else {
                            isSalaValida = true
                            mensaje = "Sala válida. Redirigiendo..."
                            // Ahora que hemos ingresado a la sala, comenzamos a escuchar la sala
                            escucharSala()
                        }
                    }
                } else {
                    // Si la sala no está activa, muestra un mensaje
                    isSalaValida = false
                    mensaje = "La sala ha finalizado."
                }
            } else {
                // Si la sala no existe, muestra un mensaje
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
    @Binding var salaCodigo: String

    @State private var salaCode: String? = nil
    @State private var salaListener: ListenerRegistration? = nil
    
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
                                // Verificar si es necesario cargar más películas
                                if viewModel.movies.count - currentIndex <= 3 {
                                    // Cargar más películas si quedan 3 o menos por mostrar
                                    viewModel.loadMoreMovies()
                                }

                                // Realizar la acción de "like" en la película actual
                                likeMovie(movie: viewModel.movies[currentIndex], codigoSala: salaCodigo)
                                
                                // Incrementar el índice para pasar a la siguiente película
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
                    setupCoincidenciasListener()                }
                .onDisappear {
                    salaListener?.remove()  // Elimina el listener cuando la vista desaparece
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
    // Método para configurar el listener que escucha cambios en un documento específico dentro de "coincidencias"
    private func setupCoincidenciasListener() {
        let db = Firestore.firestore()
        let coincidenciasDoc = db.collection("coincidencias").document(salaCodigo)
        
        // Configura el listener para el documento específico
        coincidenciasDoc.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error al escuchar cambios en el documento coincidencias: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                print("El documento con el código de sala '\(salaCodigo)' no existe.")
                return
            }
            
            let data = snapshot.data() ?? [:]
            
            // Verificar si existe el campo "match" y si contiene datos
            if let match = data["match"] as? [Int], !match.isEmpty {
                print("Matches encontrados: \(match)")
                
                // Mostrar un alert con el mensaje "Nuevo Match"
                self.showMatchAlert(viewController: UIApplication.shared.windows.first?.rootViewController)
            } else {
                print("No se encontraron matches en el documento.")
            }
        }
    }




    // Mostrar un alert con el mensaje de "Nuevo Match"
    private func showMatchAlert(viewController: UIViewController?) {
        // Crear un alert controller con el mensaje
        let alert = UIAlertController(title: "Match", message: "¡Nuevo Match en la sala!", preferredStyle: .alert)
        
        // Agregar un botón para cerrar el alert
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // Verificar si la vista está disponible antes de mostrar la alerta
        if let viewController = viewController {
            // Presentar el alert
            viewController.present(alert, animated: true, completion: nil)
        } else {
            print("No se pudo presentar el alert porque no hay un view controller disponible.")
        }
    }

    // Método para dar "like" a una película
    func likeMovie(movie: Movie, codigoSala: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let salaDoc = db.collection("salas").document(codigoSala)  // Se pasa codigoSala aquí
        let coincidenciasDoc = db.collection("coincidencias").document(codigoSala)  // Se pasa codigoSala aquí
        
        // Obtener el documento de la sala
        salaDoc.getDocument { document, error in
            if let error = error {
                print("Error al obtener el documento de la sala: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                let data = document.data() ?? [:]
                let creatorId = data["creadorID"] as? String
                
                // Recuperar los likes actuales de los usuarios
                var currentCreatorLikes = data["creatorLikes"] as? [Int] ?? []
                var currentUserLikes = data["userLikes"] as? [Int] ?? []
                
                // Actualizar los likes según el usuario
                if userId == creatorId {
                    if !currentCreatorLikes.contains(movie.id) {
                        currentCreatorLikes.append(movie.id)
                    }
                } else {
                    if !currentUserLikes.contains(movie.id) {
                        currentUserLikes.append(movie.id)
                    }
                }
                
                // Actualizar Firestore con los likes actualizados
                salaDoc.updateData([
                    "creatorLikes": currentCreatorLikes,
                    "userLikes": currentUserLikes
                ]) { error in
                    if let error = error {
                        print("Error al actualizar los likes: \(error.localizedDescription)")
                    } else {
                        print("Likes actualizados correctamente.")
                        
                        // Verificar coincidencias
                        self.checkAndUpdateCoincidences(
                            coincidenciasDoc: coincidenciasDoc,
                            creatorLikes: currentCreatorLikes,
                            userLikes: currentUserLikes,
                            creatorId: creatorId,
                            userId: userId,
                            movieId: movie.id,
                            codigoSala: codigoSala  // Se pasa codigoSala aquí
                        )
                    }
                }
            }
        }
    }

    // Método para verificar y actualizar coincidencias
    private func checkAndUpdateCoincidences(
        coincidenciasDoc: DocumentReference,
        creatorLikes: [Int],
        userLikes: [Int],
        creatorId: String?,
        userId: String?,
        movieId: Int,
        codigoSala: String  // Se agrega codigoSala como parámetro
    ) {
        let db = Firestore.firestore()
        
        // Verificar si hay una coincidencia en la película actual
        if creatorLikes.contains(movieId) && userLikes.contains(movieId) {
            coincidenciasDoc.getDocument { document, error in
                if let error = error {
                    print("Error al obtener el documento de coincidencias: \(error.localizedDescription)")
                    return
                }
                
                // Cambiado el nombre del campo de "coincidencias" a "match"
                var matchList = document?.data()?["match"] as? [Int] ?? []
                
                // Si la coincidencia ya está registrada, no hacer nada
                if matchList.contains(movieId) {
                    print("La coincidencia ya está registrada.")
                    return
                }
                
                // Agregar la nueva coincidencia
                matchList.append(movieId)
                
                // Actualizar el documento con el campo "match"
                coincidenciasDoc.setData(["match": matchList], merge: true) { error in
                    if let error = error {
                        print("Error al actualizar match: \(error.localizedDescription)")
                    } else {
                        print("Match registrado correctamente.")
                        
                        // Enviar mensaje de match a ambos usuarios
                        self.sendMatchMessage(
                            creatorId: creatorId,
                            userId: userId,
                            movieId: movieId,
                            codigoSala: codigoSala  // Se pasa codigoSala aquí
                        )
                    }
                }
            }
        } else {
            print("No hay coincidencia para esta película.")
        }
    }



    private func sendMatchMessage(creatorId: String?, userId: String?, movieId: Int, codigoSala: String?) {
        // Verificar si creatorId, userId y codigoSala son válidos
        guard let creatorId = creatorId, let userId = userId, let codigoSala = codigoSala else {
            print("Error: Faltan parámetros necesarios.")
            return
        }
        
        let db = Firestore.firestore()
        
        // Crear el mensaje con el codigoSala
        let message = "¡Match encontrado en la película con ID \(movieId) en la sala \(codigoSala)!"
        
        // Actualizar el array de usuarios conectados y agregar el mensaje
        let salaDoc = db.collection("salas").document(codigoSala)
        
        // Actualizar el array de mensajes en la sala
        salaDoc.updateData([
            "mensajes": FieldValue.arrayUnion([message])
        ]) { error in
            if let error = error {
                print("Error al enviar mensaje a la sala: \(error.localizedDescription)")
            } else {
                print("Mensaje enviado a la sala \(codigoSala).")
            }
        }
        
        // Actualizar los mensajes de los usuarios
        let creatorDoc = db.collection("usuarios").document(creatorId)
        let userDoc = db.collection("usuarios").document(userId)
        
        creatorDoc.updateData(["mensajes": FieldValue.arrayUnion([message])]) { error in
            if let error = error {
                print("Error al enviar mensaje al creador: \(error.localizedDescription)")
            } else {
                print("Mensaje enviado al creador.")
            }
        }
        
        userDoc.updateData(["mensajes": FieldValue.arrayUnion([message])]) { error in
            if let error = error {
                print("Error al enviar mensaje al usuario: \(error.localizedDescription)")
            } else {
                print("Mensaje enviado al usuario.")
            }
        }
    }

    private func startListeningForMessages(codigoSala: String?, viewController: UIViewController) {
        guard let codigoSala = codigoSala else {
            print("Error: Faltan parámetros necesarios.")
            return
        }
        
        let db = Firestore.firestore()
        
        // Obtener la referencia al documento de la sala
        let salaDoc = db.collection("salas").document(codigoSala)
        
        // Escuchar los cambios en el campo "mensajes" de la sala
        salaDoc.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot, document.exists else {
                print("No se encontró el documento de la sala o ocurrió un error: \(error?.localizedDescription ?? "Desconocido")")
                return
            }
            
            // Obtener el array de mensajes
            if let mensajes = document.get("mensajes") as? [String], !mensajes.isEmpty {
                // Aquí puedes actualizar la interfaz con los nuevos mensajes
                print("Mensajes recibidos: \(mensajes)")
                
                // Mostrar un alert con el mensaje "Match"
                self.showMatchAlert(viewController: viewController)
            } else {
                print("No se encontraron mensajes en la sala.")
            }
        }
    }

    private func showMatchAlert(viewController: UIViewController) {
        // Crear un alert controller con el mensaje
        let alert = UIAlertController(title: "Match", message: "¡Nuevo Match en la sala!", preferredStyle: .alert)
        
        // Agregar un botón para cerrar el alert
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // Presentar el alert
        viewController.present(alert, animated: true, completion: nil)
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
