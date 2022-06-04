/**
 Copyright 2022 Maciej Swic
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this softwareand associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 IN THE SOFTWARE.
 */

import SwiftUI
import Network

@available(macOS 10.14, iOS 13.0, watchOS 5.0, tvOS 12.0, *)
public class NetworkMonitor: ObservableObject {
    public typealias MonitorStatus = (NetworkMonitor) -> Void
    
    public static var shared = NetworkMonitor()
    
    /// Whether low data mode is enabled
    @Published public private(set) var isConstrained = false
    /// Whether the current network path is considered expensive
    @Published public private(set) var isExpensive = false
    /// Whether iOS considers itself connected to a network
    @Published public private(set) var isAvailable = false
    /// Whether our server is reachable
    @Published public private(set) var isReachable = false
    @Published public private(set) var description = "NETWORK_INITIALIZING".localized
    
    var hostname: String
    var reachability: Reachability?
    
    public var whenChanged: MonitorStatus?
    
    private let monitor = NWPathMonitor()
    
    public convenience init(whenChanged: MonitorStatus? = nil) {
        self.init(hostname: "apple.com", whenChanged: whenChanged)
    }
    
    public init(hostname: String, whenChanged: MonitorStatus? = nil) {
        self.hostname = hostname
        self.reachability = try? Reachability(hostname: hostname)
        self.whenChanged = whenChanged
        
        monitor.pathUpdateHandler = { path in
            self.update(path: path)
        }
        
        monitor.start(queue: DispatchQueue.main)
        
        reachability?.whenReachable = { reachability in
            self.update(reachability: reachability)
        }
        
        reachability?.whenUnreachable = { reachability in
            self.update(reachability: reachability)
        }
        
        try? reachability?.startNotifier()
        
        updateDescription()
    }
    
    deinit {
        reachability?.stopNotifier()
    }
    
    private func update(reachability: Reachability) {
        let isReachable = reachability.connection != .unavailable
        
        if self.isReachable != isReachable {
            self.isReachable = isReachable
            
            updateDescription()
            
            self.whenChanged?(self)
        }
    }
    
    private func update(path: NWPath) {
        var hasChanges = false
        
        if self.isConstrained != path.isConstrained {
            self.isConstrained = path.isConstrained
            
            hasChanges = true
        }
        
        if self.isExpensive != path.isExpensive {
            self.isExpensive = path.isExpensive
            
            hasChanges = true
        }
        
        let isAvailable = path.status != .unsatisfied
        if self.isAvailable != isAvailable {
            self.isAvailable = isAvailable
            
            hasChanges = true
        }
        
        if hasChanges {
            updateDescription()
            
            self.whenChanged?(self)
        }
    }
    
    func updateDescription() {
        var description = isAvailable ? "NETWORK_REACHABLE".localized : "NETWORK_UNREACHABLE".localized
        
        description.append(isReachable ? " \("NETWORK_SERVER_REACHABLE".localized)" : isAvailable ? " \("NETWORK_SERVER_UNREACHABLE".localized)" : "")
        description.append(isConstrained ? " \("NETWORK_CONSTRAINED".localized)" : "")
        description.append(isExpensive ? " \("NETWORK_EXPENSIVE".localized)" : "")
        
        self.description = description
    }
}

extension EnvironmentValues {
    public var network: NetworkMonitor {
        NetworkMonitor.shared
    }
}
