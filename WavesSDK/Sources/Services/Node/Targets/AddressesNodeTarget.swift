//
//  NodeAddressesService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya
import WavesSDKExtensionsUpdate

extension NodeService.Target {
    struct Addresses {
        enum Kind {
            /**
             Response:
             - Node.Model.AdddressBalance.self
             */
            case getAddressBalance(id: String)

            /**
             Response:
             - DomainLayer.DTO.AddressScriptInfo
             */
            case scriptInfo(id: String)

            case getData(address: String, key: String)
            
            case getDataRegExp(address: String, regexp: String)

            case getAddressesBalance(addresses: [String])
            
            case getValidateAddress(address: String)
        }

        var kind: Kind
        var nodeUrl: URL
    }
}

extension NodeService.Target.Addresses: NodeTargetType {
    fileprivate enum Constants {
        static let addresses = "addresses"
        static let balance = "balance"
        static let scriptInfo = "scriptInfo"
        static let validate = "validate"
    }

    var path: String {
        switch kind {
        case let .getAddressBalance(id):
            return Constants.addresses + "/" + Constants.balance + "/" + "\(id)".urlEscaped

        case let .scriptInfo(id):
            return Constants.addresses + "/" + Constants.scriptInfo + "/" + "\(id)".urlEscaped

        case let .getData(address, key):
            return Constants.addresses + "/" + "data" + "/" + address.urlEscaped + "/" + "\(key)".urlEscaped
            
        case let .getDataRegExp(address, _):
            return Constants.addresses + "/" + "data" + "/" + address.urlEscaped

        case .getAddressesBalance:
            return Constants.addresses + "/" + Constants.balance
            
        case let .getValidateAddress(address):
            return Constants.addresses + "/" + Constants.validate + "/" + "\(address)".urlEscaped
        
        }
    }

    var method: Moya.Method {
        switch kind {
        case .getAddressBalance, .scriptInfo, .getData, .getDataRegExp, .getValidateAddress:
            return .get
        case .getAddressesBalance:
            return .post
        }
    }

    var task: Task {
        switch kind {
        case .getAddressBalance, .scriptInfo, .getData, .getValidateAddress:
            return .requestParameters(parameters: ["r": "\(Date().timeIntervalSince1970)"],
                                      encoding: URLEncoding.default)
            
        case let .getDataRegExp(_, regexp):
            return .requestParameters(
                            parameters: [ "matches": regexp], encoding: URLEncoding.queryString)
            
        case let .getAddressesBalance(address):
            return .requestParameters(parameters: ["addresses": address],
                                      encoding: JSONEncoding.default)
        }
    }
}

// MARK: CachePolicyTarget

extension NodeService.Target.Addresses: CachePolicyTarget {
    var cachePolicy: URLRequest.CachePolicy {
        return .reloadIgnoringLocalAndRemoteCacheData
    }
}
