//
//  SelfServerError.swift
//
//
//  Created by Edon Valdman on 7/15/24.
//

import Foundation
import SelfServerTypes

import OpenAPIRuntime
import NIOHTTP1

public struct SelfServerError: LocalizedError, Hashable, Sendable/*, Codable*/ {
    private let _code: Code
    private init(code: Code) {
        self._code = code
    }
    
    public var errorDescription: String? {
        switch _code {
        case .abort(let errorCode, _):
            return "SelfServerError(code: \(errorCode))"
        case .undocumented(let statusCode, _):
            return "SelfServerError(code: \(statusCode.description))"
        }
    }
    
    public var failureReason: String? {
        switch _code {
        case .abort(let errorCode, let reason):
            return reason ?? errorCode.errorReason
        case .undocumented(let statusCode, _):
            return statusCode.reasonPhrase
        }
    }
    
    private enum Code: Hashable, Sendable {
        case abort(SelfServerErrorCode, reason: String?)
        case undocumented(statusCode: HTTPResponseStatus, payload: OpenAPIRuntime.UndocumentedPayload)
    }
}

extension SelfServerError {
    package init(abortError: Components.Responses.AbortError, statusCode: HTTPResponseStatus) {
        guard let errorCodeInt = abortError.headers.X_hyphen_Self_hyphen_Server_hyphen_Error_hyphen_Code,
              let errorCode = SelfServerErrorCode(rawValue: UInt(errorCodeInt)) else {
            self.init(
                code: .undocumented(
                    statusCode: statusCode,
                    payload: .init(
                    )
                )
            )
            return
        }
        
        self.init(code: .abort(errorCode, reason: try? abortError.body.json.reason))
    }
    
    package init(statusCode: HTTPResponseStatus, payload: OpenAPIRuntime.UndocumentedPayload) {
        self.init(code: .undocumented(statusCode: statusCode, payload: payload))
    }
}
