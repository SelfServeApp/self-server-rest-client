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
    internal init(errorResponse response: Components.Responses.GeneralError, statusCode: HTTPResponseStatus) {
        guard let errorCodeInt = response.headers.X_hyphen_Self_hyphen_Server_hyphen_Error_hyphen_Code,
              let errorCode = SelfServerErrorCode(rawValue: UInt(errorCodeInt)) else {
            self.init(statusCode: Int(statusCode.code), payload: .init())
            return
        }
        
        self.init(abortCode: errorCode, reason: try? response.body.json.reason)
    }
    
    internal init(errorResponse response: Components.Responses.GeneralError, statusCode: Int) {
        self.init(errorResponse: response, statusCode: .init(statusCode: statusCode))
    }
}
