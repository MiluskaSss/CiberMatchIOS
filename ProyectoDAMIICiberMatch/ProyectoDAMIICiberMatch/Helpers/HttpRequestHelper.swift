//
//  HttpRequestHelper.swift
//  ProyectoDAMIICiberMatch
//
//  Created by DAMII on 30/11/24.
//

import Foundation

class HttpRequestHelper{
    func Get(url: String, completion :  @escaping(Bool,Data?,String?) -> Void){
        guard let url = URL(string: url)else {
            completion(false,nil,"Error: can't create URL")
            return}
        
        var urlRequest = URLRequest (url: url)
        urlRequest.httpMethod = "GET"
        
        let session = URLSession.shared
        
        session.dataTask(with: urlRequest){
            data, response, error in
            guard error == nil else {
               completion (false,nil, "Error: proble calling GET")
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(false,nil,"Error : HTTP request failed")
                return }
            
            guard let data = data else {
                completion(false,nil,"Error: nno data")
                return }
            
             completion(true, data,nil)
        }.resume()
    }
}
