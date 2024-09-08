//
//  SessionAuthenticationMiddleware.swift
//
//
//  Created by Edon Valdman on 7/17/24.
//

import Foundation

import OpenAPIRuntime
import OpenAPISecuritySchemes

/// A client middleware that injects a value into the `Authorization` header field of the request.
package struct SessionTokenSecurityScheme: BearerHTTPSecurityScheme {
    package static let bearerFormat: HTTPSecuritySchemeName.BearerFormat? = .jwt
    
    package let accessToken: String
    
    package init(_ sessionToken: String) {
        self.accessToken = sessionToken
    }
}

package struct SessionTokenMiddleware: SecuritySchemeMiddleware {
    package weak var delegate: (any SecuritySchemeMiddlewareDelegate)? = nil
    
    package init() {
    }
}
