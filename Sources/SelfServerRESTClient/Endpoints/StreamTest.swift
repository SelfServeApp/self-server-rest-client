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

extension SelfServeDTO.AssetTransfer.DigestKind {
    fileprivate func toSchema() -> Components.Schemas.AssetDigestKind {
        switch self {
        case .md5: .md5
        case .sha256: .sha256
        case .sha512: .sha512
        }
    }
}

extension SelfServerRESTClient {
    public func assetTransfer(
        _ transfer: SelfServeDTO.AssetTransfer
    ) async throws {
        let mappedStream = transfer.resourcesStream(options: nil, resourceHandler: nil)
            .map { data -> Components.RequestBodies.AssetTransfer.multipartFormPayload in
                switch data {
                case .assetChunk(let chunk, let range, let assetID, let assetName):
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
                    
                case .assetComplete(let assetID, let assetName, let digest):
                    return .asset_complete(
                        .init(
                            payload: .init(
                                headers: .init(
                                    X_hyphen_Asset_hyphen_ID: assetID
                                ),
                                body: .init(
                                    digest: Base64EncodedData(digest)
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
                X_hyphen_Request_hyphen_Id: transfer.transferID.uuidString,
                X_hyphen_Digest_hyphen_Kind: transfer.digestKind.toSchema()
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
