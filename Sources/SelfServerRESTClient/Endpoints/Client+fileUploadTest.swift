//
//  Client+fileUploadTest.swift
//  
//
//  Created by Edon Valdman on 7/18/24.
//

import Foundation

import OpenAPIRuntime
import SelfServerRESTTypes

import SelfServerHelperTypes

extension SelfServerDTOs.FileUploadTest.DigestKind {
    fileprivate func toSchema() -> Components.Schemas.AssetDigestKind {
        switch self {
        case .md5: .md5
        case .sha256: .sha256
        case .sha512: .sha512
        }
    }
}

extension SelfServerRESTClient {
    public func fileUploadTest(
        _ transfer: SelfServerDTOs.FileUploadTest
    ) async throws -> Components.Schemas.AssetTransferResponseBody {
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
        case .ok(let resp):
            switch resp.body {
            case .json(let body):
                return body
            }
            
        case .badRequest(let resp):
            throw SelfServerError(response: resp)
                ?? UnknownCodeError(status: .badRequest, response: resp)
            
        case .unauthorized(let resp):
            throw UnauthorizedRequestError(operationID: "fileUploadTest", response: resp)
            
        case .forbidden(let resp):
            throw SelfServerError(response: resp)
                ?? UnknownCodeError(status: .forbidden, response: resp)
        
        case .internalServerError(let resp):
            throw SelfServerError(response: resp)
                ?? UnknownCodeError(status: .internalServerError, response: resp)
            
        case .undocumented(let statusCode, let payload):
            throw UndocumentedResponseError(statusCode: .init(statusCode: statusCode), payload: payload)
        }
    }
}
