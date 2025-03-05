//
//  Created by Cyandev on 2025/3/5.
//  Copyright (c) 2025 Cyandev. All rights reserved.
//

#if os(macOS)
import AppKit
import CoreVideo

class MacDriver: VSyncDriver {
    
    struct Request {
        
        let displayID: CGDirectDisplayID
    }
    
    struct CoreVideoError: Error {
        
        let code: CVReturn
    }
    
    private var displayLink: CVDisplayLink?
    private let displayID: CGDirectDisplayID
    
    required init(request: Request) throws {
        displayID = request.displayID
        
        let result = CVDisplayLinkCreateWithCGDisplay(displayID, &displayLink)
        guard result == kCVReturnSuccess, displayLink != nil else {
            throw CoreVideoError(code: result)
        }
    }
    
    func isCompatible(with request: Request) -> Bool {
        return displayID == request.displayID
    }
    
    func attach(_ callback: @Sendable @escaping (VSyncEventContext) -> Void) throws {
        guard let displayLink else {
            preconditionFailure("The display link should be created before this call")
        }
        
        var result = CVDisplayLinkSetOutputHandler(displayLink) { _, _, outputTime, _, _ in
            let targetTimestamp = outputTime.pointee
            callback(.init(
                targetTimestamp: Double(targetTimestamp.videoTime) / Double(targetTimestamp.videoTimeScale)
            ))
            return kCVReturnSuccess
        }
        guard result == kCVReturnSuccess else {
            throw CoreVideoError(code: result)
        }
        
        
        result = CVDisplayLinkStart(displayLink)
        guard result == kCVReturnSuccess else {
            throw CoreVideoError(code: result)
        }
    }
    
    func detach() throws {
        guard let displayLink else {
            preconditionFailure("The display link should be created before this call")
        }
        
        var result = CVDisplayLinkStop(displayLink)
        guard result == kCVReturnSuccess else {
            throw CoreVideoError(code: result)
        }
        
        result = CVDisplayLinkSetOutputHandler(displayLink) { _, _, _, _, _ in
            return kCVReturnSuccess
        }
        guard result == kCVReturnSuccess else {
            throw CoreVideoError(code: result)
        }
    }
}

public extension VSyncObserver {
    
    /// Creates an observer for the specified screen.
    ///
    /// - Parameter screen: The screen from which VSync events are received.
    convenience init(screen: NSScreen) throws {
        self.init(__internal: ())
        
        guard let displayID = screen.deviceDescription[.init("NSScreenNumber")] as? CGDirectDisplayID else {
            fatalError("Invalid screen configuration")
        }
        try VSyncDriverManager.shared.addObserver(self, with: .init(displayID: displayID))
    }
}
#endif
