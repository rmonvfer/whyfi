//
//  GatewayResolver.swift
//  OpenWhyFi
//
//  Created by Ramon on 1/28/26.
//

import Foundation
import SystemConfiguration

actor GatewayResolver {
    func getDefaultGateway() -> String? {
        guard let store = SCDynamicStoreCreate(nil, "OpenWhyFi" as CFString, nil, nil) else {
            return nil
        }

        guard let globalState = SCDynamicStoreCopyValue(store, "State:/Network/Global/IPv4" as CFString) as? [String: Any] else {
            return nil
        }

        guard let routerIP = globalState["Router"] as? String else {
            return nil
        }

        return routerIP
    }
}
