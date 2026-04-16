#!/usr/bin/env swift

import AppKit
import Foundation

let iconNamesToSizes: [(String, CGFloat)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

guard CommandLine.arguments.count == 2 else {
    fputs("Usage: generate-app-icon.swift <output-iconset-dir>\n", stderr)
    exit(1)
}

let outputDirectory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

for (name, size) in iconNamesToSizes {
    let imageSize = NSSize(width: size, height: size)
    let image = NSImage(size: imageSize)

    image.lockFocus()

    let backgroundRect = NSRect(origin: .zero, size: imageSize)
    let backgroundPath = NSBezierPath(roundedRect: backgroundRect, xRadius: size * 0.23, yRadius: size * 0.23)
    NSColor(calibratedRed: 0.08, green: 0.1, blue: 0.14, alpha: 1.0).setFill()
    backgroundPath.fill()

    let glowRect = backgroundRect.insetBy(dx: size * 0.08, dy: size * 0.08)
    let glowPath = NSBezierPath(roundedRect: glowRect, xRadius: size * 0.18, yRadius: size * 0.18)
    NSColor(calibratedRed: 0.42, green: 0.92, blue: 0.78, alpha: 0.18).setFill()
    glowPath.fill()

    let dotRect = NSRect(
        x: size * 0.72,
        y: size * 0.7,
        width: size * 0.12,
        height: size * 0.12
    )
    let dotPath = NSBezierPath(ovalIn: dotRect)
    NSColor(calibratedRed: 1.0, green: 0.45, blue: 0.58, alpha: 1.0).setFill()
    dotPath.fill()

    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center

    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: size * 0.52, weight: .bold),
        .foregroundColor: NSColor.white,
        .paragraphStyle: paragraph
    ]

    let text = NSAttributedString(string: "é", attributes: attributes)
    let textSize = text.size()
    let textRect = NSRect(
        x: (size - textSize.width) / 2,
        y: (size - textSize.height) / 2 - (size * 0.04),
        width: textSize.width,
        height: textSize.height
    )
    text.draw(in: textRect)

    image.unlockFocus()

    guard
        let tiffData = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiffData),
        let pngData = bitmap.representation(using: .png, properties: [:])
    else {
        fputs("Failed to render \(name)\n", stderr)
        exit(1)
    }

    try pngData.write(to: outputDirectory.appendingPathComponent(name))
}
