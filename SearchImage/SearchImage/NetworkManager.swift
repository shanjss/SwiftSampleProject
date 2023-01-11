//
//  NetworkManage.swift
//  SearchImage
//
//  Created by Shantanu Barnawal on 10/1/2021.
//

import Foundation
import UIKit

enum NetworkError: Error {
  case invalidResponse(URLResponse?)
  case invalidData
  case invalidUrl
}

class NetworkManager {
    static var shared = NetworkManager()
    private init() { }

    let urlSession = URLSession(configuration: .default)

    private var imageCache = NSCache<NSString, UIImage>()

    func image(imageDetail: ImageEntity, completion: @escaping (UIImage?, Error?) -> (Void)) {
        let url = URL(string: imageDetail.link)!
        download(imageLink: url, completion: completion)
    }

    private func download(imageLink: URL, completion: @escaping (UIImage?, Error?) -> (Void)) {
        if let image = imageCache.object(forKey: imageLink.absoluteString as NSString) {
            completion(image as UIImage, nil)
            return
        }

        let task = urlSession.downloadTask(with: imageLink) { urlLink, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(nil, NetworkError.invalidResponse(response))
                return
            }

            guard let urlLink = urlLink else {
                completion(nil, NetworkError.invalidUrl)
                return
            }

            do {
                let data = try Data(contentsOf: urlLink)
                if let downloadedImage = UIImage(data: data) {
                    self.imageCache.setObject(downloadedImage, forKey: imageLink.absoluteString as NSString)
                    completion(downloadedImage, nil)
                } else {
                    completion(nil, NetworkError.invalidData)
                }
            } catch let error {
                completion(nil, error)
            }
        }
        task.resume()
    }

    func query(with input:String, completion:@escaping ([Gallery]?, Error?) -> Void) {
        // "​https://api.imgur.com/3/gallery/search/?q=cats​"
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.imgur.com"
        components.path = "/3/gallery/search/"
        components.queryItems = [URLQueryItem(name: "q", value: input)]
        
        let key = "b067d5cb828ec5a"
        var request = URLRequest(url: components.url!)
        request.addValue("Client-ID \(key)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(nil, NetworkError.invalidResponse(response))
                return
            }
            
            guard let data = data else {
                completion(nil, NetworkError.invalidData)
                return
            }
            
            do {
                let response = try JSONDecoder().decode(GalleryResponse.self, from: data)
                completion(response.data, nil)
            } catch let error {
                completion(nil, error)
            }
        }
        task.resume()
    }
}
