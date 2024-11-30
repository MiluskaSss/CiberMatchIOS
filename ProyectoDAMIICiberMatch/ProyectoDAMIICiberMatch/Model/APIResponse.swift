//
//  APIResponse.swift
//  ProyectoDAMIICiberMatch
//
//  Created by DAMII on 30/11/24.
//

import Foundation
struct APIResponse: Decodable {
    let results: [Movie]

    enum CodingKeys: String, CodingKey {
        case results
    }
}
struct Movie: Decodable, Identifiable {
    let id: Int
    let title: String
    let poster: String
    let overview: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case poster = "poster_path"
        case overview
    }
}

