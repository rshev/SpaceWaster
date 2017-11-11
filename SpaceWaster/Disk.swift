//
//  Disk.swift
//  SpaceWaster
//
//  Created by asdfgh1 on 11/11/2017.
//  Copyright © 2017 Roman Shevtsov. All rights reserved.
//

import Foundation

enum Disk {

    static var fileManagerSystemFreeSize: String? {
        guard
            let attributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
            let freeSpaceSize = attributes[FileAttributeKey.systemFreeSize] as? Int64
        else {
            return nil
        }

        return freeSpaceSize.formattedAsDiskSpace
    }

    private static var urlResourceValues: URLResourceValues? {
        let url = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
        do {
            let values = try url.resourceValues(forKeys: [
                .volumeAvailableCapacityKey,
                .volumeAvailableCapacityForImportantUsageKey,
                .volumeAvailableCapacityForOpportunisticUsageKey,
            ])
            return values
        } catch {
            return nil
        }
    }

    static var urlVolumeAvailableCapacity: String? {
        return urlResourceValues?.volumeAvailableCapacity?.formattedAsDiskSpace
    }

    static var urlVolumeAvailableCapacityForImportantUsage: String? {
        return urlResourceValues?.volumeAvailableCapacityForImportantUsage?.formattedAsDiskSpace
    }

    static var urlVolumeAvailableCapacityForOpportunisticUsage: String? {
        return urlResourceValues?.volumeAvailableCapacityForOpportunisticUsage?.formattedAsDiskSpace
    }
}

private extension SignedInteger {
    var formattedAsDiskSpace: String {
        return ByteCountFormatter.string(fromByteCount: Int64(self), countStyle: .file)
    }
}
