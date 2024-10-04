//
//  Client+newLibrary.swift
//  
//
//  Created by Edon Valdman on 9/8/24.
//

import Foundation

import OpenAPIRuntime
import SelfServerRESTTypes

import SelfServerHelperTypes

extension SelfServerRESTClient {
    public func newLibrary(
        _ library: SelfServerDTOs.NewLibrary
    ) async throws -> Components.Schemas.Library {
        let resp = try await self._client.newLibrary(
            .init(
                body: .json(
                    .init(
                        name: library.name,
                        deviceId: library.deviceID.uuidString
                    )
                )
            )
        )
        
        switch resp {
        case .created(let resp):
            switch resp.body {
            case .json(let body):
                return body
            }
            
        case .badRequest(let resp):
            throw SelfServerError(response: resp)
                ?? UnknownCodeError(status: .badRequest, response: resp)
            
        case .unauthorized(let resp):
            throw UnauthorizedRequestError(
                operationID: #function
                    .trimmingCharacters(in: .alphanumerics.inverted),
                response: resp
            )
            
        case .conflict(let resp):
            throw SelfServerError(conflict: resp)
            
        case .internalServerError(let resp):
            throw SelfServerError(response: resp)
                ?? UnknownCodeError(status: .internalServerError, response: resp)
            
        case .undocumented(let statusCode, let payload):
            throw UndocumentedResponseError(statusCode: .init(statusCode: statusCode), payload: payload)
        }
    }
}
