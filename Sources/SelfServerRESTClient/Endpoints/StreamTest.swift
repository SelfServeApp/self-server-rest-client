//
//  StreamTest.swift
//  
//
//  Created by Edon Valdman on 7/18/24.
//

import Foundation

import OpenAPIRuntime

import SelfServerRESTTypes
import SelfServerTypes

extension SelfServerRESTClient {
    public func streamTest(
        libraryID: UUID,
        transferID: UUID,
        assetDataStream: AsyncThrowingStream<Data, Error>
    ) async throws {
        let mappedStream = assetDataStream
            .map { data -> Components.RequestBodies.AssetTransfer.multipartFormPayload in
                return .asset_chunk(
                    .init(
                        payload: .init(
                            headers: .init(
                                X_hyphen_Asset_hyphen_Name: "test",
                                // TODO: use new HTTPRanges package
                                Range: "bytes=0-"
                            ),
                            body: .init(data)
                        )
                    )
                )
            }
        
        let output = try await self._client.fileUploadTest(
            path: .init(libraryID: libraryID.uuidString),
            headers: .init(
//                Transfer_hyphen_Encoding: .chunked,
                X_hyphen_Request_hyphen_Id: transferID.uuidString
            ),
            body: .multipartForm(.init(mappedStream, iterationBehavior: .single))
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
