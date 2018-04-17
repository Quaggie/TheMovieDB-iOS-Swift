//
//  Request.swift
//  Movs
//
//  Created by Jonathan Bijos on 28/02/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import UIKit

class Request: NSObject {
    private let timeoutInterval: TimeInterval = 30
    private let cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    private let headers = Headers()
    
    private enum HTTPMethod: String {
        case get = "GET"
    }
    
    private let urlString: String
    
    init(url: String) {
        urlString = url
    }
    
    func get<T: Decodable>(params: Params? = nil, completion: @escaping Response<T>) {
        var urlComponents = URLComponents(string: urlString)
        var items: [URLQueryItem] = []
        if let params = params {
            for (key,value) in params {
                items.append(URLQueryItem(name: key, value: value))
            }
        }
        items = items.filter{!$0.name.isEmpty}
        if !items.isEmpty {
            urlComponents?.queryItems = items
        }
        guard let url = urlComponents?.url else { return }
        print(url.absoluteString)
        
        var urlRequest = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        urlRequest.httpMethod = HTTPMethod.get.rawValue
        urlRequest.allHTTPHeaderFields = headers.values
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let httpURLResponse = response as? HTTPURLResponse, let data = data {
                switch httpURLResponse.statusCode {
                case 200...300:
                    let jsonDecoder = JSONDecoder()
                    do {
                        let model = try jsonDecoder.decode(T.self, from: data)
                        DispatchQueue.main.async {
                            completion(Result.success(model))
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(Result.error(ErrorModel.defaultModel))
                        }
                    }
                case 301...500:
                    let jsonDecoder = JSONDecoder()
                    do {
                        let errorModel = try jsonDecoder.decode(ErrorModel.self, from: data)
                        DispatchQueue.main.async {
                            completion(Result.error(errorModel))
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(Result.error(ErrorModel.defaultModel))
                        }
                    }
                default:
                    DispatchQueue.main.async {
                        completion(Result.error(ErrorModel.defaultModel))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(Result.error(ErrorModel.defaultModel))
                }
            }
        }.resume()
    }
}

