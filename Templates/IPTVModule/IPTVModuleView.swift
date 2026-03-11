import AVKit
import AppKit
import SwiftUI
import itchy

struct IPTVModuleView: View {
    @StateObject private var store = IPTVModuleStore.shared

    var body: some View {
        VStack(alignment: .leading, spacing: store.settings.tileSpacing) {
            Button {
                store.presentPanel()
            } label: {
                HStack(spacing: store.settings.tileButtonSpacing) {
                    Image(systemName: "tv")
                        .font(.system(size: store.settings.tileButtonIconSize, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Open TV Panel")
                        .font(.system(size: store.settings.tileButtonFontSize, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(height: store.settings.tileButtonHeight)
                .padding(.horizontal, store.settings.tileButtonHorizontalPadding)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.12, green: 0.46, blue: 0.96),
                            Color(red: 0.07, green: 0.32, blue: 0.74)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    Capsule()
                        .stroke(Color.white.opacity(0.28), lineWidth: 1)
                }
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Text(store.activeHostText)
                .font(.system(size: store.settings.tileSubtitleFontSize, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
                .lineLimit(1)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .nookModuleLayout()
    }
}

private struct IPTVPanelView: View {
    @ObservedObject var store: IPTVModuleStore
    @State private var urlInput: String = ""
    @State private var channelFilterText: String = ""

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().opacity(store.settings.panelDividerOpacity)
            controls
            Divider().opacity(store.settings.panelDividerOpacity)
            content
        }
        .background(panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: store.settings.panelCornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: store.settings.panelCornerRadius, style: .continuous)
                .stroke(Color.primary.opacity(store.settings.panelStrokeOpacity), lineWidth: store.settings.panelStrokeWidth)
        }
        .onAppear {
            if urlInput.isEmpty {
                urlInput = store.playlistURLText
            }
            Task { await store.loadIfNeeded() }
        }
    }

    private var panelBackground: some View {
        ZStack {
            Color(NSColor.windowBackgroundColor)
            LinearGradient(
                colors: [
                    Color.white.opacity(store.settings.panelTopGradientOpacity),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var header: some View {
        HStack(spacing: store.settings.headerSpacing) {
            HStack(spacing: store.settings.trafficLightsSpacing) {
                TrafficLight(color: Color(red: 1.0, green: 0.37, blue: 0.34)) {
                    store.closePanel()
                }
                TrafficLight(color: Color(red: 1.0, green: 0.76, blue: 0.19)) {
                    store.minimizePanel()
                }
                TrafficLight(color: Color(red: 0.16, green: 0.79, blue: 0.25)) {
                    store.zoomPanel()
                }
            }

            Spacer(minLength: 0)

            VStack(spacing: store.settings.headerTitleSpacing) {
                Text("IPTV Panel")
                    .font(.system(size: store.settings.headerTitleFontSize, weight: .semibold))
                Text(store.statusSubtitle)
                    .font(.system(size: store.settings.headerSubtitleFontSize, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Color.clear
                .frame(width: store.settings.headerRightSpacerSize, height: store.settings.headerRightSpacerSize)
        }
        .padding(.horizontal, store.settings.headerHorizontalPadding)
        .padding(.vertical, store.settings.headerVerticalPadding)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: store.settings.controlsSpacing) {
            HStack(spacing: store.settings.controlsRowSpacing) {
                TextField("https://example.com/playlist.m3u8", text: $urlInput)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, store.settings.urlFieldHorizontalPadding)
                    .padding(.vertical, store.settings.urlFieldVerticalPadding)
                    .background(
                        RoundedRectangle(cornerRadius: store.settings.urlFieldCornerRadius, style: .continuous)
                            .fill(Color.secondary.opacity(store.settings.urlFieldBackgroundOpacity))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: store.settings.urlFieldCornerRadius, style: .continuous)
                            .stroke(Color.primary.opacity(store.settings.urlFieldStrokeOpacity), lineWidth: store.settings.urlFieldStrokeWidth)
                    )

                panelActionButton(
                    title: "Load URL",
                    systemImage: "link.badge.plus",
                    isPrimary: true,
                    isDisabled: false
                ) {
                    store.playlistURLText = urlInput
                    Task { await store.applyCustomURLAndLoad() }
                }

                panelActionButton(
                    title: "Refresh",
                    systemImage: "arrow.clockwise",
                    isPrimary: false,
                    isDisabled: store.isLoading
                ) {
                    Task { await store.loadChannels(forceRefresh: true) }
                }
            }

            HStack(spacing: store.settings.infoRowSpacing) {
                Text(store.statusMessage)
                    .font(.system(size: store.settings.statusFontSize, weight: .semibold))
                    .foregroundStyle(store.errorMessage == nil ? Color.secondary : Color.red)
                if let errorMessage = store.errorMessage, !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(size: store.settings.statusFontSize))
                        .foregroundStyle(.red)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                if store.isLoading {
                    ProgressView()
                        .controlSize(.small)
                }
            }
        }
        .padding(store.settings.contentPadding)
    }

    private var content: some View {
        HStack(spacing: store.settings.contentSpacing) {
            channelList
            playerArea
        }
        .padding(.horizontal, store.settings.contentPadding)
        .padding(.bottom, store.settings.contentPadding)
    }

    private var channelList: some View {
        let filteredChannels = store.filteredChannels(matching: channelFilterText)

        return VStack(alignment: .leading, spacing: store.settings.channelListFilterSpacing) {
            HStack(spacing: store.settings.channelListFilterIconSpacing) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: store.settings.channelListFilterIconSize, weight: .medium))
                    .foregroundStyle(.secondary)
                TextField("Filter channels", text: $channelFilterText)
                    .textFieldStyle(.plain)
                    .font(.system(size: store.settings.channelListFilterFontSize, weight: .medium))
            }
            .padding(.horizontal, store.settings.channelListFilterHorizontalPadding)
            .padding(.vertical, store.settings.channelListFilterVerticalPadding)
            .background(
                RoundedRectangle(cornerRadius: store.settings.channelListFilterCornerRadius, style: .continuous)
                    .fill(Color.secondary.opacity(store.settings.channelListFilterBackgroundOpacity))
            )
            .overlay(
                RoundedRectangle(cornerRadius: store.settings.channelListFilterCornerRadius, style: .continuous)
                    .stroke(Color.primary.opacity(store.settings.channelListFilterStrokeOpacity), lineWidth: store.settings.channelListFilterStrokeWidth)
            )

            ScrollView {
                LazyVStack(alignment: .leading, spacing: store.settings.channelRowSpacing) {
                    ForEach(filteredChannels) { channel in
                        ChannelRow(
                            channel: channel,
                            isSelected: channel.id == store.selectedChannelID,
                            settings: store.settings
                        ) {
                            store.selectChannel(channel)
                        }
                    }
                    if filteredChannels.isEmpty {
                        Text("No channel matches the filter.")
                            .font(.system(size: store.settings.channelSubtitleFontSize, weight: .medium))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, store.settings.channelRowHorizontalPadding)
                            .padding(.vertical, store.settings.channelRowVerticalPadding)
                    }
                }
                .padding(store.settings.channelListInnerPadding)
            }
        }
        .frame(width: store.settings.channelListWidth)
        .background(
            RoundedRectangle(cornerRadius: store.settings.channelListCornerRadius, style: .continuous)
                .fill(Color.secondary.opacity(store.settings.channelListBackgroundOpacity))
        )
        .overlay(
            RoundedRectangle(cornerRadius: store.settings.channelListCornerRadius, style: .continuous)
                .stroke(Color.primary.opacity(store.settings.channelListStrokeOpacity), lineWidth: store.settings.channelListStrokeWidth)
        )
        .padding(store.settings.channelListInnerPadding)
    }

    private func panelActionButton(
        title: String,
        systemImage: String,
        isPrimary: Bool,
        isDisabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: store.settings.controlsButtonContentSpacing) {
                Image(systemName: systemImage)
                    .font(.system(size: store.settings.controlsButtonIconSize, weight: .semibold))
                    .foregroundColor(.white)
                Text(title)
                    .font(.system(size: store.settings.controlsButtonFontSize, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(height: store.settings.controlsButtonHeight)
            .padding(.horizontal, store.settings.controlsButtonHorizontalPadding)
            .background(
                Group {
                    if isPrimary {
                        LinearGradient(
                            colors: [
                                Color(red: 0.15, green: 0.50, blue: 0.98),
                                Color(red: 0.08, green: 0.34, blue: 0.80)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color.black.opacity(store.settings.controlsSecondaryButtonBackgroundOpacity)
                    }
                }
            )
            .overlay {
                RoundedRectangle(cornerRadius: store.settings.controlsButtonCornerRadius, style: .continuous)
                    .stroke(
                        (isPrimary ? Color.white : Color.primary)
                            .opacity(store.settings.controlsButtonStrokeOpacity),
                        lineWidth: store.settings.controlsButtonStrokeWidth
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: store.settings.controlsButtonCornerRadius, style: .continuous))
            .opacity(isDisabled ? store.settings.controlsButtonDisabledOpacity : 1)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    private var playerArea: some View {
        VStack(alignment: .leading, spacing: store.settings.playerSpacing) {
            HStack(spacing: store.settings.playerHeaderSpacing) {
                Text("Player")
                    .font(.system(size: store.settings.playerHeaderFontSize, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
                panelActionButton(
                    title: "Fullscreen",
                    systemImage: "arrow.up.left.and.arrow.down.right",
                    isPrimary: false,
                    isDisabled: false
                ) {
                    store.toggleFullScreen()
                }
            }

            if let selected = store.selectedChannel {
                VideoPlayer(player: store.player)
                    .clipShape(RoundedRectangle(cornerRadius: store.settings.playerCornerRadius, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: store.settings.playerCornerRadius, style: .continuous)
                            .stroke(Color.primary.opacity(store.settings.playerStrokeOpacity), lineWidth: store.settings.playerStrokeWidth)
                    }
                Text(selected.name)
                    .font(.system(size: store.settings.playerTitleFontSize, weight: .semibold))
                    .lineLimit(1)
                if let groupTitle = selected.groupTitle, !groupTitle.isEmpty {
                    Text(groupTitle)
                        .font(.system(size: store.settings.playerSubtitleFontSize, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            } else {
                PlaceholderPlayer(settings: store.settings)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct TrafficLight: View {
    let color: Color
    let action: () -> Void

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 12, height: 12)
            .onTapGesture { action() }
    }
}

private struct ChannelRow: View {
    let channel: IPTVChannel
    let isSelected: Bool
    let settings: IPTVModuleSettings
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: settings.channelRowHorizontalSpacing) {
                ChannelLogo(channel: channel, settings: settings)
                VStack(alignment: .leading, spacing: settings.channelTextSpacing) {
                    Text(channel.name)
                        .font(.system(size: settings.channelNameFontSize, weight: .semibold))
                        .lineLimit(1)
                        .foregroundStyle(isSelected ? .white : .primary)
                    if let groupTitle = channel.groupTitle, !groupTitle.isEmpty {
                        Text(groupTitle)
                            .font(.system(size: settings.channelSubtitleFontSize, weight: .medium))
                            .lineLimit(1)
                            .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, settings.channelRowHorizontalPadding)
            .padding(.vertical, settings.channelRowVerticalPadding)
            .background(
                RoundedRectangle(cornerRadius: settings.channelRowCornerRadius, style: .continuous)
                    .fill(
                        isSelected
                            ? Color.accentColor.opacity(settings.channelRowSelectedOpacity)
                            : Color.secondary.opacity(settings.channelRowBackgroundOpacity)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: settings.channelRowCornerRadius, style: .continuous)
                    .stroke(
                        isSelected
                            ? Color.accentColor.opacity(settings.channelRowSelectedStrokeOpacity)
                            : Color.primary.opacity(settings.channelRowStrokeOpacity),
                        lineWidth: settings.channelRowStrokeWidth
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

private struct ChannelLogo: View {
    let channel: IPTVChannel
    let settings: IPTVModuleSettings

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: settings.logoCornerRadius, style: .continuous)
                .fill(Color.secondary.opacity(settings.logoBackgroundOpacity))
            if let logoURL = channel.logoURL {
                AsyncImage(url: logoURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: settings.logoWidth, height: settings.logoHeight)
        .clipShape(RoundedRectangle(cornerRadius: settings.logoCornerRadius, style: .continuous))
    }

    private var placeholder: some View {
        Image(systemName: "tv")
            .font(.system(size: settings.logoPlaceholderIconSize, weight: .semibold))
            .foregroundStyle(.secondary)
    }
}

private struct PlaceholderPlayer: View {
    let settings: IPTVModuleSettings

    var body: some View {
        VStack(spacing: settings.playerPlaceholderSpacing) {
            RoundedRectangle(cornerRadius: settings.playerCornerRadius, style: .continuous)
                .fill(Color.secondary.opacity(settings.playerPlaceholderBackgroundOpacity))
                .overlay {
                    Image(systemName: "tv")
                        .font(.system(size: settings.playerPlaceholderIconSize, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            Text("Select a channel to start playback")
                .font(.system(size: settings.playerSubtitleFontSize, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

private final class IPTVPanelWindow: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    override func cancelOperation(_ sender: Any?) {
        close()
    }
}

private final class IPTVPanelManager: NSObject, NSWindowDelegate {
    private var window: IPTVPanelWindow?
    private let store: IPTVModuleStore
    private let settings: IPTVModuleSettings

    init(store: IPTVModuleStore, settings: IPTVModuleSettings) {
        self.store = store
        self.settings = settings
        super.init()
    }

    func present() {
        let window = window ?? makeWindow()
        window.contentView = NSHostingView(rootView: IPTVPanelView(store: store))
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    func close() {
        store.shutdownPlaybackSession()
        window?.close()
    }

    func minimize() {
        window?.miniaturize(nil)
    }

    func zoom() {
        window?.zoom(nil)
    }

    func toggleFullScreen() {
        guard let window else { return }
        window.toggleFullScreen(nil)
    }

    func windowWillClose(_ notification: Notification) {
        guard let closed = notification.object as? IPTVPanelWindow, closed == window else { return }
        store.shutdownPlaybackSession()
        window = nil
    }

    private func makeWindow() -> IPTVPanelWindow {
        let window = IPTVPanelWindow(
            contentRect: NSRect(x: 0, y: 0, width: settings.panelWidth, height: settings.panelHeight),
            styleMask: [.borderless, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false
        window.hidesOnDeactivate = false
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.minSize = NSSize(width: settings.panelMinWidth, height: settings.panelMinHeight)
        window.center()
        window.delegate = self
        self.window = window
        return window
    }
}

private struct IPTVChannel: Identifiable, Hashable, Codable {
    let name: String
    let streamURLString: String
    let logoURLString: String?
    let groupTitle: String?

    var id: String { streamURLString }

    var streamURL: URL? { URL(string: streamURLString) }

    var logoURL: URL? {
        guard let logoURLString, !logoURLString.isEmpty else { return nil }
        return URL(string: logoURLString)
    }
}

private struct IPTVCacheEntry: Codable {
    let sourceURL: String
    let fetchedAt: Date
    let channels: [IPTVChannel]
}

private struct IPTVCacheStore: Codable {
    var entries: [String: IPTVCacheEntry] = [:]
}

private struct IPTVModuleSettings {
    let defaultPlaylistURL = "https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8"
    let requestTimeout: TimeInterval = 20
    let cacheTTL: TimeInterval = 86_400
    let cacheMaxEntries: Int = 8
    let tileSpacing: CGFloat = 10
    let tileTitleFontSize: CGFloat = 14
    let tileSubtitleFontSize: CGFloat = 11
    let tileButtonSpacing: CGFloat = 6
    let tileButtonFontSize: CGFloat = 13
    let tileButtonIconSize: CGFloat = 13
    let tileButtonHeight: CGFloat = 40
    let tileButtonHorizontalPadding: CGFloat = 12
    let tileButtonBackgroundOpacity: CGFloat = 0.08
    let panelWidth: CGFloat = 1_020
    let panelHeight: CGFloat = 620
    let panelMinWidth: CGFloat = 800
    let panelMinHeight: CGFloat = 460
    let panelCornerRadius: CGFloat = 18
    let panelDividerOpacity: CGFloat = 0.2
    let panelStrokeOpacity: CGFloat = 0.16
    let panelStrokeWidth: CGFloat = 1
    let panelTopGradientOpacity: CGFloat = 0.05
    let headerSpacing: CGFloat = 12
    let headerTitleSpacing: CGFloat = 2
    let headerTitleFontSize: CGFloat = 14
    let headerSubtitleFontSize: CGFloat = 11
    let headerHorizontalPadding: CGFloat = 14
    let headerVerticalPadding: CGFloat = 10
    let headerRightSpacerSize: CGFloat = 28
    let trafficLightsSpacing: CGFloat = 8
    let controlsSpacing: CGFloat = 8
    let controlsRowSpacing: CGFloat = 8
    let controlsButtonHeight: CGFloat = 32
    let controlsButtonCornerRadius: CGFloat = 9
    let controlsButtonContentSpacing: CGFloat = 6
    let controlsButtonHorizontalPadding: CGFloat = 12
    let controlsButtonFontSize: CGFloat = 12
    let controlsButtonIconSize: CGFloat = 12
    let controlsButtonStrokeOpacity: CGFloat = 0.2
    let controlsButtonStrokeWidth: CGFloat = 1
    let controlsSecondaryButtonBackgroundOpacity: CGFloat = 0.52
    let controlsButtonDisabledOpacity: CGFloat = 0.55
    let infoRowSpacing: CGFloat = 8
    let statusFontSize: CGFloat = 11
    let urlFieldHorizontalPadding: CGFloat = 10
    let urlFieldVerticalPadding: CGFloat = 8
    let urlFieldCornerRadius: CGFloat = 10
    let urlFieldBackgroundOpacity: CGFloat = 0.1
    let urlFieldStrokeOpacity: CGFloat = 0.12
    let urlFieldStrokeWidth: CGFloat = 1
    let contentPadding: CGFloat = 12
    let contentSpacing: CGFloat = 12
    let channelListWidth: CGFloat = 326
    let channelListInnerPadding: CGFloat = 8
    let channelListFilterSpacing: CGFloat = 8
    let channelListFilterIconSpacing: CGFloat = 6
    let channelListFilterIconSize: CGFloat = 13
    let channelListFilterFontSize: CGFloat = 12
    let channelListFilterHorizontalPadding: CGFloat = 10
    let channelListFilterVerticalPadding: CGFloat = 8
    let channelListFilterCornerRadius: CGFloat = 10
    let channelListFilterBackgroundOpacity: CGFloat = 0.09
    let channelListFilterStrokeOpacity: CGFloat = 0.12
    let channelListFilterStrokeWidth: CGFloat = 1
    let channelListCornerRadius: CGFloat = 14
    let channelListBackgroundOpacity: CGFloat = 0.06
    let channelListStrokeOpacity: CGFloat = 0.1
    let channelListStrokeWidth: CGFloat = 1
    let channelRowSpacing: CGFloat = 8
    let channelRowHorizontalSpacing: CGFloat = 9
    let channelTextSpacing: CGFloat = 2
    let channelNameFontSize: CGFloat = 12
    let channelSubtitleFontSize: CGFloat = 10
    let channelRowHorizontalPadding: CGFloat = 8
    let channelRowVerticalPadding: CGFloat = 8
    let channelRowCornerRadius: CGFloat = 10
    let channelRowBackgroundOpacity: CGFloat = 0.06
    let channelRowSelectedOpacity: CGFloat = 0.28
    let channelRowStrokeOpacity: CGFloat = 0.08
    let channelRowSelectedStrokeOpacity: CGFloat = 0.46
    let channelRowStrokeWidth: CGFloat = 1
    let logoWidth: CGFloat = 40
    let logoHeight: CGFloat = 27
    let logoCornerRadius: CGFloat = 7
    let logoBackgroundOpacity: CGFloat = 0.08
    let logoPlaceholderIconSize: CGFloat = 12
    let playerSpacing: CGFloat = 10
    let playerHeaderSpacing: CGFloat = 8
    let playerHeaderFontSize: CGFloat = 11
    let playerCornerRadius: CGFloat = 14
    let playerStrokeOpacity: CGFloat = 0.14
    let playerStrokeWidth: CGFloat = 1
    let playerTitleFontSize: CGFloat = 15
    let playerSubtitleFontSize: CGFloat = 11
    let playerPlaceholderSpacing: CGFloat = 10
    let playerPlaceholderBackgroundOpacity: CGFloat = 0.08
    let playerPlaceholderIconSize: CGFloat = 28
}

private final class IPTVModuleStore: ObservableObject {
    static let shared = IPTVModuleStore()

    @Published var playlistURLText: String
    @Published var channels: [IPTVChannel] = []
    @Published var selectedChannelID: String?
    @Published var isLoading: Bool = false
    @Published var statusMessage: String = "Ready"
    @Published var errorMessage: String?
    @Published var lastUpdatedAt: Date?

    let settings = IPTVModuleSettings()
    let player = AVPlayer()

    private let defaultsKey = "iptv.module.playlist.url"
    private let cacheFileName = "iptv-module-cache.json"
    private var hasInitialLoad = false
    private var activePlaylistURL: URL?
    private lazy var panelManager = IPTVPanelManager(store: self, settings: settings)

    private init() {
        let storedURL = UserDefaults.standard.string(forKey: defaultsKey)
        playlistURLText = storedURL?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            ? storedURL!
            : settings.defaultPlaylistURL
    }

    var activeHostText: String {
        let source = activePlaylistURL ?? URL(string: playlistURLText)
        return source?.host ?? "Playlist"
    }

    var selectedChannel: IPTVChannel? {
        guard let selectedChannelID else { return channels.first }
        return channels.first(where: { $0.id == selectedChannelID }) ?? channels.first
    }

    var statusSubtitle: String {
        guard let lastUpdatedAt else { return "No fetch yet" }
        return "Updated \(lastUpdatedAt.formatted(date: .omitted, time: .shortened))"
    }

    func filteredChannels(matching query: String) -> [IPTVChannel] {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return channels }
        let needle = normalized.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        return channels.filter { channel in
            let name = channel.name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            let group = (channel.groupTitle ?? "").folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            return name.contains(needle) || group.contains(needle)
        }
    }

    func presentPanel() {
        panelManager.present()
    }

    func closePanel() {
        panelManager.close()
    }

    func minimizePanel() {
        panelManager.minimize()
    }

    func zoomPanel() {
        panelManager.zoom()
    }

    func toggleFullScreen() {
        panelManager.toggleFullScreen()
    }

    func shutdownPlaybackSession() {
        player.pause()
        player.replaceCurrentItem(with: nil)
    }

    @MainActor
    func loadIfNeeded() async {
        guard !hasInitialLoad else { return }
        hasInitialLoad = true
        await loadChannels(forceRefresh: false)
    }

    @MainActor
    func applyCustomURLAndLoad() async {
        guard let validURL = normalizedPlaylistURL(from: playlistURLText) else {
            statusMessage = "Invalid URL"
            errorMessage = "Enter a valid M3U or M3U8 URL."
            return
        }
        playlistURLText = validURL.absoluteString
        UserDefaults.standard.set(playlistURLText, forKey: defaultsKey)
        await loadChannels(forceRefresh: false)
    }

    @MainActor
    func loadChannels(forceRefresh: Bool) async {
        guard let sourceURL = normalizedPlaylistURL(from: playlistURLText) else {
            statusMessage = "Invalid URL"
            errorMessage = "Enter a valid M3U or M3U8 URL."
            return
        }

        activePlaylistURL = sourceURL
        isLoading = true
        errorMessage = nil
        statusMessage = forceRefresh ? "Refreshing..." : "Loading..."
        defer { isLoading = false }

        if !forceRefresh, let cache = cachedEntry(for: sourceURL), !isCacheExpired(cache) {
            applyChannels(cache.channels)
            lastUpdatedAt = cache.fetchedAt
            statusMessage = "Loaded from cache"
            return
        }

        do {
            let text = try await fetchPlaylistText(from: sourceURL)
            let fetchedChannels = parsePlaylist(text: text, baseURL: sourceURL)
            guard !fetchedChannels.isEmpty else {
                throw URLError(.cannotParseResponse)
            }
            let fetchedAt = Date()
            persistCache(channels: fetchedChannels, for: sourceURL, fetchedAt: fetchedAt)
            applyChannels(fetchedChannels)
            lastUpdatedAt = fetchedAt
            statusMessage = "Loaded \(fetchedChannels.count) channels"
        } catch {
            if let fallback = cachedEntry(for: sourceURL), !fallback.channels.isEmpty {
                applyChannels(fallback.channels)
                lastUpdatedAt = fallback.fetchedAt
                statusMessage = "Network failed, using cache"
                errorMessage = "Could not refresh playlist."
            } else {
                channels = []
                selectedChannelID = nil
                player.pause()
                statusMessage = "Load failed"
                errorMessage = "Playlist could not be loaded."
            }
        }
    }

    func selectChannel(_ channel: IPTVChannel) {
        selectedChannelID = channel.id
        guard let url = channel.streamURL else { return }
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        player.play()
    }

    private func applyChannels(_ incoming: [IPTVChannel]) {
        let previousSelection = selectedChannelID
        channels = incoming
        guard !incoming.isEmpty else {
            selectedChannelID = nil
            player.pause()
            return
        }

        if let previousSelection, let channel = incoming.first(where: { $0.id == previousSelection }) {
            selectChannel(channel)
            return
        }
        if let first = incoming.first {
            selectChannel(first)
        }
    }

    private func normalizedPlaylistURL(from raw: String) -> URL? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let url = URL(string: trimmed), url.scheme != nil else { return nil }
        return url
    }

    private func fetchPlaylistText(from url: URL) async throws -> String {
        var request = URLRequest(url: url)
        request.timeoutInterval = settings.requestTimeout
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }
        if let utf8 = String(data: data, encoding: .utf8) {
            return utf8
        }
        if let latin1 = String(data: data, encoding: .isoLatin1) {
            return latin1
        }
        throw URLError(.cannotDecodeRawData)
    }

    private func parsePlaylist(text: String, baseURL: URL) -> [IPTVChannel] {
        let lines = text
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .components(separatedBy: "\n")

        var channels: [IPTVChannel] = []
        var pendingAttributes: [String: String] = [:]
        var pendingTitle: String?

        for raw in lines {
            let line = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else { continue }

            if line.hasPrefix("#EXTINF:") {
                pendingAttributes = parseExtinfAttributes(line)
                pendingTitle = parseExtinfTitle(line)
                continue
            }
            if line.hasPrefix("#") {
                continue
            }

            guard let streamURL = URL(string: line, relativeTo: baseURL)?.absoluteURL else { continue }
            let metadataName = pendingAttributes["tvg-name"]?.trimmingCharacters(in: .whitespacesAndNewlines)
            let resolvedTitle = pendingTitle?.trimmingCharacters(in: .whitespacesAndNewlines)
            let channelName = [metadataName, resolvedTitle].compactMap { $0 }.first(where: { !$0.isEmpty }) ?? streamURL.lastPathComponent

            let rawLogo = pendingAttributes["tvg-logo"]?.trimmingCharacters(in: .whitespacesAndNewlines)
            let logoURL = rawLogo.flatMap { value in
                value.isEmpty ? nil : URL(string: value, relativeTo: baseURL)?.absoluteURL.absoluteString
            }
            let groupTitle = pendingAttributes["group-title"]?.trimmingCharacters(in: .whitespacesAndNewlines)

            channels.append(
                IPTVChannel(
                    name: channelName,
                    streamURLString: streamURL.absoluteString,
                    logoURLString: logoURL,
                    groupTitle: groupTitle?.isEmpty == true ? nil : groupTitle
                )
            )

            pendingAttributes = [:]
            pendingTitle = nil
        }

        return channels
    }

    private func parseExtinfAttributes(_ line: String) -> [String: String] {
        let segment = line
            .replacingOccurrences(of: "#EXTINF:", with: "")
            .split(separator: ",", maxSplits: 1, omittingEmptySubsequences: false)
            .first
            .map(String.init) ?? ""

        guard let regex = try? NSRegularExpression(pattern: #"([a-zA-Z0-9\-]+)="([^"]*)""#, options: []) else {
            return [:]
        }
        let range = NSRange(segment.startIndex..<segment.endIndex, in: segment)
        let matches = regex.matches(in: segment, options: [], range: range)
        var values: [String: String] = [:]
        for match in matches where match.numberOfRanges == 3 {
            guard
                let keyRange = Range(match.range(at: 1), in: segment),
                let valueRange = Range(match.range(at: 2), in: segment)
            else { continue }
            values[String(segment[keyRange]).lowercased()] = String(segment[valueRange])
        }
        return values
    }

    private func parseExtinfTitle(_ line: String) -> String? {
        let parts = line.split(separator: ",", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2 else { return nil }
        return String(parts[1])
    }

    private func cacheKey(for url: URL) -> String {
        url.absoluteString.lowercased()
    }

    private func isCacheExpired(_ entry: IPTVCacheEntry) -> Bool {
        Date().timeIntervalSince(entry.fetchedAt) > settings.cacheTTL
    }

    private func cachedEntry(for url: URL) -> IPTVCacheEntry? {
        loadCacheStore().entries[cacheKey(for: url)]
    }

    private func persistCache(channels: [IPTVChannel], for url: URL, fetchedAt: Date) {
        var store = loadCacheStore()
        store.entries[cacheKey(for: url)] = IPTVCacheEntry(
            sourceURL: url.absoluteString,
            fetchedAt: fetchedAt,
            channels: channels
        )

        if store.entries.count > settings.cacheMaxEntries {
            let keysToKeep = Set(
                store.entries
                    .sorted(by: { $0.value.fetchedAt > $1.value.fetchedAt })
                    .prefix(settings.cacheMaxEntries)
                    .map(\.key)
            )
            store.entries = store.entries.filter { keysToKeep.contains($0.key) }
        }
        saveCacheStore(store)
    }

    private func loadCacheStore() -> IPTVCacheStore {
        guard
            let url = cacheFileURL(),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode(IPTVCacheStore.self, from: data)
        else {
            return IPTVCacheStore()
        }
        return decoded
    }

    private func saveCacheStore(_ store: IPTVCacheStore) {
        guard let url = cacheFileURL() else { return }
        guard let data = try? JSONEncoder().encode(store) else { return }
        try? data.write(to: url, options: [.atomic])
    }

    private func cacheFileURL() -> URL? {
        guard let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        let folder = base.appendingPathComponent("ItchySDK-IPTVModule", isDirectory: true)
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder.appendingPathComponent(cacheFileName)
    }
}
