import AppKit
import SwiftUI
import ServiceManagement
import HotKey  // Add via: File → Add Packages → https://github.com/soffes/HotKey
import ApplicationServices

class KeyablePanel: NSPanel {
    override var canBecomeKey: Bool { true }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem!
    private var capturePanel: NSPanel?
    private var settingsWindow: NSWindow?
    private var eventMonitor: Any?
    private var activationObserver: Any?
    private var hotKey: HotKey?
    private var launchAtLoginItem: NSMenuItem!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        // Check before setting up hotkey
        if !checkAccessibilityPermission() {
            showAccessibilityAlert()
        }
        setupHotKey()
        NSApp.setActivationPolicy(.accessory)
    }
    
    // MARK: - Accessibility
    
    private func checkAccessibilityPermission() -> Bool {
        AXIsProcessTrusted()
    }
    
    private func showAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Access Required"
        alert.informativeText = "Obsidian Tray needs Accessibility access to register global hotkeys.\n\nClick 'Open Settings' and enable Obsidian Tray in the list."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open Settings")
        alert.addButton(withTitle: "Later")
        
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
    }
    
    // MARK: - Menu Bar
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "note.text", accessibilityDescription: "Quick Capture")
        }
        
        let menu = NSMenu()
        menu.delegate = self
        menu.addItem(NSMenuItem(title: "Capture Note (⌘⇧N)", action: #selector(showCaptureWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Open Inbox", action: #selector(openInbox), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        launchAtLoginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        menu.addItem(launchAtLoginItem)
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(showSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }
    
    // MARK: - Global Hotkey (using HotKey package)
    
    private func setupHotKey() {
        hotKey = HotKey(key: .n, modifiers: [.command, .shift])
        hotKey?.keyDownHandler = { [weak self] in
            self?.showCaptureWindow()
        }
    }
    
    // MARK: - Capture Window
    
    @objc func showCaptureWindow() {
        if capturePanel == nil {
            createCapturePanel()
        }
        
        guard let panel = capturePanel else { return }
        
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let x = screenFrame.midX - panel.frame.width / 2
            let y = screenFrame.midY + 100
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }
        
        panel.makeKeyAndOrderFront(nil)

        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.dismissCaptureWindow()
        }

        activationObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.dismissCaptureWindow()
        }
    }
    
    private func createCapturePanel() {
        let captureView = CaptureView(
            onSubmit: { [weak self] text in
                self?.saveNote(text)
                self?.dismissCaptureWindow()
            },
            onCancel: { [weak self] in
                self?.dismissCaptureWindow()
            }
        )

        let hostingView = NSHostingView(rootView: captureView)
        let contentSize = hostingView.fittingSize

        let panel = KeyablePanel(
            contentRect: NSRect(origin: .zero, size: contentSize),
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.isMovableByWindowBackground = true
        panel.backgroundColor = .clear
        panel.contentView = hostingView

        capturePanel = panel
    }
    
    private func dismissCaptureWindow() {
        capturePanel?.orderOut(nil)
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        if let observer = activationObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
            activationObserver = nil
        }
    }
    
    // MARK: - Save Note

    private func saveNote(_ text: String) {
        let filePath = SettingsManager.shared.currentFilePath()

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let timestamp = formatter.string(from: Date())
        let entry = "- \(timestamp) \(text)\n"

        let fileManager = FileManager.default

        // Create parent directory if needed
        let parentDir = filePath.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: parentDir.path) {
            try? fileManager.createDirectory(at: parentDir, withIntermediateDirectories: true)
        }

        if !fileManager.fileExists(atPath: filePath.path) {
            let title = filePath.deletingPathExtension().lastPathComponent
            try? "# \(title)\n\n".write(to: filePath, atomically: true, encoding: .utf8)
        }

        if let fileHandle = try? FileHandle(forWritingTo: filePath) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(entry.data(using: .utf8)!)
            fileHandle.closeFile()
        }
    }

    @objc private func openInbox() {
        let filePath = SettingsManager.shared.currentFilePath()
        NSWorkspace.shared.open(filePath)
    }

    // MARK: - Settings

    @objc private func showSettings() {
        if let window = settingsWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsView()
        let hostingView = NSHostingView(rootView: settingsView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Obsidian Tray Settings"
        window.contentView = hostingView
        window.isReleasedWhenClosed = false
        window.center()
        settingsWindow = window

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: - Launch at Login

    @objc private func toggleLaunchAtLogin() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            print("Failed to toggle launch at login: \(error)")
        }
    }

    func menuWillOpen(_ menu: NSMenu) {
        launchAtLoginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
    }
}
