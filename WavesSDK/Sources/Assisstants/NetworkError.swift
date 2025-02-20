//
//  NetworkError.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 23/11/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//
import Foundation
import Moya

private enum Constants {
    static let scriptErrorCode: Int = 307
    static let assetScriptErrorCode: Int = 308
    static let notFound: Int = 404
}

public enum NetworkError: Error, Equatable {
    
    case none
    case message(String)
    case notFound
    case internetNotWorking
    case serverError
    case scriptError
    
    public var isInternetNotWorking: Bool {
        switch self {
        case .internetNotWorking:
            return true
            
        default:
            return false
        }
    }
    
    public var isServerError: Bool {
        switch self {
        case .serverError:
            return true
            
        default:
            return false
        }
    }
    
// TODO: Library
//    public var text: String {
//        switch self {
//        case .message(let message):
//            return message
//
//        case .internetNotWorking:
//            return Localizable.Waves.General.Error.Title.noconnectiontotheinternet
//
//        default:
//            return Localizable.Waves.General.Error.Title.notfound
//        }
//    }
}

extension MoyaError {
    
    var error: Error? {
        switch self {
        case .underlying(let error, _):
            return error
            
        case .objectMapping(let error, _):
            return error
            
        case .encodableMapping(let error):
            return error
            
        case .parameterEncoding(let error):
            return error
            
        default:
            return nil
        }
    }
}

public extension NetworkError {
    
    static func error(by error: Error) -> NetworkError {
        
        switch error {
        case let error as NetworkError:
            return error
            
        case let moyaError as MoyaError:
            guard let response = moyaError.response else {
                
                if let error = moyaError.error {
                    return NetworkError.error(by: error)
                } else {
                    return NetworkError.notFound
                }
            }
            
            return NetworkError.error(response: response)
            
        case let urlError as NSError where urlError.domain == NSURLErrorDomain:
            
            switch urlError.code {
            case NSURLErrorBadURL:
                return NetworkError.serverError
                
            case NSURLErrorTimedOut:
                return NetworkError.internetNotWorking
                
            case NSURLErrorUnsupportedURL:
                return NetworkError.serverError
                
            case NSURLErrorCannotFindHost:
                return NetworkError.serverError
                
            case NSURLErrorCannotConnectToHost:
                return NetworkError.serverError
                
            case NSURLErrorNetworkConnectionLost:
                return NetworkError.serverError
                
            case NSURLErrorDNSLookupFailed:
                return NetworkError.serverError
                
            case NSURLErrorHTTPTooManyRedirects:
                return NetworkError.serverError
                
            case NSURLErrorResourceUnavailable:
                return NetworkError.serverError
                
            case NSURLErrorNotConnectedToInternet:
                return NetworkError.internetNotWorking
                
            case NSURLErrorBadServerResponse:
                return NetworkError.serverError
                
            default:
                return NetworkError.none
            }
            
        default:
            return NetworkError.none
        }
    }
    
    static func error(response: Moya.Response) -> NetworkError {
        
        if let error = error(data: response.data) {
            return error
        }
        
        switch response.statusCode {
        case Constants.notFound:
            return NetworkError.notFound
            
        default:
            return NetworkError.none
        }
    }
    
    
    static func error(data: Data) -> NetworkError? {
        
        var message: String? = nil
        let anyObject = try? JSONSerialization.jsonObject(with: data, options: [])
        
        if let anyObject = anyObject as? [String: Any] {
            
            if anyObject["error"] as? Int == Constants.scriptErrorCode {
                return NetworkError.scriptError
            }
            
            message = anyObject["message"] as? String
            
            if message == nil {
                message = anyObject["error"] as? String
            }
        }
        
        if let message = message {
            return NetworkError.message(message)
        }
        
        return nil
    }
    
}
