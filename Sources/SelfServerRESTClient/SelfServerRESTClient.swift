//
//  SelfServerRESTClient.swift
//  
//
//  Created by Edon Valdman on 7/15/24.
//

import Foundation

import OpenAPIRuntime
import OpenAPIAsyncHTTPClient

import SelfServerRESTClientStubs
import SelfServerRESTTypes
import SelfServerHelperTypes

import OpenAPISecuritySchemes

public final class SelfServerRESTClient: @unchecked Sendable {
    internal let _client: SelfServerOpenAPIClient
    
    /// The JWT token for the active session.
    public private(set) var sessionToken: String? = nil
    private var sessionTokenMiddleware: SessionTokenMiddleware
    
    public init(_ url: URL) {
        let transport = AsyncHTTPClientTransport()
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
