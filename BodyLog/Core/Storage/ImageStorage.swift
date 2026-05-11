import Foundation
import UIKit

enum ImageStorageError: Error {
    case encodingFailed
    case writeFailed(Error)
}

struct ImageStorage {
    static let shared = ImageStorage()

    private let fm = FileManager.default
    private let jpegQuality: CGFloat = 0.8

    private var documentsURL: URL {
        fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var trackersRoot: URL {
        documentsURL.appendingPathComponent("trackers", isDirectory: true)
    }

    /// 写入图片，返回相对路径（存进 Entry.photoLocalPath）。
    @discardableResult
    func save(_ image: UIImage, trackerId: UUID, entryId: UUID) throws -> String {
        guard let data = image.jpegData(compressionQuality: jpegQuality) else {
            throw ImageStorageError.encodingFailed
        }
        let dir = trackersRoot.appendingPathComponent(trackerId.uuidString, isDirectory: true)
        try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        let file = dir.appendingPathComponent("\(entryId.uuidString).jpg")
        do {
            try data.write(to: file, options: .atomic)
        } catch {
            throw ImageStorageError.writeFailed(error)
        }
        return "trackers/\(trackerId.uuidString)/\(entryId.uuidString).jpg"
    }

    func absoluteURL(forRelativePath relativePath: String) -> URL {
        documentsURL.appendingPathComponent(relativePath)
    }

    func load(relativePath: String) -> UIImage? {
        let url = absoluteURL(forRelativePath: relativePath)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    func delete(relativePath: String) throws {
        let url = absoluteURL(forRelativePath: relativePath)
        if fm.fileExists(atPath: url.path) {
            try fm.removeItem(at: url)
        }
    }

    func deleteAll(trackerId: UUID) throws {
        let dir = trackersRoot.appendingPathComponent(trackerId.uuidString, isDirectory: true)
        if fm.fileExists(atPath: dir.path) {
            try fm.removeItem(at: dir)
        }
    }
}
