//
//  ContentView.swift
//  Animation Playground
//
//  Created by Rajveer Tut on 10/18/24.
//

import SwiftUI
import SwiftData
import UIKit

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
    let cardSpacing: CGFloat = 10
    let compressionLineOffset: CGFloat = 150
    let completedCardSpacing: CGFloat = 10 // Spacing between completed cards
    let compressionThreshold: CGFloat = 0.8 // Compression required to be marked as completed
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(spacing: 0) { // Zero spacing, handled individually for each card
                        ForEach(Array(checklistItems.enumerated()), id: \.element.id) { index, item in
                            CompressibleCardView(item: $checklistItems[index], 
                                                 cardHeight: cardHeight,
                                                 compressionLineOffset: compressionLineOffset,
                                                 compressionThreshold: compressionThreshold)
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
    let compressionLineOffset: CGFloat
    let compressionThreshold: CGFloat
    
    @State private var lastCompressionPercentage: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            // Use GeometryReader to access the view's position and size within its parent
            
            // Calculate the vertical position (Y-coordinate) of the top edge of this view
            // within the coordinate space named "scroll" (likely a ScrollView)
            let minY = geometry.frame(in: .named("scroll")).minY
            
            // Calculate how far the top of the view is from the compression start line
            // A positive value means the view is below the line, negative means it's above
            let distanceFromCompressionLine = minY - compressionLineOffset
            
            // Determine the amount of compression to apply:
            // - If distanceFromCompressionLine is positive, no compression (max with 0)
            // - Otherwise, compress up to the difference between full and compressed height
            // - The negative sign inverts distanceFromCompressionLine for the calculation
            let compressionAmount = max(0, min(cardHeight, -distanceFromCompressionLine))
            
            // Calculate the percentage of compression applied
            // 0% means no compression, 100% means fully compressed
            let compressionPercentage = compressionAmount / (cardHeight)
            
            VStack(alignment: .leading, spacing: 10) {
                // Card title and checkbox
                HStack {
                    Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                        .foregroundColor(item.isChecked ? .green : .gray)
                    Text(item.title)
                        .font(.headline)
                        .strikethrough(item.isChecked)
                        .opacity(1 - compressionPercentage)
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
                Text("Y: \(minY, specifier: "%.2f"), Compression%: \(compressionPercentage, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text("CompressAmount: \(compressionAmount, specifier: "%.2f"), DistFromCompressLine: \(distanceFromCompressionLine, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: cardHeight)
            .background(
                ZStack {
                    Color.white
                    Color.init(red: 0.133, green: 0.545, blue: 0.133) // Forest Green
                        .opacity(compressionPercentage)
                }
            )
            .cornerRadius(10)
            .shadow(radius: 3)
            .scaleEffect(
                y: item.isChecked ? 1 : 1 - compressionPercentage,
                anchor: .top
            )
            .offset(y: item.isChecked ? -compressionLineOffset : max(-compressionAmount, -distanceFromCompressionLine))
            .animation(.easeInOut(duration: 0.05), value: compressionAmount)
            .onChange(of: compressionPercentage) { _, newValue in
                // Check if the compression percentage has just reached the threshold
                if newValue >= compressionThreshold && lastCompressionPercentage < compressionThreshold {
                    // Provide strong haptic feedback when compression threshold is reached
                    let impact = UIImpactFeedbackGenerator(style: .heavy)
                    impact.impactOccurred(intensity: 1.0)
                }
                
                // Mark item as checked when compression threshold is reached
                if newValue >= compressionThreshold && !item.isChecked {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        item.isChecked = true
                    }
                }
                
                // Update the last compression percentage
                lastCompressionPercentage = newValue
            }
        }
        .frame(height: cardHeight)
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
