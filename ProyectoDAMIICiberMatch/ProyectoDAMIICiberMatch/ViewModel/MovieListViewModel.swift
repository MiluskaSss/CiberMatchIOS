// MovieListViewModel.swift
// ProyectoDAMIICiberMatch
//
// Created by DAMII on 30/11/24.
//

import Foundation

class MovieListViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    private var currentPage: Int = 1  // Página actual para la paginación
    private let movieService = MovieService()

    /// Método para cargar películas desde el servicio
    func getPopularMovies() {
        // Cargar las películas de la primera página
        movieService.getPopularMovies(page: currentPage) { [weak self] movies, message in
            if let movies = movies {
                DispatchQueue.main.async {
                    self?.movies = movies
                }
            } else if let message = message {
                print("Error al obtener películas: \(message)")
            }
        }
    }
    
    /// Método para cargar más películas (paginación)
    func loadMoreMovies() {
        currentPage += 1  // Incrementar la página
        movieService.getPopularMovies(page: currentPage) { [weak self] movies, message in
            if let movies = movies {
                DispatchQueue.main.async {
                    self?.movies.append(contentsOf: movies)  // Añadir las nuevas películas
                }
            } else if let message = message {
                print("Error al obtener más películas: \(message)")
            }
        }
    }
}
