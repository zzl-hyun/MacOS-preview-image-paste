import AppKit
import Darwin
import Foundation
import ImageIO

let annotationPasteboardType = NSPasteboard.PasteboardType("com.apple.AnnotationKit.AnnotationItem")

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data(("Error: \(message)\n").utf8))
    exit(1)
}

class ArchiveAKAnnotation: NSObject, NSCoding {
    override init() { super.init() }
    required init?(coder: NSCoder) { super.init() }
    func encode(with coder: NSCoder) {}
}

final class ArchiveAKImageAnnotation: ArchiveAKAnnotation {
    let pngData: Data
    let width: Double
    let height: Double
    let scaleFactor: Double

    init(pngData: Data, pixelWidth: Int, pixelHeight: Int, scaleFactor: Double) {
        self.pngData = pngData
        self.scaleFactor = scaleFactor
        width = Double(pixelWidth) * scaleFactor
        height = Double(pixelHeight) * scaleFactor
        super.init()
    }

    required init?(coder: NSCoder) {
        pngData = Data()
        width = 0
        height = 0
        scaleFactor = 1
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        let rectangle = NSMutableDictionary()
        rectangle["Width"] = NSNumber(value: width)
        rectangle["Height"] = NSNumber(value: height)
        rectangle["Y"] = NSNumber(value: 0.0)
        rectangle["X"] = NSNumber(value: 0.0)

        coder.encode(false, forKey: "AKIsFormFieldKey")
        coder.encode(1, forKey: "akPlat")
        coder.encode(2, forKey: "akVers")
        coder.encode(nil as Any?, forKey: "customPlaceholderText")
        coder.encode(true, forKey: "editsDisableAppearanceOverride")
        coder.encode(0, forKey: "formContentType")
        coder.encode(false, forKey: "hasShadow")
        coder.encode(false, forKey: "horizontallyFlipped")
        coder.encode(NSMutableData(data: pngData), forKey: "imageAsData")
        coder.encode(1, forKey: "originalExifOrientation")
        coder.encode(scaleFactor, forKey: "originalModelBaseScaleFactor")
        coder.encode(rectangle, forKey: "rectangle")
        coder.encode(0.0, forKey: "rotationAngle")
        coder.encode(true, forKey: "shouldUsePlaceholderText")
        coder.encode(false, forKey: "textIsClipped")
        coder.encode(false, forKey: "textIsFixedHeight")
        coder.encode(false, forKey: "textIsFixedWidth")
        coder.encode(UUID().uuidString, forKey: "UUID")
        coder.encode(false, forKey: "verticallyFlipped")
    }
}

func imagePixelSize(from data: Data) -> (width: Int, height: Int) {
    guard
        let source = CGImageSourceCreateWithData(data as CFData, nil),
        let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
        let width = properties[kCGImagePropertyPixelWidth] as? NSNumber,
        let height = properties[kCGImagePropertyPixelHeight] as? NSNumber
    else { fail("Could not read the PNG dimensions.") }
    return (width.intValue, height.intValue)
}

func createAnnotationArchive(pngData: Data, pixelWidth: Int, pixelHeight: Int, scaleFactor: Double) -> Data {
    let annotation = ArchiveAKImageAnnotation(
        pngData: pngData,
        pixelWidth: pixelWidth,
        pixelHeight: pixelHeight,
        scaleFactor: scaleFactor
    )
    let output = NSMutableData()
    let archiver = NSKeyedArchiver(forWritingWith: output)
    archiver.requiresSecureCoding = false
    archiver.outputFormat = .binary
    archiver.setClassName("AKAnnotation", for: ArchiveAKAnnotation.self)
    archiver.setClassName("AKImageAnnotation", for: ArchiveAKImageAnnotation.self)
    archiver.encode(annotation, forKey: NSKeyedArchiveRootObjectKey)
    archiver.finishEncoding()
    return output as Data
}

func takeInteractiveScreenshot() {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
    process.arguments = ["-i", "-c", "-x"]
    do {
        try process.run()
        process.waitUntilExit()
    } catch { fail("Could not launch screencapture: \(error)") }
    if process.terminationStatus != 0 { fail("The screenshot was cancelled or failed.") }
}

if CommandLine.arguments.contains("--capture") { takeInteractiveScreenshot() }

let pasteboard = NSPasteboard.general
guard let pngData = pasteboard.data(forType: .png) else {
    fail("The clipboard does not contain PNG data.")
}

let pixelSize = imagePixelSize(from: pngData)
var scaleFactor = 1.0 / Double(NSScreen.main?.backingScaleFactor ?? 2.0)
if let scaleIndex = CommandLine.arguments.firstIndex(of: "--scale"),
   CommandLine.arguments.indices.contains(scaleIndex + 1),
   let suppliedScale = Double(CommandLine.arguments[scaleIndex + 1]),
   suppliedScale > 0 {
    scaleFactor = suppliedScale
}

let annotationData = createAnnotationArchive(
    pngData: pngData,
    pixelWidth: pixelSize.width,
    pixelHeight: pixelSize.height,
    scaleFactor: scaleFactor
)
pasteboard.declareTypes([annotationPasteboardType], owner: nil)
guard pasteboard.setData(annotationData, forType: annotationPasteboardType) else {
    fail("Could not write the AnnotationItem to the clipboard.")
}

print("Converted \(pixelSize.width) x \(pixelSize.height) px to \(Int(Double(pixelSize.width) * scaleFactor)) x \(Int(Double(pixelSize.height) * scaleFactor)) pt.")
print("Paste it into a PDF open in Preview with Command-V.")
