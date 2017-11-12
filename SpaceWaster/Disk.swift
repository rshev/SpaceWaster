//
//  Disk.swift
//  SpaceWaster
//
//  Created by asdfgh1 on 11/11/2017.
//  Copyright © 2017 Roman Shevtsov. All rights reserved.
//

import Foundation

enum Disk {
    private static var documentsDirectory: String {
        return "\(NSHomeDirectory())/Documents"
    }

    static var documentsDirectoryUrl: URL {
        return URL(fileURLWithPath: documentsDirectory, isDirectory: true)
    }

    static var documentsDirectorySize: String? {
        do {
            return try FileManager.default
                .contentsOfDirectory(at: Disk.documentsDirectoryUrl, includingPropertiesForKeys: nil)
                .reduce(0, {
                    $0 + (urlResourceValues(url: $1)?.fileSize ?? 0)
                })
                .formattedAsDiskSpace
        }
        catch {
            return nil
        }
    }

    static func clearDocumentsDirectory() {
        do {
            try FileManager.default.contentsOfDirectory(at: Disk.documentsDirectoryUrl, includingPropertiesForKeys: nil).forEach({
                try FileManager.default.removeItem(at: $0)
            })
        }
        catch {}
    }

    private static func urlResourceValues(url: URL = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)) -> URLResourceValues? {
        do {
            let values = try url.resourceValues(forKeys: [
                .fileSizeKey,
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
        return urlResourceValues()?.volumeAvailableCapacity?.formattedAsDiskSpace
    }

    static var urlVolumeAvailableCapacityForImportantUsage: String? {
        return urlResourceValues()?.volumeAvailableCapacityForImportantUsage?.formattedAsDiskSpace
    }

    static var urlVolumeAvailableCapacityForOpportunisticUsage: String? {
        return urlResourceValues()?.volumeAvailableCapacityForOpportunisticUsage?.formattedAsDiskSpace
    }
}

private extension SignedInteger {
    var formattedAsDiskSpace: String {
        return ByteCountFormatter.string(fromByteCount: Int64(self), countStyle: .file)
    }
}
