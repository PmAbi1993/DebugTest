//
//  DashboardView.swift
//  DebugTest
//
//  Created by Cascade on 8/9/25.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        TabView {
            HomeTabView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            ExploreTabView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Explore")
                }

            MessagesTabView()
                .tabItem {
                    Image(systemName: "envelope.fill")
                    Text("Messages")
                }

            NotificationsTabView()
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("Alerts")
                }

            ProfileTabView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .onAppear {
            AppLogger.debug("ASd")
        }
        .accentColor(.white)
        .tint(.white)
        .background(Color.black)
    }
}

// MARK: - Tabs

private struct HomeTabView: View {
    @State private var searchText: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    DashboardHeaderView()

                    // Key Metrics
                    MetricsSection()

                    // Charts
                    ChartsSection()

                    // Quick Actions
                    QuickActionsSection()

                    // Activity Feed
                    ActivityFeedSection()

                    // Trends
                    TrendsSection()

                    // Spaces / Live Audio
                    SpacesSection()
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                        Text("Dashboard")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.dark)
    }
}

private struct ExploreTabView: View {
    @State private var query: String = ""

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Trending now").foregroundColor(.white)) {
                    ForEach(Trend.sample) { trend in
                        TrendRowView(trend: trend)
                            .listRowBackground(Color(white: 0.12))
                    }
                }

                Section(header: Text("Suggested for you").foregroundColor(.white)) {
                    ForEach(Activity.sample.prefix(5)) { activity in
                        ActivityRowView(activity: activity)
                            .listRowBackground(Color(white: 0.12))
                    }
                }
            }
            .searchable(text: $query, placement: .automatic)
            .background(Color.black)
            .scrollContentBackground(.hidden)
            .navigationTitle("Explore")
        }
        .preferredColorScheme(.dark)
    }
}

private struct MessagesTabView: View {
    var body: some View {
        NavigationView {
            List {
                ForEach(Message.sample) { message in
                    HStack(spacing: 12) {
                        AvatarView(initials: message.senderInitials)
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(message.sender)
                                    .font(.subheadline).bold()
                                    .foregroundColor(.white)
                                Spacer()
                                Text(message.timestamp)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            Text(message.snippet)
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(2)
                                .font(.footnote)
                        }
                    }
                    .padding(.vertical, 6)
                    .listRowBackground(Color(white: 0.12))
                }
            }
            .background(Color.black)
            .scrollContentBackground(.hidden)
            .navigationTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct NotificationsTabView: View {
    @State private var filter: Filter = .all

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("Filter", selection: $filter) {
                    ForEach(Filter.allCases, id: \.self) { f in
                        Text(f.title)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                List {
                    ForEach(Activity.sample.filter { filter.matches($0) }) { activity in
                        ActivityRowView(activity: activity)
                            .listRowBackground(Color(white: 0.12))
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.black)
            }
            .navigationTitle("Alerts")
        }
        .preferredColorScheme(.dark)
    }

    enum Filter: CaseIterable {
        case all, mentions, follows, likes

        var title: String {
            switch self {
            case .all: return "All"
            case .mentions: return "Mentions"
            case .follows: return "Follows"
            case .likes: return "Likes"
            }
        }

        func matches(_ activity: Activity) -> Bool {
            switch self {
            case .all: return true
            case .mentions: return activity.type == .mention
            case .follows: return activity.type == .follow
            case .likes: return activity.type == .like
            }
        }
    }
}

private struct ProfileTabView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack(alignment: .center, spacing: 16) {
                    AvatarView(initials: "PM", size: 64)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Abhijith PM")
                            .font(.title3).bold()
                            .foregroundColor(.white)
                        Text("@pmabi")
                            .font(.callout)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                    Button(action: {}) {
                        Text("Edit profile")
                            .font(.subheadline).bold()
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .clipShape(Capsule())
                    }
                }

                // Stats
                HStack(spacing: 24) {
                    StatItem(title: "Posts", value: "2,415")
                    StatItem(title: "Following", value: "987")
                    StatItem(title: "Followers", value: "12.4K")
                }

                // Pinned
                Text("Pinned")
                    .font(.headline)
                    .foregroundColor(.white)
                ActivityRowView(activity: Activity.sample.first!)

                // Recent
                Text("Recent")
                    .font(.headline)
                    .foregroundColor(.white)
                VStack(spacing: 0) {
                    ForEach(Activity.sample.dropFirst().prefix(5)) { activity in
                        ActivityRowView(activity: activity)
                        Divider().background(Color.white.opacity(0.1))
                    }
                }
            }
            .padding()
            .background(Color.black)
        }
        .preferredColorScheme(.dark)
        .navigationTitle("Profile")
    }
}

// MARK: - Sections

private struct DashboardHeaderView: View {
    var body: some View {
        HStack(spacing: 12) {
            AvatarView(initials: "PM")
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.6))
                Text("Search X")
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color(white: 0.12))
            .clipShape(Capsule())

            Button(action: {}) {
                Image(systemName: "square.and.pencil")
                    .foregroundColor(.black)
                    .padding(10)
                    .background(Color.white)
                    .clipShape(Circle())
            }
        }
    }
}

private struct MetricsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key metrics")
                .font(.headline)
                .foregroundColor(.white)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    MetricCardView(title: "Impressions", value: "128.4K", delta: "+12.3%", positive: true)
                    MetricCardView(title: "Engagement", value: "8,214", delta: "+3.1%", positive: true)
                    MetricCardView(title: "Followers", value: "12.4K", delta: "-0.4%", positive: false)
                    MetricCardView(title: "CTR", value: "3.8%", delta: "+0.9%", positive: true)
                }
            }
        }
    }
}

private struct ChartsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Analytics")
                .font(.headline)
                .foregroundColor(.white)
            VStack(spacing: 12) {
                LineChartView(points: [12, 18, 16, 22, 28, 26, 34, 42, 38, 45])
                    .frame(height: 140)
                    .background(Color(white: 0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                BarChartView(values: [4, 6, 8, 3, 5, 7, 9, 5, 6, 8])
                    .frame(height: 120)
                    .background(Color(white: 0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
}

private struct QuickActionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick actions")
                .font(.headline)
                .foregroundColor(.white)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                QuickActionButton(title: "Compose", system: "square.and.pencil")
                QuickActionButton(title: "Spaces", system: "dot.radiowaves.left.and.right")
                QuickActionButton(title: "Lists", system: "list.bullet")
                QuickActionButton(title: "Analytics", system: "chart.xyaxis.line")
                QuickActionButton(title: "Bookmarks", system: "bookmark.fill")
                QuickActionButton(title: "Monetize", system: "dollarsign.circle.fill")
            }
        }
    }
}

private struct ActivityFeedSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity")
                .font(.headline)
                .foregroundColor(.white)
            VStack(spacing: 0) {
                ForEach(Activity.sample) { activity in
                    ActivityRowView(activity: activity)
                    Divider().background(Color.white.opacity(0.1))
                }
            }
            .background(Color(white: 0.12))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

private struct TrendsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trends for you")
                .font(.headline)
                .foregroundColor(.white)
            VStack(spacing: 0) {
                ForEach(Trend.sample) { trend in
                    TrendRowView(trend: trend)
                    Divider().background(Color.white.opacity(0.1))
                }
            }
            .background(Color(white: 0.12))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

private struct SpacesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live Spaces")
                .font(.headline)
                .foregroundColor(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(1...6, id: \.self) { idx in
                        SpaceCardView(title: "Tech Talk #\(idx)", hosts: ["Alex", "Sam"], listeners: Int.random(in: 120...950))
                    }
                }
            }
        }
    }
}

// MARK: - Components

private struct AvatarView: View {
    let initials: String
    var size: CGFloat = 36

    var body: some View {
        Text(initials)
            .font(.subheadline).bold()
            .foregroundColor(.black)
            .frame(width: size, height: size)
            .background(Color.white)
            .clipShape(Circle())
    }
}

private struct MetricCardView: View {
    let title: String
    let value: String
    let delta: String
    let positive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            Text(value)
                .font(.title3).bold()
                .foregroundColor(.white)
            HStack(spacing: 4) {
                Image(systemName: positive ? "arrow.up.right" : "arrow.down.right")
                    .font(.caption)
                Text(delta)
                    .font(.caption).bold()
            }
            .foregroundColor(positive ? .green : .red)
        }
        .padding(14)
        .frame(width: 160, alignment: .leading)
        .background(Color(white: 0.12))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct LineChartView: View {
    let points: [CGFloat]

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let maxValue = (points.max() ?? 1)
            let minValue = (points.min() ?? 0)
            let range = max(maxValue - minValue, 1)

            let path = Path { p in
                for (i, value) in points.enumerated() {
                    let x = CGFloat(i) / CGFloat(max(points.count - 1, 1)) * w
                    let y = h - ((value - minValue) / range) * h
                    if i == 0 { p.move(to: CGPoint(x: x, y: y)) } else { p.addLine(to: CGPoint(x: x, y: y)) }
                }
            }

            path
                .stroke(LinearGradient(colors: [.white, .white.opacity(0.6)], startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: 2, lineJoin: .round))
                .shadow(color: .white.opacity(0.2), radius: 6, x: 0, y: 0)
        }
        .padding(12)
    }
}

private struct BarChartView: View {
    let values: [CGFloat]

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let maxValue = max(values.max() ?? 1, 1)
            let barWidth = w / CGFloat(values.count * 2)
            HStack(alignment: .bottom, spacing: barWidth) {
                ForEach(values.indices, id: \.self) { idx in
                    let v = values[idx]
                    let barHeight = (v / maxValue) * h
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white)
                        .frame(width: barWidth, height: barHeight)
                        .opacity(0.9)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.horizontal, barWidth)
        }
        .padding(.vertical, 12)
    }
}

private struct QuickActionButton: View {
    let title: String
    let system: String

    var body: some View {
        Button(action: {}) {
            VStack(spacing: 8) {
                Image(systemName: system)
                    .font(.title3)
                    .foregroundColor(.black)
                    .frame(width: 36, height: 36)
                    .background(Color.white)
                    .clipShape(Circle())
                Text(title)
                    .font(.footnote)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(white: 0.12))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

private struct ActivityRowView: View {
    let activity: Activity

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AvatarView(initials: activity.userInitials)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(activity.user)
                        .foregroundColor(.white)
                        .font(.subheadline).bold()
                    Text("@\(activity.handle)")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.caption)
                    Spacer()
                    Text(activity.timestamp)
                        .foregroundColor(.white.opacity(0.6))
                        .font(.caption)
                }
                Text(activity.text)
                    .foregroundColor(.white)
                    .font(.callout)
                HStack(spacing: 16) {
                    Label("\(activity.likes)", systemImage: "heart")
                    Label("\(activity.reposts)", systemImage: "arrow.2.squarepath")
                    Label("\(activity.comments)", systemImage: "bubble.left")
                }
                .foregroundColor(.white.opacity(0.7))
                .font(.caption)
                .padding(.top, 4)
            }
        }
        .padding(12)
    }
}

private struct TrendRowView: View {
    let trend: Trend

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(trend.category.uppercased())
                    .font(.caption2).bold()
                    .foregroundColor(.white.opacity(0.6))
                Text(trend.title)
                    .font(.subheadline).bold()
                    .foregroundColor(.white)
                Text("\(trend.tweetCount) posts")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(12)
    }
}

private struct SpaceCardView: View {
    let title: String
    let hosts: [String]
    let listeners: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Circle().fill(Color.purple).frame(width: 6, height: 6)
                Text("LIVE")
                    .font(.caption2).bold()
                    .foregroundColor(.purple)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.purple.opacity(0.2))
                    .clipShape(Capsule())
            }
            Text(title)
                .font(.subheadline).bold()
                .foregroundColor(.white)
            Text("Hosts: \(hosts.joined(separator: ", ")) • \(listeners) listening")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(12)
        .frame(width: 220, alignment: .leading)
        .background(Color(white: 0.12))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct StatItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.headline).bold()
                .foregroundColor(.white)
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

// MARK: - Models & Samples

private struct Activity: Identifiable {
    enum Kind { case like, follow, mention, post }

    let id = UUID()
    let type: Kind
    let user: String
    let handle: String
    let userInitials: String
    let text: String
    let likes: Int
    let reposts: Int
    let comments: Int
    let timestamp: String

    static let sample: [Activity] = [
        .init(type: .post, user: "Jane Doe", handle: "janed", userInitials: "JD", text: "Launching a new SwiftUI chart pack next week!", likes: 342, reposts: 79, comments: 45, timestamp: "2m"),
        .init(type: .mention, user: "Swift Weekly", handle: "swiftweekly", userInitials: "SW", text: "@pmabi loved your latest post about async/await!", likes: 128, reposts: 18, comments: 12, timestamp: "15m"),
        .init(type: .follow, user: "Alex Kim", handle: "alexk", userInitials: "AK", text: "Alex Kim started following you", likes: 0, reposts: 0, comments: 0, timestamp: "1h"),
        .init(type: .like, user: "Sam Park", handle: "spark", userInitials: "SP", text: "liked your post", likes: 0, reposts: 0, comments: 0, timestamp: "1h"),
        .init(type: .post, user: "Dev News", handle: "devnews", userInitials: "DN", text: "Xcode 16.3 beta adds new debugging tools.", likes: 512, reposts: 122, comments: 64, timestamp: "2h"),
        .init(type: .mention, user: "WWDC Clips", handle: "wwdcclips", userInitials: "WC", text: "@pmabi what are your favorite hidden iOS 18 APIs?", likes: 88, reposts: 10, comments: 21, timestamp: "3h")
    ]
}

private struct Trend: Identifiable {
    let id = UUID()
    let category: String
    let title: String
    let tweetCount: String

    static let sample: [Trend] = [
        .init(category: "Technology", title: "#SwiftUI", tweetCount: "49.4K"),
        .init(category: "Business", title: "#AI", tweetCount: "120K"),
        .init(category: "Sports", title: "#USOpen", tweetCount: "87.3K"),
        .init(category: "Entertainment", title: "#Dune2", tweetCount: "63.1K"),
        .init(category: "Gaming", title: "#Starfield", tweetCount: "34.8K"),
        .init(category: "News", title: "#Election2025", tweetCount: "210K")
    ]
}

private struct Message: Identifiable {
    let id = UUID()
    let sender: String
    let senderInitials: String
    let snippet: String
    let timestamp: String

    static let sample: [Message] = [
        .init(sender: "Jane Doe", senderInitials: "JD", snippet: "That dashboard concept looks great—have you considered adding a compare mode?", timestamp: "1m"),
        .init(sender: "Product Team", senderInitials: "PT", snippet: "Roadmap sync moved to tomorrow 10am.", timestamp: "12m"),
        .init(sender: "Alex Kim", senderInitials: "AK", snippet: "Here’s the API response sample you asked for.", timestamp: "35m"),
        .init(sender: "Sam Park", senderInitials: "SP", snippet: "Nice work on the charts—let’s ship it.", timestamp: "1h"),
        .init(sender: "Support", senderInitials: "SU", snippet: "Two users asked about export options.", timestamp: "2h")
    ]
}

// MARK: - Preview

#Preview {
    DashboardView()
        .preferredColorScheme(.dark)
}
