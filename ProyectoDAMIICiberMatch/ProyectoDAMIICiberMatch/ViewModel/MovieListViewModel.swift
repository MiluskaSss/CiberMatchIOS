//
//  MovieListViewModel.swift
//  ProyectoDAMIICiberMatch
//
//  Created by DAMII on 30/11/24.
//

import Foundation
class MovieListViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    
    /// Método para cargar películas de ejemplo en memoria
    private func getMoviesInMemory() {
        let movie = Movie(
            id: 1,
            title: "Venom 2",
            poster: "https://image.tmdb.org/t/p/w500/aosm8NMQ3UyoBVpSxyimorCQykC.jpg",
            overview: "Las aventuras de venom"
        )
        movies.append(movie)
    }
    
    /// Método para obtener películas populares desde el servicio
    func getPopularMovies() {
        MovieService().getPopularMovies { movies, message in
            if let movies = movies {
                DispatchQueue.main.async {
                    self.movies = movies
                }
            } else if let message = message {
                print("Error al obtener películas: \(message)")
            }
        }
    }
}
