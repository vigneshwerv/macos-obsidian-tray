import SwiftUI

enum NoteFileMode: String, CaseIterable {
    case singleFile = "single"
    case dailyFile = "daily"

    var displayName: String {
        switch self {
        case .singleFile: return "Single File"
        case .dailyFile: return "Daily File"
        }
    }

    var description: String {
        switch self {
        case .singleFile: return "All notes go to one file"
        case .dailyFile: return "Creates a new file each day"
        }
    }
}

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    @Published var fileMode: NoteFileMode {
        didSet { UserDefaults.standard.set(fileMode.rawValue, forKey: "noteFileMode") }
    }

    @Published var singleFilePath: String {
        didSet { UserDefaults.standard.set(singleFilePath, forKey: "singleFilePath") }
    }

    @Published var dailyFolderPath: String {
        didSet { UserDefaults.standard.set(dailyFolderPath, forKey: "dailyFolderPath") }
    }

    @Published var dailyFileFormat: String {
        didSet { UserDefaults.standard.set(dailyFileFormat, forKey: "dailyFileFormat") }
    }

    init() {
        let defaultPath = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Documents/Inbox.md").path
        let defaultFolder = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Documents").path

        self.fileMode = NoteFileMode(rawValue: UserDefaults.standard.string(forKey: "noteFileMode") ?? "") ?? .singleFile
        self.singleFilePath = UserDefaults.standard.string(forKey: "singleFilePath") ?? defaultPath
        self.dailyFolderPath = UserDefaults.standard.string(forKey: "dailyFolderPath") ?? defaultFolder
        self.dailyFileFormat = UserDefaults.standard.string(forKey: "dailyFileFormat") ?? "yyyy-MM-dd"
    }

    func currentFilePath() -> URL {
        switch fileMode {
        case .singleFile:
            return URL(fileURLWithPath: singleFilePath)
        case .dailyFile:
            let formatter = DateFormatter()
            formatter.dateFormat = dailyFileFormat
            let filename = formatter.string(from: Date()) + ".md"
            return URL(fileURLWithPath: dailyFolderPath).appendingPathComponent(filename)
        }
    }
}

struct SettingsView: View {
    @ObservedObject var settings = SettingsManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Note Settings")
                .font(.headline)

            // Mode picker
            Picker("Mode", selection: $settings.fileMode) {
                ForEach(NoteFileMode.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            Text(settings.fileMode.description)
                .font(.caption)
                .foregroundColor(.secondary)

            Divider()

            if settings.fileMode == .singleFile {
                singleFileSettings
            } else {
                dailyFileSettings
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 450)
    }

    private var singleFileSettings: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("File Location")
                .font(.subheadline.weight(.medium))

            HStack {
                TextField("Path", text: $settings.singleFilePath)
                    .textFieldStyle(.roundedBorder)

                Button("Browse...") {
                    selectSingleFile()
                }
            }

            Text("Notes will be appended to this file")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var dailyFileSettings: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Folder Location")
                    .font(.subheadline.weight(.medium))

                HStack {
                    TextField("Folder", text: $settings.dailyFolderPath)
                        .textFieldStyle(.roundedBorder)

                    Button("Browse...") {
                        selectDailyFolder()
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Filename Format")
                    .font(.subheadline.weight(.medium))

                HStack {
                    TextField("Format", text: $settings.dailyFileFormat)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 150)

                    Text(".md")
                        .foregroundColor(.secondary)

                    Spacer()
                }

                Text("Today's file: \(previewFilename)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var previewFilename: String {
        let formatter = DateFormatter()
        formatter.dateFormat = settings.dailyFileFormat
        return formatter.string(from: Date()) + ".md"
    }

    private func selectSingleFile() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.plainText]
        panel.nameFieldStringValue = "Inbox.md"
        panel.canCreateDirectories = true

        if let url = URL(string: settings.singleFilePath) {
            panel.directoryURL = url.deletingLastPathComponent()
            panel.nameFieldStringValue = url.lastPathComponent
        }

        if panel.runModal() == .OK, let url = panel.url {
            settings.singleFilePath = url.path
        }
    }

    private func selectDailyFolder() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true

        if let url = URL(string: settings.dailyFolderPath) {
            panel.directoryURL = url
        }

        if panel.runModal() == .OK, let url = panel.url {
            settings.dailyFolderPath = url.path
        }
    }
}

#Preview {
    SettingsView()
}
