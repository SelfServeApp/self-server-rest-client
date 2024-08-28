//
//  StreamTest.swift
//  
//
//  Created by Edon Valdman on 7/18/24.
//

import Foundation

import OpenAPIRuntime
import SelfServerRESTClientStubs
import SelfServerRESTTypes

import SelfServerDTOs
import SelfServerHelperTypes
import SelfServerExtensions


extension SelfServerRESTClient {
    public func assetTransfer(
        _ transfer: SelfServeDTO.AssetTransfer
    ) async throws {
        let mappedStream = transfer.resourcesStream(options: nil, resourceHandler: nil)
            .map { data -> Components.RequestBodies.AssetTransfer.multipartFormPayload in
                switch data {
                case .assetChunk(let chunk, let assetID, let range, let assetName):
                    return .asset_chunk(
                        .init(
                            payload: .init(
                                headers: .init(
                                    X_hyphen_Asset_hyphen_ID: assetName, 
                                    Content_hyphen_Range: range.description
                                ),
                                body: .init(chunk)
                            ),
                            filename: assetName
                        )
                    )
                    
                case .assetComplete(let assetName, let assetSize):
                    return .asset_complete(
                        .init(
                            payload: .init(
                                headers: .init(
                                    X_hyphen_Asset_hyphen_ID: assetName
                                ),
                                body: .init("complete")
                            ),
                            filename: assetName
                        )
                    )
                }
            }
        
        let output = try await self._client.fileUploadTest(
            path: .init(libraryID: transfer.libraryID.uuidString),
            headers: .init(
                X_hyphen_Request_hyphen_Id: transfer.transferID.uuidString
            ),
            body: .multipartForm(MultipartBody(mappedStream, iterationBehavior: .single))
        )
        
        switch output {
        case .created:
            break
        case .clientError(let statusCode, let abortError),
                .serverError(let statusCode, let abortError):
            throw SelfServerError(abortError: abortError, statusCode: statusCode)
        case .undocumented(let statusCode, let payload):
            throw SelfServerError(statusCode: statusCode, payload: payload)
        }
    }
}
