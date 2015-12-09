//
//  LocalURLProtocol.swift
//  Passengr
//
//  Created by Andrew Shepard on 4/13/15.
//  Copyright (c) 2015 Andrew Shepard. All rights reserved.
//

import Foundation

class LocalURLProtocol: NSURLProtocol {
    override class func canInitWithRequest(request: NSURLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
        return request
    }
    
    override func startLoading() {
        guard let client = self.client else { fatalError("Client is missing") }
        guard let url = request.URL else { fatalError("URL is missing") }
        
        let data = self.dataForRequest(request) ?? NSData()
        let headers = ["Content-Type": "text/html"]
        guard let response = NSHTTPURLResponse(URL: url, statusCode: 200, HTTPVersion: "HTTP/1.1", headerFields: headers) else {
            fatalError("Response could not be created")
        }
        
        client.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: .NotAllowed)
        client.URLProtocol(self, didLoadData: data)
        client.URLProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        // all data return at once, nothing to do
    }
    
    private func dataForRequest(request: NSURLRequest) -> NSData? {
        let bundle = NSBundle(forClass: self.dynamicType)
        guard let file = bundle.pathForResource("test", ofType: "html") else {
            return nil
        }
        
        let data = NSData(contentsOfFile: file)
        return data
    }
}
