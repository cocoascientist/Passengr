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
        
        let data = self.dataForRequest(request) ?? NSData()
        let headers = ["Content-Type": "text/html"]
        
        guard let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers) else {
            fatalError("Response could not be created")
        }
        
        client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client.urlProtocol(self, didLoad: data as Data)
        client.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        // all data return at once, nothing to do
    }
    
    private func dataForRequest(_ request: NSURLRequest) -> NSData? {
        let bundle = Bundle(for: self.dynamicType)
        guard let file = bundle.path(forResource: "test", ofType: "html") else {
            return nil
        }
        
        let data = NSData(contentsOfFile: file)
        return data
    }
}
