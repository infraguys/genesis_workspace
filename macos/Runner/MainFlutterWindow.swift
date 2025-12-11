import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    self.titleVisibility = .hidden
    self.titlebarAppearsTransparent = true
    self.isMovableByWindowBackground = false
    self.styleMask.insert(.fullSizeContentView)
    self.backgroundColor = NSColor.clear

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
