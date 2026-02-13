//
//  Obsidian_TrayApp.swift
//  Obsidian Tray
//
//  Created by Vignesh Vaidyanathan on 1/24/26.
//

import SwiftUI

@main
struct Obsidian_TrayApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
