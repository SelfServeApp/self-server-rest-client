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
    internal init(abortError: Components.Responses.AbortError, statusCode: HTTPResponseStatus) {
        guard let errorCodeInt = abortError.headers.X_hyphen_Self_hyphen_Server_hyphen_Error_hyphen_Code,
              let errorCode = SelfServerErrorCode(rawValue: UInt(errorCodeInt)) else {
            self.init(statusCode: Int(statusCode.code), payload: .init())
            return
        }
        
        self.init(abortCode: errorCode, reason: try? abortError.body.json.reason)
    }
    
    internal init(abortError: Components.Responses.AbortError, statusCode: Int) {
        self.init(abortError: abortError, statusCode: .init(statusCode: statusCode))
    }
}
