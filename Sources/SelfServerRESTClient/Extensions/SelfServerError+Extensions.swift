//
//  SelfServerError+Extensions.swift
//
//
//  Created by Edon Valdman on 8/27/24.
//

import Foundation
import SelfServerHelperTypes
import SelfServerRESTTypes

import NIOHTTP1

extension SelfServerError {
    /// A convenience initializer from a `401UnauthorizedResponse` response, which should have a `401`/`Unauthorized` status code.
    internal init(error401 response: Components.Responses._401UnauthorizedResponse) {
        self.init(unauthorized401: response.headers.WWW_hyphen_Authenticate)
    }
    
    /// A convenience initializer from a `GeneralError` response, which should have a `500`/`Internal Server Error` status code.
    internal init(error403 response: Components.Responses._403ForbiddenResponse) {
        guard let errorCodeInt = response.headers.X_hyphen_Self_hyphen_Server_hyphen_Error_hyphen_Code,
              let errorCode = SelfServerErrorCode(rawValue: UInt(errorCodeInt)) else {
            self.init(statusCode: .unauthorized, payload: .init())
            return
        }
        
        self.init(forbidden403: errorCode, reason: try? response.body.json.reason)
    }
    
    /// A convenience initializer from a `GeneralError` response, which should have a `500`/`Internal Server Error` status code.
    internal init(error500 response: Components.Responses.GeneralError) {
        guard let errorCodeInt = response.headers.X_hyphen_Self_hyphen_Server_hyphen_Error_hyphen_Code,
              let errorCode = SelfServerErrorCode(rawValue: UInt(errorCodeInt)) else {
            self.init(statusCode: .internalServerError, payload: .init())
            return
        }
        
        self.init(abort500: errorCode, reason: try? response.body.json.reason)
    }
}
