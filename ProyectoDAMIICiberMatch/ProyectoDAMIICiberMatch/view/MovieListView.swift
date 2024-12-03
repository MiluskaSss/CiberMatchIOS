import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MovieListView: View {
    @StateObject var viewModel: MovieListViewModel = MovieListViewModel()
    @State private var currentIndex: Int = 0
    @State private var offset: CGSize = .zero
    @State private var isDragging: Bool = false
    @State private var showLogoutAlert: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToLogin: Bool = false
    
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
                                likeMovie(movieId: String(viewModel.movies[currentIndex].id)) // Convertimos a String
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
    
    private func likeMovie(movieId: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let userDoc = db.collection("sala").document(userId)
        
        userDoc.getDocument { document, error in
            if let document = document, document.exists {
                userDoc.updateData([
                    "likes": FieldValue.arrayUnion([movieId])
                ]) { error in
                    if let error = error {
                        print("Error al guardar 'Me gusta': \(error.localizedDescription)")
                    } else {
                        print("'Me gusta' añadido correctamente")
                    }
                }
            } else {
                userDoc.setData([
                    "userId": userId,
                    "likes": [movieId]
                ]) { error in
                    if let error = error {
                        print("Error al crear documento: \(error.localizedDescription)")
                    } else {
                        print("Documento creado correctamente")
                    }
                }
            }
        }
    }
    
    private func fetchCommonLikes() {
        let db = Firestore.firestore()
        db.collection("sala").getDocuments { snapshot, error in
            if let error = error {
                print("Error al obtener documentos: \(error.localizedDescription)")
                return
            }
            
            var allLikes: [[String]] = []
            
            snapshot?.documents.forEach { document in
                if let likes = document.data()["likes"] as? [String] {
                    allLikes.append(likes)
                }
            }
            
            guard let firstUserLikes = allLikes.first else { return }
            let commonLikes = allLikes.dropFirst().reduce(Set(firstUserLikes)) { partialResult, nextLikes in
                partialResult.intersection(Set(nextLikes))
            }
            
            print("Coincidencias: \(commonLikes)")
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



struct MovieListView_Previews: PreviewProvider {
    static var previews: some View {
        MovieListView()
            .preferredColorScheme(.dark) // Usar esquema de colores oscuro para la vista previa
    }
}
