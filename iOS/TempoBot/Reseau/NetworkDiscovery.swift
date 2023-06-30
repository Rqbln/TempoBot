//
//  NetworkDiscovery.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 11/06/2023.
//

import Foundation
import Network

class NetworkServiceDiscovery: NSObject, ObservableObject {
    private var serviceBrowser: NetServiceBrowser?
    @Published private var addresses = [String]()

    func startDiscovery() {
        serviceBrowser = NetServiceBrowser()
        serviceBrowser?.delegate = self
        serviceBrowser?.searchForServices(ofType: "_http._tcp.", inDomain: "local.") // changez ceci en fonction du type de service que vous recherchez
    }

    func stopDiscovery() {
        serviceBrowser?.stop()
        serviceBrowser = nil
    }

    func getAddresses() -> [String] {
        return addresses
    }
}

extension NetworkServiceDiscovery: NetServiceBrowserDelegate {
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        service.delegate = self
        service.resolve(withTimeout: 5.0)
    }
}

extension NetworkServiceDiscovery: NetServiceDelegate {
    func netServiceDidResolveAddress(_ sender: NetService) {
        let address = sender.addresses?.compactMap({ (data: Data) -> String? in
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> Void in
                let sockaddrPtr = pointer.bindMemory(to: sockaddr.self).baseAddress!

                if sockaddrPtr.pointee.sa_family == UInt8(AF_INET) {
                    var addr4 = sockaddrPtr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee }
                    _ = inet_ntop(AF_INET, &(addr4.sin_addr), &hostname, socklen_t(NI_MAXHOST))
                } else if sockaddrPtr.pointee.sa_family == UInt8(AF_INET6) {
                    var addr6 = sockaddrPtr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { $0.pointee }
                    _ = inet_ntop(AF_INET6, &(addr6.sin6_addr), &hostname, socklen_t(NI_MAXHOST))
                }
            }
            return String(cString: hostname)
        })
        
        if let address = address?.first {
            addresses.append(address)
        }
    }
}



