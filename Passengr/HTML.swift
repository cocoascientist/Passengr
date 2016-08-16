//
//  HTML.swift
//  Passengr
//
//  Created by Andrew Shepard on 11/17/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import Foundation

class HTMLNode {
    private let nodePtr: xmlNodePtr
    private let node: xmlNode
    
    init(node nodePtr: xmlNodePtr) {
        self.nodePtr = nodePtr
        self.node = nodePtr.pointee
    }
    
    lazy var nodeValue: String = {
        let document = self.nodePtr.pointee.doc
        let children = self.nodePtr.pointee.children
        guard let textValue = xmlNodeListGetString(document, children, 1) else { return "" }
        defer { free(textValue) }
        
        let value = textValue.withMemoryRebound(to: CChar.self, capacity: 1) {
            return String(validatingUTF8: $0)
        }
        
        guard value != nil else { return  "" }
        
        return value!
    }()
    
    func xpath(xpath: String) -> [HTMLNode] {
        let document = nodePtr.pointee.doc
        guard let context = xmlXPathNewContext(document) else { return [] }
        defer { xmlXPathFreeContext(context) }
        
        context.pointee.node = nodePtr
        
        guard let result = xmlXPathEvalExpression(xpath, context) else { return [] }
        defer { xmlXPathFreeObject(result) }
        
        guard let nodeSet = result.pointee.nodesetval else { return [] }
        if nodeSet.pointee.nodeNr == 0 || nodeSet.pointee.nodeTab == nil {
            return []
        }
        
        let size = Int(nodeSet.pointee.nodeNr)
        let nodes: [HTMLNode] = [Int](0..<size).map {
            let node = nodeSet.pointee.nodeTab[$0]
            return HTMLNode(node: node!)
        }
        
        return nodes
    }
}

class HTMLDoc {
    final let documentPtr: htmlDocPtr
    
    init(data: NSData) {
        let cfEncoding = CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue)
        let cfEncodingAsString = CFStringConvertEncodingToIANACharSetName(cfEncoding)
        let cEncoding = CFStringGetCStringPtr(cfEncodingAsString, 0)
        
        // HTML_PARSE_RECOVER | HTML_PARSE_NOERROR | HTML_PARSE_NOWARNING
        let htmlParseOptions: CInt = 1 << 0 | 1 << 5 | 1 << 6
        
        let bytes = data.bytes.assumingMemoryBound(to: Int8.self)
        self.documentPtr = htmlReadMemory(bytes, CInt(data.length), nil, cEncoding, htmlParseOptions)
    }
    
    deinit {
        xmlFreeDoc(documentPtr)
        self._root = nil
    }
    
    private weak var _root: HTMLNode?
    var root: HTMLNode? {
        if let root = _root {
            return root
        }
        else {
            guard let root = xmlDocGetRootElement(documentPtr) else { return nil }
            let node = HTMLNode(node: root)
            self._root = node
            return node
        }
    }
}
