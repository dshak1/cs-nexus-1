//
//  LeetCodeView.swift
//  CSNexus
//
//  Created by GitHub Copilot on 2025-10-05.
//

import SwiftUI

struct LeetCodeView: View {
    @StateObject private var leetCodeService = LeetCodeService()
    @State private var selectedDifficulty: String? = nil
    @State private var searchUsername = ""
    @State private var showingUserStats = false
    @State private var selectedProblem: LeetCodeProblem?
    @State private var completedProblems: Set<String> = []
    
    let difficulties = ["Easy", "Medium", "Hard"]
    let topics = ["array", "string", "hash-table", "dynamic-programming", "math", "sorting", "greedy", "depth-first-search", "binary-search", "two-pointers"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // User Stats Section
                userStatsSection
                
                // GitHub Contributions
                githubContributionsSection
                
                // Difficulty Filter
                difficultyFilterSection
                
                // Problems List
                if leetCodeService.isLoading {
                    ProgressView("Loading problems...")
                        .padding()
                } else if let error = leetCodeService.errorMessage {
                    errorView(message: error)
                } else {
                    problemsListSection
                }
            }
            .padding()
        }
        .navigationTitle("Coding Stats")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadProblems()
        }
        .refreshable {
            loadProblems()
        }
        .sheet(item: $selectedProblem) { problem in
            ProblemDetailSheet(problem: problem)
        }
        .sheet(isPresented: $showingUserStats) {
            UserStatsSheet(leetCodeService: leetCodeService, searchUsername: $searchUsername)
        }
    }
    
    // MARK: - User Stats Section
    private var userStatsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let stats = leetCodeService.userStats {
                // Compact stats display - left aligned
                HStack(spacing: 8) {
                    CompactStatPill(label: "Easy", count: stats.easySolved, color: .green)
                    CompactStatPill(label: "Medium", count: stats.mediumSolved, color: .orange)
                    CompactStatPill(label: "Hard", count: stats.hardSolved, color: .red)
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - GitHub Contributions Section
    private var githubContributionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with stats
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("GitHub Activity")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Last 52 weeks")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Compact stats
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text("247")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.branch")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("53")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text("23")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
            }
            
            // Contribution graph - scrollable horizontally
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    // Day labels
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer().frame(height: 15)
                        Text("Mon")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                            .frame(height: 15)
                        Spacer().frame(height: 15)
                        Text("Wed")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                            .frame(height: 15)
                        Spacer().frame(height: 15)
                        Text("Fri")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                            .frame(height: 15)
                        Spacer().frame(height: 15)
                    }
                    .frame(width: 30)
                    
                    // Contribution grid
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(15), spacing: 4), count: 7), spacing: 4) {
                        ForEach(0..<364, id: \.self) { day in
                            Rectangle()
                                .fill(contributionColor(for: day))
                                .frame(width: 15, height: 15)
                                .cornerRadius(3)
                        }
                    }
                    .padding(.leading, 4)
                }
            }
            
            // Legend
            HStack(spacing: 8) {
                Spacer()
                Text("Less")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 3) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(width: 12, height: 12)
                        .cornerRadius(2)
                    Rectangle()
                        .fill(Color.green.opacity(0.3))
                        .frame(width: 12, height: 12)
                        .cornerRadius(2)
                    Rectangle()
                        .fill(Color.green.opacity(0.6))
                        .frame(width: 12, height: 12)
                        .cornerRadius(2)
                    Rectangle()
                        .fill(Color.green.opacity(0.8))
                        .frame(width: 12, height: 12)
                        .cornerRadius(2)
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                        .cornerRadius(2)
                }
                
                Text("More")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func contributionColor(for day: Int) -> Color {
        let seed = (day * 7 + 13) % 20
        switch seed {
        case 0...8: return Color(.systemGray5)
        case 9...12: return Color.green.opacity(0.3)
        case 13...16: return Color.green.opacity(0.6)
        case 17...18: return Color.green.opacity(0.8)
        default: return Color.green
        }
    }
    
    // MARK: - Difficulty Filter Section
    private var difficultyFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    label: "All",
                    isSelected: selectedDifficulty == nil,
                    action: {
                        selectedDifficulty = nil
                        loadProblems()
                    }
                )
                
                ForEach(difficulties, id: \.self) { difficulty in
                    FilterChip(
                        label: difficulty,
                        isSelected: selectedDifficulty == difficulty,
                        action: {
                            selectedDifficulty = difficulty
                            loadProblems()
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Problems List Section
    private var problemsListSection: some View {
        LazyVStack(spacing: 12) {
            ForEach(leetCodeService.problems) { problem in
                ProblemCard(
                    problem: problem,
                    isCompleted: completedProblems.contains(problem.id),
                    onToggleComplete: {
                        toggleProblemCompletion(problem.id)
                    }
                )
                .onTapGesture {
                    selectedProblem = problem
                }
            }
        }
    }
    
    // MARK: - Toggle Completion
    private func toggleProblemCompletion(_ problemId: String) {
        if completedProblems.contains(problemId) {
            completedProblems.remove(problemId)
        } else {
            completedProblems.insert(problemId)
        }
    }
    
    // MARK: - Error View
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            
            Text("Connection Error")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Text("Please check:\n• Internet connection\n• Network settings\n• Try again in a moment")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: loadProblems) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
    }
    
    // MARK: - Load Problems
    private func loadProblems() {
        // Load mock data for demo
        leetCodeService.loadMockData()
    }
}

// MARK: - Problem Card
struct ProblemCard: View {
    let problem: LeetCodeProblem
    let isCompleted: Bool
    let onToggleComplete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox button
            Button(action: onToggleComplete) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isCompleted ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("#\(problem.id)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    DifficultyBadge(difficulty: problem.difficulty)
                }
                
                Text(problem.title)
                    .font(.headline)
                    .strikethrough(isCompleted, color: .secondary)
                    .foregroundColor(isCompleted ? .secondary : .primary)
                
                HStack {
                    Text("\(Int(problem.acRate))% acceptance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                // Topic tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(problem.topicTags.prefix(3)) { tag in
                            Text(tag.name)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .opacity(isCompleted ? 0.7 : 1.0)
    }
}

// MARK: - Difficulty Badge
struct DifficultyBadge: View {
    let difficulty: LeetCodeProblem.Difficulty
    
    var color: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(6)
    }
}

// MARK: - Stat Pill
struct StatPill: View {
    let label: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.headline)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Compact Stat Pill
struct CompactStatPill: View {
    let label: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - Problem Detail Sheet
struct ProblemDetailSheet: View {
    let problem: LeetCodeProblem
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("#\(problem.id)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            DifficultyBadge(difficulty: problem.difficulty)
                        }
                        
                        Text(problem.title)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    // Stats
                    HStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("Acceptance")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(Int(problem.acRate))%")
                                .font(.headline)
                        }
                        
                        Divider()
                            .frame(height: 30)
                        
                        VStack(alignment: .leading) {
                            Text("Difficulty")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(problem.difficulty.rawValue)
                                .font(.headline)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Topics
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Topics")
                            .font(.headline)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(problem.topicTags) { tag in
                                Text(tag.name)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Open in LeetCode button
                    Link(destination: problem.url) {
                        HStack {
                            Image(systemName: "arrow.up.right.square")
                            Text("Solve on LeetCode")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Problem Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - User Stats Sheet
struct UserStatsSheet: View {
    @ObservedObject var leetCodeService: LeetCodeService
    @Binding var searchUsername: String
    @Environment(\.dismiss) var dismiss
    @State private var isSearching = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Enter LeetCode username", text: $searchUsername)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .padding()
                
                Button(action: searchUser) {
                    if isSearching {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Load Stats")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(searchUsername.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(searchUsername.isEmpty || isSearching)
                
                if let error = leetCodeService.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Load LeetCode Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func searchUser() {
        isSearching = true
        Task {
            do {
                _ = try await leetCodeService.fetchUserStats(username: searchUsername)
                dismiss()
            } catch {
                print("Error fetching user stats: \(error)")
            }
            isSearching = false
        }
    }
}

// MARK: - Flow Layout (for wrapping tags)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

// MARK: - GitHub Stat Item
struct GitHubStatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    LeetCodeView()
}
