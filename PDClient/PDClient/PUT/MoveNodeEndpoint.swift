// Copyright (c) 2023 Proton AG
//
// This file is part of Proton Drive.
//
// Proton Drive is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Proton Drive is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Proton Drive. If not, see https://www.gnu.org/licenses/.

import Foundation

public struct MoveNodeParameters: Codable {
    public init(name: String,
                hash: String,
                parentLinkID: String,
                nodePassphrase: String,
                nodePassphraseSignature: String,
                signatureAddress: String,
                originalHash: String)
    {
        self.Name = name
        self.Hash = hash
        self.ParentLinkID = parentLinkID
        self.NodePassphrase = nodePassphrase
        self.NodePassphraseSignature = nodePassphraseSignature
        self.SignatureAddress = signatureAddress
        self.OriginalHash = originalHash
    }
    
    var Name: String
    var Hash: String
    var ParentLinkID: String
    var NodePassphrase: String
    var NodePassphraseSignature: String
    var SignatureAddress: String
    var OriginalHash: String
}

struct MoveNodeEndpoint: Endpoint {
    public struct Response: Codable {
        var code: Int
    }
    
    var request: URLRequest
    
    init(shareID: Share.ShareID, nodeID: Link.LinkID, parameters: MoveNodeParameters, service: APIService, credential: ClientCredential) {
        // url
        var url = service.url(of: "/shares")
        url.appendPathComponent(shareID)
        url.appendPathComponent("/links")
        url.appendPathComponent(nodeID)
        url.appendPathComponent("/move")
        
        // request
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        // headers
        var headers = service.baseHeaders
        headers.merge(service.authHeaders(credential), uniquingKeysWith: { $1 })
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        request.httpBody = try? JSONEncoder().encode(parameters)
        
        self.request = request
    }
}
