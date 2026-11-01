import AppKit
let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
func color(_ hex: UInt32) -> NSColor { NSColor(srgbRed: CGFloat((hex >> 16)&255)/255, green: CGFloat((hex >> 8)&255)/255, blue: CGFloat(hex&255)/255, alpha: 1) }
func polygon(_ points: [(CGFloat,CGFloat)], _ c: UInt32) {
 let p=NSBezierPath(); p.move(to:NSPoint(x:points[0].0,y:points[0].1)); for v in points.dropFirst(){p.line(to:NSPoint(x:v.0,y:v.1))}; p.close(); color(c).setFill(); p.fill()
}
func draw(_ size: Int, icon: Bool, crashed: Bool=false) -> Data {
 let rep=NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:size,pixelsHigh:size,bitsPerSample:8,samplesPerPixel:4,hasAlpha:true,isPlanar:false,colorSpaceName:.deviceRGB,bytesPerRow:0,bitsPerPixel:0)!
 NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current=NSGraphicsContext(bitmapImageRep:rep)
 let ctx=NSGraphicsContext.current!.cgContext; ctx.scaleBy(x:CGFloat(size)/1024,y:CGFloat(size)/1024)
 if icon {color(0x102B46).setFill(); NSBezierPath(rect:NSRect(x:0,y:0,width:1024,height:1024)).fill()
 for i in 0..<3 {let p=NSBezierPath(roundedRect:NSRect(x:100+CGFloat(i)*70,y:180+CGFloat(i)*80,width:90,height:22),xRadius:11,yRadius:11);color(0x24516A).setFill();p.fill()}}
 // Original folded-wing sky sprite: angular silhouette, single small eye, no pipes.
 polygon([(160,420),(470,370),(880,565),(450,680)], crashed ? 0xEFA377 : 0x49D5BC)
 polygon([(310,480),(450,840),(610,490)],0x9DF1DE)
 polygon([(470,370),(450,680),(610,490)],0x24A997)
 polygon([(775,515),(920,565),(810,602)],0xF8CC79)
 color(0x102B46).setFill();NSBezierPath(ovalIn:NSRect(x:727,y:556,width:26,height:26)).fill()
 NSGraphicsContext.restoreGraphicsState(); return rep.representation(using:.png,properties:[:])!
}
try draw(1024,icon:true).write(to:root.appendingPathComponent("assets/images/app_logo.png"))
try draw(512,icon:false).write(to:root.appendingPathComponent("assets/images/bird.png"))
try draw(512,icon:false,crashed:true).write(to:root.appendingPathComponent("assets/images/bird_crash.png"))
let dir=root.appendingPathComponent("ios/Runner/Assets.xcassets/AppIcon.appiconset")
let data=try Data(contentsOf:dir.appendingPathComponent("Contents.json"));let json=try JSONSerialization.jsonObject(with:data) as! [String:Any]
for item in json["images"] as! [[String:String]] {let n=Double(item["size"]!.components(separatedBy:"x")[0])! * Double(item["scale"]!.replacingOccurrences(of:"x",with:""))!;try draw(Int(n),icon:true).write(to:dir.appendingPathComponent(item["filename"]!))}
