//
//  ProductService.swift
//  InteriorQuoteApp_Swift
//
//  Created by Kirti Saumya Joshi on 16/5/2026.
//

import Foundation

class ProductService {

    func fetchWindowProducts(completion: @escaping ([Product]) -> Void) {

        guard let url = URL(string: "https://utasbot.dev/kit305_2026/product") else {
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in

            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }

            do {
                let response = try JSONDecoder().decode(ProductApiResponse.self, from: data)

                let windowProducts = response.data.filter {
                    $0.type.lowercased() == "window"
                }

                DispatchQueue.main.async {
                    completion(windowProducts)
                }

            } catch {
                print("Product decode error:", error)

                DispatchQueue.main.async {
                    completion([])
                }
            }

        }.resume()
    }
}
