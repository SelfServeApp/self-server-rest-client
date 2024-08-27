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
import SelfServerHelperTypes

public enum FileTransferData: Hashable, Sendable {
    case assetChunk(Data, assetName: String, range: ClosedRange<Int>)
    case assetComplete(assetName: String, assetSize: Int64)
}

extension SelfServerRESTClient {
    public func streamTest<S: AsyncSequence>(
        libraryID: UUID,
        transferID: UUID,
        assetDataStream: S
    ) async throws where S.Element == FileTransferData, S: Sendable {
        let mappedStream = assetDataStream
            .map { data -> Components.RequestBodies.AssetTransfer.multipartFormPayload in
                switch data {
                case .assetChunk(let chunk, let assetName, let range):
                    return .asset_chunk(
                        .init(
                            payload: .init(
                                headers: .init(
                                    X_hyphen_Asset_hyphen_Name: assetName,
                                    Range: "bytes=\(range.lowerBound)-\(range.upperBound)"
                                ),
                                body: .init(chunk)
                            )
                        )
                    )
                    
                case .assetComplete(let assetName, let assetSize):
                    return .asset_complete(
                        .init(
                            payload: .init(
                                headers: .init(
                                    X_hyphen_Asset_hyphen_Name: assetName,
                                    Content_hyphen_Length: assetSize
                                ),
                                body: .init("complete")
                            )
                        )
                    )
                }
            }
        
        let output = try await self._client.fileUploadTest(
            path: .init(libraryID: libraryID.uuidString),
            headers: .init(
                X_hyphen_Request_hyphen_Id: transferID.uuidString
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
