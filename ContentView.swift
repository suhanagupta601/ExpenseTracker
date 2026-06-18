
// login page -> main page with tabs on bottom and pie chart
import SwiftUI

struct ContentView: View {
    
    @State private var isLogin = false
    
    var body: some View {
        if (!isLogin) { // change back to isLogin
            mainAppView
        } else {
            LoginView(isLogin: $isLogin)
        }
    }
    
    var mainAppView: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            TabView {
                
                InsightsView()
                    .tabItem {
                        Image(systemName: "chart.pie.fill")
                        Text("Insights")
                    }.tag(1)
               
                Spacer()
                
                Text("Tab Content 2")
                    .tabItem {
                        Image(systemName:"square.grid.2x2.fill" )
                        Text("Categories")
                    }.tag(2)
                
                Spacer()
                
                Text("Tab Content 3")
                    .tabItem {
                        Image(systemName: "clock.fill")
                        Text("History")
                    }.tag(3)
                
            }

            
            
            
            
            
            
            
            
            
            
            
            
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(BudgetViewModel())
        .environment(ThemeManager())
}
