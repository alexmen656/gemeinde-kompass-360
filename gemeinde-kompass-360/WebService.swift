//
//  WebService.swift
//  gemeinde-kompass-360
//
//  Created by Alex Polan on 13/11/2023.
//

import Foundation


enum NetworkError: Error {
    case badUrl
    case invalidRequest
    case badResponse
    case badStatus
    case failedToDecodeResponse
}

class WebService {
    func downloadData<T: Codable>(fromURL urlString: String) async throws -> T {
        do {
            guard let url = URL(string: urlString) else { throw NetworkError.badUrl }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            // Hier können Sie Ihren Request Body erstellen und als Daten im HTTPBody setzen
            let requestBody: [String: Any] = ["get_gemeinden": "get_gemeinden", "app": "app"]
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
           // print(request.httpBody);
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { throw NetworkError.badResponse }
            
            guard (200..<300).contains(httpResponse.statusCode) else { throw NetworkError.badStatus }
           // print(data)
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
           // print(decodedResponse)
            return decodedResponse
        } catch {
            throw error
        }
    }
}
