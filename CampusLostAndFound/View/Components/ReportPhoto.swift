import UIKit
import ImageIO

enum ReportPhoto {
    // Downsample before decoding so large library images do not remain full-size in memory.
    static func prepare(_ data: Data) -> Data? {
        let options: NSDictionary = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: 1600
        ]
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }
        return UIImage(cgImage: thumbnail).jpegData(compressionQuality: 0.75)
    }
}
