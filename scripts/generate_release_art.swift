import Foundation
import CoreGraphics
import ImageIO

// Preserve Android's established artwork; only resize its existing logo for iOS.
let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let logoSource = CGImageSourceCreateWithURL(root.appendingPathComponent("assets/images/app_logo.png") as CFURL, nil)!
let logo = CGImageSourceCreateImageAtIndex(logoSource, 0, nil)!
let directory = root.appendingPathComponent("ios/Runner/Assets.xcassets/AppIcon.appiconset")
let contents = try Data(contentsOf: directory.appendingPathComponent("Contents.json"))
let catalog = try JSONSerialization.jsonObject(with: contents) as! [String: Any]
for item in catalog["images"] as! [[String: String]] {
    let points = Double(item["size"]!.components(separatedBy: "x")[0])!
    let scale = Double(item["scale"]!.replacingOccurrences(of: "x", with: ""))!
    let size = Int(points * scale)
    let context = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8,
        bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    context.interpolationQuality = .high
    context.draw(logo, in: CGRect(x: 0, y: 0, width: size, height: size))
    let output = CGImageDestinationCreateWithURL(
        directory.appendingPathComponent(item["filename"]!) as CFURL, "public.png" as CFString, 1, nil)!
    CGImageDestinationAddImage(output, context.makeImage()!, nil)
    precondition(CGImageDestinationFinalize(output))
}
