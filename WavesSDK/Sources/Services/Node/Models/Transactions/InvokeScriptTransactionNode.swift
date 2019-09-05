//
//  InvokeScriptTransactionNode.swift
//  Alamofire
//
//  Created by rprokofev on 07/05/2019.
//

import Foundation

extension NodeService.DTO {

    /**
      Invoke script transaction is a transaction that invokes functions of the dApp script.
      dApp contains compiled functions  developed with [Waves Ride IDE]({https://ide.wavesplatform.com/)
      You can invoke one of them by name with some arguments.
     */
    public struct InvokeScriptTransaction: Codable {

        /**
          Call the function from dApp (address or alias) with typed arguments
         */
        public struct Call: Codable {

            /**
              Arguments for the function call
             */
            public struct Args: Codable {
                public enum Value: Codable {
                    
                    private enum CodingKeys: String, CodingKey {
                        case integer
                        case bool
                        case string
                        case binary
                    }
                    
                    public init(from decoder: Decoder) throws {
                        let values = try decoder.container(keyedBy: CodingKeys.self)
                        
                        if let value = try? values.decode(Int64.self, forKey: .integer) {
                            self = .integer(value)
                            return
                        }
                        
                        if let value = try? values.decode(String.self, forKey: .string) {
                            self = .string(value)
                            return
                        }
                        
                        if let value = try? values.decode(String.self, forKey: .binary) {
                            self = .binary(value)
                            return
                        }
                        
                        if let value = try? values.decode(Bool.self, forKey: .bool) {
                            self = .bool(value)
                            return
                        }
                        
                        throw NSError(domain: "Decoder Invalid", code: 0, userInfo: nil)
                    }
                    
                    public func encode(to encoder: Encoder) throws {
                        
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        switch self {
                        case .integer(let value):
                            try container.encode(value, forKey: .integer)
                            
                        case .string(let value):
                            try container.encode(value, forKey: .string)
                            
                        case .bool(let value):
                            try container.encode(value, forKey: .bool)
                            
                        case .binary(let value):
                            try container.encode(value, forKey: .binary)
                        }
                    }
                    
                    case bool(Bool)
                    case integer(Int64)
                    case string(String)
                    case binary(String)
                }
                
                public let type: String
                public let value: Value

                public init(type: String, value: Value) {
                    self.type = type
                    self.value = value
                }
            }

            /**
              Function unique name
              */
            public let function: String

            /**
              List of arguments
              */
            public let args: [Args]

            public init(function: String, args: [Args]) {
                self.function = function
                self.args = args
            }
        }

        /**
          Payment for function of dApp. Now it works with only one payment.
         */
        public struct Payment: Codable {
            /**
              Amount in satoshi
             */
            public let amount: Int64
            /**
              Asset Id in Waves blockchain
             */
            public let assetId: String?

            public init(amount: Int64, assetId: String?) {
                self.amount = amount
                self.assetId = assetId
            }
        }
        
        public let type: Int
        public let id: String
        public let chainId: String?
        public let sender: String
        public let senderPublicKey: String
        public let fee: Int64

        public let timestamp: Date
        public let proofs: [String]?
        public let version: Int

        public let height: Int64?

        /**
          Asset id instead Waves for transaction commission withdrawal
         */
        public let feeAssetId: String?

        /**
          dApp – address or alias of contract with function on RIDE language
         */
        public let dApp: String

        /**
          Function name in dApp with array of arguments
         */
        public let call: Call?

        /**
          Payments for function of dApp. Now it works with only one payment.
         */
        public let payment: [Payment]

        public init(type: Int, id: String, chainId: String?, sender: String, senderPublicKey: String, fee: Int64, timestamp: Date, proofs: [String]?, version: Int, height: Int64?, feeAssetId: String?, dApp: String, call: Call?, payment: [Payment]) {
            self.type = type
            self.id = id
            self.chainId = chainId
            self.sender = sender
            self.senderPublicKey = senderPublicKey
            self.fee = fee
            self.timestamp = timestamp
            self.proofs = proofs
            self.version = version
            self.height = height
            self.feeAssetId = feeAssetId
            self.dApp = dApp
            self.call = call
            self.payment = payment
        }
    }
}

extension NodeService.DTO.InvokeScriptTransaction.Call.Args {
    
    enum CodingKeys: String, CodingKey {
        case type
        case value
    }
    
    enum ValueKey: String {
        case boolean
        case integer
        case string
        case binary
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let value = try container.decodeIfPresent(String.self, forKey: .type) {
            type = value
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath,
                                                                    debugDescription: "Not found type"))
        }
        
        if let type = ValueKey(rawValue: self.type) {
            switch type {
            case .boolean:
                value = .bool(try container.decode(Bool.self, forKey: .value))
            case .integer:
                value = .integer(try container.decode(Int64.self, forKey: .value))
            case .string:
                value = .string(try container.decode(String.self, forKey: .value))
            case .binary:
                value = .binary(try container.decode(String.self, forKey: .value))
            }
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath,
                                                                    debugDescription: "Not found value"))
        }
    }
}

