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
        self.node = nodePtr.memory
    }
    
    lazy var nodeValue: String = {
        let document = self.nodePtr.memory.doc
        let children = self.nodePtr.memory.children
        let textValue = xmlNodeListGetString(document, children, 1)
        defer { free(textValue) }
        
        guard let nodeString = String.fromCString(UnsafePointer<CChar>(textValue)) else { return "" }
        return nodeString
    }()
    
    func xpath(xpath: String) -> [HTMLNode] {
        let document = nodePtr.memory.doc
        let context = xmlXPathNewContext(document)
        defer { xmlXPathFreeContext(context) }
        
        if context == nil { return [] }
        context.memory.node = nodePtr
        
        let result = xmlXPathEvalExpression(xpath, context)
        defer { xmlXPathFreeObject(result) }
        
        if result == nil { return [] }
        
        let nodeSet = result.memory.nodesetval
        if nodeSet == nil || nodeSet.memory.nodeNr == 0 || nodeSet.memory.nodeTab == nil {
            return []
        }
        
        let size = Int(nodeSet.memory.nodeNr)
        let nodes: [HTMLNode] = [Int](0..<size).map {
            let node = nodeSet.memory.nodeTab[$0]
            return HTMLNode(node: node)
        }
        
        return nodes
    }
}

extension HTMLNode {
    func childrenOf() -> AnyGenerator<HTMLNode> {
        var node = nodePtr.memory.children
        
        return AnyGenerator() {
            if node == nil { return nil }
            defer { node = node.memory.next }
            return HTMLNode(node: node)
        }
    }
}

class HTMLDoc {
    final let documentPtr: htmlDocPtr
    
    init(data: NSData) {
        let cfEncoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)
        let cfEncodingAsString = CFStringConvertEncodingToIANACharSetName(cfEncoding)
        let cEncoding = CFStringGetCStringPtr(cfEncodingAsString, 0)
        
        // HTML_PARSE_RECOVER | HTML_PARSE_NOERROR | HTML_PARSE_NOWARNING
        let htmlParseOptions: CInt = 1 << 0 | 1 << 5 | 1 << 6
        self.documentPtr = htmlReadMemory(UnsafePointer<Int8>(data.bytes), CInt(data.length), nil, cEncoding, htmlParseOptions)
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
            let root = xmlDocGetRootElement(documentPtr)
            if root != nil {
                let node = HTMLNode(node: root)
                self._root = node
                return node
            }
            else {
                return nil
            }
        }
    }
}
