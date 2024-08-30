//
//  StreamTest.swift
//  
//
//  Created by Edon Valdman on 7/18/24.
//

import Foundation

import OpenAPIRuntime
import SelfServerRESTTypes

import SelfServerDTOs
import SelfServerHelperTypes

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
                                    X_hyphen_Asset_hyphen_ID: assetID,
                                    Content_hyphen_Range: range.description
                                ),
                                body: .init(chunk)
                            ),
                            filename: assetName
                        )
                    )
                    
                case .assetComplete(let assetID, let digest, let digestKind, let assetName):
                    let kind: Components.Schemas.AssetCompletePart.digestKindPayload = switch digestKind {
                    case .md5: .md5
                    case .sha256: .sha256
                    case .sha512: .sha512
                    }
                    
                    return .asset_complete(
                        .init(
                            payload: .init(
                                headers: .init(
                                    X_hyphen_Asset_hyphen_ID: assetID
                                ),
                                body: .init(
                                    digest: digest,
                                    digestKind: kind
                                )
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
        case .ok:
            break
        case .clientError(let statusCode, let abortError),
                .serverError(let statusCode, let abortError):
            throw SelfServerError(abortError: abortError, statusCode: statusCode)
        case .undocumented(let statusCode, let payload):
            throw SelfServerError(statusCode: statusCode, payload: payload)
        }
    }
}
