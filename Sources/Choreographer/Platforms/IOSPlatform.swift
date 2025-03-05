//
//  Created by Cyandev on 2025/3/5.
//  Copyright (c) 2025 Cyandev. All rights reserved.
//

#if os(iOS) || os(tvOS)
import QuartzCore

class IOSDriver: NSObject, VSyncDriver {
    
    struct Request { }
    
    private var displayLink: CADisplayLink?
    private var callback: ((VSyncEventContext) -> Void)?
    
    required init(request: Request) throws {
        super.init()
    }
    
    func isCompatible(with request: Request) -> Bool {
        return true
    }
    
    func attach(_ callback: @escaping (VSyncEventContext) -> Void) throws {
        self.callback = callback
        let displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLinkEvent))
        displayLink.add(to: .main, forMode: .common)
        self.displayLink = displayLink
    }
    
    func detach() throws {
        displayLink?.invalidate()
        displayLink = nil
        callback = nil
    }
    
    @objc private func handleDisplayLinkEvent() {
        if let callback, let displayLink {
            callback(.init(targetTimestamp: displayLink.targetTimestamp))
        }
    }
}

public extension VSyncObserver {
    
    /// Creates an observer with the default configuration.
    convenience init() throws {
        self.init(__internal: ())
        
        try VSyncDriverManager.shared.addObserver(self, with: .init())
    }
}
#endif
