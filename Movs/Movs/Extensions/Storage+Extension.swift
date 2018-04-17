//
//  Storage+Extension.swift
//  Movs
//
//  Created by Jonathan Bijos on 01/03/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import Foundation
import Cache

extension Storage {
    class func shared() -> Storage? {
        guard let directory = try? FileManager.default.url(for: .documentDirectory,
                                                           in: .userDomainMask,
                                                           appropriateFor: nil,
                                                           create: true).appendingPathComponent("MyPreferences") else {
            return nil
        }
        let diskConfig = DiskConfig(
            name: "Floppy",
            expiry: .never,
            maxSize: 10000,
            directory: directory,
            protectionType: .complete
        )
        
        let memoryConfig = MemoryConfig(
            expiry: .date(Date().addingTimeInterval(2*60)),
            countLimit: 50,
            totalCostLimit: 0
        )
        return try? Storage(diskConfig: diskConfig, memoryConfig: memoryConfig)
    }
}
