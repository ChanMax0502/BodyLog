import Foundation
import UIKit

actor ThumbnailCache {
    static let shared = ThumbnailCache()

    private let memory: NSCache<NSString, UIImage> = {
        let c = NSCache<NSString, UIImage>()
        c.countLimit = 100
        return c
    }()
    private let fm = FileManager.default
    private let side: CGFloat = 144

    private var diskRoot: URL {
        let caches = fm.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return caches.appendingPathComponent("thumbnails", isDirectory: true)
    }

    func thumbnail(trackerId: UUID, entryId: UUID, source sourceURL: URL) async -> UIImage? {
        let key = "\(trackerId.uuidString)_\(entryId.uuidString)" as NSString
        if let cached = memory.object(forKey: key) {
            return cached
        }
        let diskURL = diskRoot.appendingPathComponent("\(key).jpg")
        if let data = try? Data(contentsOf: diskURL), let img = UIImage(data: data) {
            memory.setObject(img, forKey: key)
            return img
        }
        guard let original = UIImage(contentsOfFile: sourceURL.path) else { return nil }
        let thumb = original.downscaled(to: CGSize(width: side, height: side))
        try? fm.createDirectory(at: diskRoot, withIntermediateDirectories: true)
        if let data = thumb.jpegData(compressionQuality: 0.8) {
            try? data.write(to: diskURL, options: .atomic)
        }
        memory.setObject(thumb, forKey: key)
        return thumb
    }

    func invalidate(trackerId: UUID, entryId: UUID) {
        let key = "\(trackerId.uuidString)_\(entryId.uuidString)" as NSString
        memory.removeObject(forKey: key)
        let diskURL = diskRoot.appendingPathComponent("\(key).jpg")
        try? fm.removeItem(at: diskURL)
    }
}

private extension UIImage {
    func downscaled(to target: CGSize) -> UIImage {
        let scale = max(target.width / size.width, target.height / size.height)
        let scaled = CGSize(width: size.width * scale, height: size.height * scale)
        let origin = CGPoint(x: (target.width - scaled.width) / 2, y: (target.height - scaled.height) / 2)
        let renderer = UIGraphicsImageRenderer(size: target)
        return renderer.image { _ in
            draw(in: CGRect(origin: origin, size: scaled))
        }
    }
}
