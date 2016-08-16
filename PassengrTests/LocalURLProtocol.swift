//
//  LocalURLProtocol.swift
//  Passengr
//
//  Created by Andrew Shepard on 4/13/15.
//  Copyright (c) 2015 Andrew Shepard. All rights reserved.
//

import Foundation

class LocalURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let client = self.client else { fatalError("Client is missing") }
        guard let url = request.url else { fatalError("URL is missing") }
        
        let data = self.dataFor(request: request) ??  Data()
        let headers = ["Content-Type": "text/html"]
        
        guard let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers) else {
            fatalError("Response could not be created")
        }
        
        client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client.urlProtocol(self, didLoad: data)
        client.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        // all data return at once, nothing to do
    }
    
    private func dataFor(request: URLRequest) -> Data? {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "test", withExtension: "html") else {
            return nil
        }
        
        let data = try! Data(contentsOf: url)
        return data
    }
}
