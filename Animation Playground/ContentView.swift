//
//  ContentView.swift
//  Animation Playground
//
//  Created by Rajveer Tut on 10/18/24.
//

import SwiftUI
import SwiftData

// Defines the structure for each checklist item
struct ChecklistItem: Identifiable {
    let id = UUID()
    var title: String
    var isChecked: Bool
    var insight: String
}

struct ContentView: View {
    // State to hold the list of checklist items
    @State private var checklistItems: [ChecklistItem] = []
    
    // Constants for card dimensions and layout
    let cardHeight: CGFloat = 120
    let cardSpacing: CGFloat = 15
    let compressionLineOffset: CGFloat = 200
    let completedCardHeight: CGFloat = 60 // Height of a completed (compressed) card
    let completedCardSpacing: CGFloat = 5 // Spacing between completed cards
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(spacing: 0) { // Zero spacing, handled individually for each card
                        ForEach(Array(checklistItems.enumerated()), id: \.element.id) { index, item in
                            CompressibleCardView(item: $checklistItems[index], 
                                                 cardHeight: cardHeight,
                                                 completedCardHeight: completedCardHeight,
                                                 compressionLineOffset: compressionLineOffset)
                                .padding(.bottom, item.isChecked ? completedCardSpacing : cardSpacing)
                        }
                    }
                    .padding(.top, compressionLineOffset)
                    .padding()
                }
                .coordinateSpace(name: "scroll") // Named coordinate space for scroll position tracking
                
                // Red line indicating the compression threshold
                Rectangle()
                    .fill(Color.red)
                    .frame(height: 2)
                    .offset(y: compressionLineOffset)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: resetChecklist) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear(perform: initializeChecklist)
    }
    
    // Initializes the checklist with predefined items
    private func initializeChecklist() {
        checklistItems = [
            ChecklistItem(title: "Review monthly budget", isChecked: false, insight: getRandomInsight()),
            ChecklistItem(title: "Check credit score", isChecked: false, insight: getRandomInsight()),
            ChecklistItem(title: "Pay off credit card", isChecked: false, insight: getRandomInsight()),
            ChecklistItem(title: "Set up automatic savings", isChecked: false, insight: getRandomInsight()),
            ChecklistItem(title: "Research investment options", isChecked: false, insight: getRandomInsight()),
            ChecklistItem(title: "Update emergency fund", isChecked: false, insight: getRandomInsight()),
            ChecklistItem(title: "Review insurance policies", isChecked: false, insight: getRandomInsight()),
            ChecklistItem(title: "Plan for taxes", isChecked: false, insight: getRandomInsight()),
            ChecklistItem(title: "Set financial goals", isChecked: false, insight: getRandomInsight()),
            ChecklistItem(title: "Track expenses for a week", isChecked: false, insight: getRandomInsight()),
            ChecklistItem(title: "Research retirement accounts", isChecked: false, insight: getRandomInsight()),
            ChecklistItem(title: "Create a debt repayment plan", isChecked: false, insight: getRandomInsight()),
            ChecklistItem(title: "Review subscriptions", isChecked: false, insight: getRandomInsight()),
            ChecklistItem(title: "Check for unused services", isChecked: false, insight: getRandomInsight()),
            ChecklistItem(title: "Learn about compound interest", isChecked: false, insight: getRandomInsight()),
            ChecklistItem(title: "Start a side hustle", isChecked: false, insight: getRandomInsight())
        ]
    }
    
    // Resets the checklist to its initial state
    private func resetChecklist() {
        withAnimation {
            initializeChecklist()
        }
    }
}

// View for each compressible card in the checklist
struct CompressibleCardView: View {
    @Binding var item: ChecklistItem
    let cardHeight: CGFloat
    let completedCardHeight: CGFloat
    let compressionLineOffset: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            // Calculate compression based on scroll position
            let minY = geometry.frame(in: .named("scroll")).minY
            let distanceFromCompressionLine = minY - compressionLineOffset
            let compressionAmount = max(0, min(cardHeight / 2, -distanceFromCompressionLine))
            let compressionPercentage = compressionAmount / (cardHeight / 2)
            
            VStack(alignment: .leading, spacing: 10) {
                // Card title and checkbox
                HStack {
                    Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                        .foregroundColor(item.isChecked ? .green : .gray)
                    Text(item.title)
                        .font(.headline)
                        .strikethrough(item.isChecked)
                    Spacer()
                }
                
                // Card insight (hidden when fully compressed or checked)
                if compressionPercentage < 1 && !item.isChecked {
                    Text(item.insight)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .opacity(1 - compressionPercentage)
                }
                
                // Debug information
                Text("Y: \(minY, specifier: "%.2f"), Compression: \(compressionPercentage, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: item.isChecked ? completedCardHeight : cardHeight - compressionAmount)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 3)
            .offset(y: item.isChecked ? -compressionLineOffset : -compressionAmount)
            .animation(.easeInOut(duration: 0.1), value: compressionAmount)
            .onChange(of: compressionPercentage) { _, newValue in
                // Mark item as checked when fully compressed
                if newValue >= 0.99 && !item.isChecked {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        item.isChecked = true
                    }
                }
            }
        }
        .frame(height: item.isChecked ? completedCardHeight : cardHeight)
    }
}

// PreferenceKey for tracking scroll offset
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// Function to get a random financial insight
func getRandomInsight() -> String {
    let insights = getInsights()
    return insights.randomElement() ?? ""
}

// Function to provide a list of financial insights
func getInsights() -> [String] {
    return [
        "Saving 20% of your income can significantly boost your financial security.",
        "Compound interest can help your money grow faster over time.",
        "Diversifying your investments can help manage risk.",
        "Paying off high-interest debt first can save you money in the long run.",
        "An emergency fund can provide a financial safety net.",
        "Regularly reviewing your budget can help you stay on track with your financial goals.",
        "Automating your savings can make it easier to build wealth over time.",
        "Understanding your credit score can help you make better financial decisions.",
        "Investing in low-cost index funds can be a simple way to grow your wealth.",
        "Planning for taxes throughout the year can prevent financial stress during tax season."
    ]
}

// Preview provider for SwiftUI canvas
#Preview {
    ContentView()
}
