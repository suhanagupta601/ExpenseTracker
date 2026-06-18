import SwiftUI

@main
struct ExpenseTrackerApp: App {
    @State private var viewModel = BudgetViewModel()
    @State private var theme = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environment(theme)

        }
    }
}
