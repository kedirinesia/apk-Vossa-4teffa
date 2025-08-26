import Cocoa
import FlutterMacOS
import FirebaseCore

@main
class AppDelegate: FlutterAppDelegate {

    override func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Inisialisasi Firebase
        FirebaseApp.configure()
        
        // Menghubungkan Flutter dengan plugin
        let flutterViewController = MainFlutterWindow.shared.contentViewController as! FlutterViewController
        GeneratedPluginRegistrant.register(with: flutterViewController)
        
        super.applicationDidFinishLaunching(aNotification)
    }

    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
