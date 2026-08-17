import Foundation
import zlib

enum ZipArchiveHelper {
    static func createZip(from sourceDirectory: URL, to destinationURL: URL) throws {
        let files = try collectFiles(in: sourceDirectory, relativeTo: sourceDirectory)

        var localParts: [Data] = []
        var centralParts: [Data] = []
        var offset: UInt32 = 0

        for relativePath in files.sorted() {
            let fileURL = sourceDirectory.appendingPathComponent(relativePath)
            let fileData = try Data(contentsOf: fileURL)
            let crc = crc32Checksum(fileData)
            let nameData = Data(relativePath.utf8)

            var local = Data()
            local.appendUInt32(0x0403_4b50)
            local.appendUInt16(20)
            local.appendUInt16(0)
            local.appendUInt16(0)
            local.appendUInt16(0)
            local.appendUInt16(0)
            local.appendUInt32(crc)
            local.appendUInt32(UInt32(fileData.count))
            local.appendUInt32(UInt32(fileData.count))
            local.appendUInt16(UInt16(nameData.count))
            local.appendUInt16(0)
            local.append(nameData)
            local.append(fileData)

            var central = Data()
            central.appendUInt32(0x0201_4b50)
            central.appendUInt16(20)
            central.appendUInt16(20)
            central.appendUInt16(0)
            central.appendUInt16(0)
            central.appendUInt16(0)
            central.appendUInt16(0)
            central.appendUInt32(crc)
            central.appendUInt32(UInt32(fileData.count))
            central.appendUInt32(UInt32(fileData.count))
            central.appendUInt16(UInt16(nameData.count))
            central.appendUInt16(0)
            central.appendUInt16(0)
            central.appendUInt16(0)
            central.appendUInt16(0)
            central.appendUInt32(0)
            central.appendUInt32(offset)
            central.append(nameData)

            localParts.append(local)
            centralParts.append(central)
            offset += UInt32(local.count)
        }

        var archive = Data()
        for part in localParts { archive.append(part) }

        let centralDirectoryOffset = offset
        for part in centralParts {
            archive.append(part)
            offset += UInt32(part.count)
        }

        let centralDirectorySize = offset - centralDirectoryOffset

        var end = Data()
        end.appendUInt32(0x0605_4b50)
        end.appendUInt16(0)
        end.appendUInt16(0)
        end.appendUInt16(UInt16(files.count))
        end.appendUInt16(UInt16(files.count))
        end.appendUInt32(centralDirectorySize)
        end.appendUInt32(centralDirectoryOffset)
        end.appendUInt16(0)
        archive.append(end)

        try archive.write(to: destinationURL, options: .atomic)
    }

    static func unzip(from zipURL: URL, to destinationDirectory: URL) throws {
        let fileManager = FileManager.default
        let archiveData = try Data(contentsOf: zipURL)

        if fileManager.fileExists(atPath: destinationDirectory.path) {
            try fileManager.removeItem(at: destinationDirectory)
        }
        try fileManager.createDirectory(at: destinationDirectory, withIntermediateDirectories: true)

        var offset = 0
        while offset + 30 <= archiveData.count {
            let signature = archiveData.readUInt32(at: offset)
            guard signature == 0x0403_4b50 else { break }

            let compressionMethod = archiveData.readUInt16(at: offset + 8)
            let compressedSize = Int(archiveData.readUInt32(at: offset + 18))
            let uncompressedSize = Int(archiveData.readUInt32(at: offset + 22))
            let nameLength = Int(archiveData.readUInt16(at: offset + 26))
            let extraLength = Int(archiveData.readUInt16(at: offset + 28))

            let nameStart = offset + 30
            let nameEnd = nameStart + nameLength
            guard nameEnd <= archiveData.count else { break }

            let relativePath = String(data: archiveData[nameStart..<nameEnd], encoding: .utf8) ?? ""
            let dataStart = nameEnd + extraLength
            let dataEnd = dataStart + compressedSize
            guard dataEnd <= archiveData.count else { break }

            let payload = archiveData[dataStart..<dataEnd]
            let outputURL = destinationDirectory.appendingPathComponent(relativePath)
            try fileManager.createDirectory(
                at: outputURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            if compressionMethod == 0 {
                try Data(payload).write(to: outputURL, options: .atomic)
            } else {
                throw ZipArchiveError.unsupportedCompression
            }

            _ = uncompressedSize
            offset = dataEnd
        }
    }

    private static func collectFiles(in directory: URL, relativeTo root: URL) throws -> [String] {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }

        var paths: [String] = []
        for case let fileURL as URL in enumerator {
            let values = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
            guard values.isRegularFile == true else { continue }
            let relative = fileURL.path.replacingOccurrences(of: root.path + "/", with: "")
            paths.append(relative)
        }
        return paths
    }

    private static func crc32Checksum(_ data: Data) -> UInt32 {
        data.withUnsafeBytes { buffer in
            guard let base = buffer.baseAddress else { return 0 }
            return UInt32(crc32(0, base.assumingMemoryBound(to: Bytef.self), uInt(buffer.count)))
        }
    }
}

enum ZipArchiveError: LocalizedError {
    case unsupportedCompression

    var errorDescription: String? {
        switch self {
        case .unsupportedCompression: L10n.string("backup.error.unsupportedArchive")
        }
    }
}

private extension Data {
    mutating func appendUInt16(_ value: UInt16) {
        var little = value.littleEndian
        Swift.withUnsafeBytes(of: &little) { append(contentsOf: $0) }
    }

    mutating func appendUInt32(_ value: UInt32) {
        var little = value.littleEndian
        Swift.withUnsafeBytes(of: &little) { append(contentsOf: $0) }
    }

    func readUInt16(at offset: Int) -> UInt16 {
        guard offset + 2 <= count else { return 0 }
        return subdata(in: offset..<(offset + 2)).withUnsafeBytes {
            UInt16(littleEndian: $0.load(as: UInt16.self))
        }
    }

    func readUInt32(at offset: Int) -> UInt32 {
        guard offset + 4 <= count else { return 0 }
        return subdata(in: offset..<(offset + 4)).withUnsafeBytes {
            UInt32(littleEndian: $0.load(as: UInt32.self))
        }
    }
}
