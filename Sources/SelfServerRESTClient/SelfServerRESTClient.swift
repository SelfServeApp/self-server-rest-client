//
//  SelfServerRESTClient.swift
//  
//
//  Created by Edon Valdman on 7/15/24.
//

import Foundation

import OpenAPIRuntime
import OpenAPIAsyncHTTPClient

import SelfServerRESTTypes
import OpenAPISecuritySchemes

import OpenAPIURLSession

public final class SelfServerRESTClient: @unchecked Sendable {
//    private let _urlSession: URLSession = {
//        let config = URLSessionConfiguration.default
//        config.waitsForConnectivity = false
//        return .init(configuration: config)
//    }()
    
    internal let _client: Client
    
    /// The JWT token for the active session.
    public private(set) var sessionToken: String? = nil
    private var sessionTokenMiddleware: SessionTokenMiddleware
    
    public init(_ url: URL) {
//        let transport = AsyncHTTPClientTransport()
        let transport = URLSessionTransport(
//            configuration: .init(session: _urlSession)
        )
        self.sessionTokenMiddleware = .init()
        
        self._client = .init(
            serverURL: url,
            transport: transport,
            middlewares: [
                self.sessionTokenMiddleware,
            ]
        )
        
        self.sessionTokenMiddleware.delegate = self
    }
    
    private let _authlessOperationIDs: [String] = [
    ]
    
    public func clearSessionToken() {
        self.sessionToken = nil
    }
        
    public func setSessionToken(_ token: String) {
        self.sessionToken = token
    }
}

extension SelfServerRESTClient: SecuritySchemeMiddlewareDelegate {
    public func securityScheme(
        _ middleware: any SecuritySchemeMiddleware,
        forOperation operationId: String
    ) -> (any SecurityScheme)? {
        // If it's not an "authless" operation, and there is a session token, apply the session token to the operation.
        guard !_authlessOperationIDs.contains(operationId),
              let sessionToken else { return nil }
        
        return SessionTokenSecurityScheme(sessionToken)
    }
}
