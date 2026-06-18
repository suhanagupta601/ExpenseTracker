

import SwiftUI
import Charts

struct InsightsView: View {
    // in order th=o access allExpenses list, amounts, cats, etc. - belongs to view as well
    @EnvironmentObject var viewModel: BudgetViewModel
    @State private var showAddExpense = false
    
    /*
     BUDGET HEADER
     */
    //@State private var showingBudgetEditor = false
    @State private var draftBudget = ""
    @State private var isEditingBudget = false
    @FocusState private var budgetFieldFocused: Bool
    
    @Environment(ThemeManager.self) private var theme

    

    
/* VAR categoryGroups:
 purpose - get CURRENT month's categories and their amounts to add data to the PIE CHART
 output - array of dictionary of [(catgeory : amount in cat)]
 */
    var categoryGroups: [(category: Category, amount: Double)] {
        // go through the allExpenses and filter using uuid (each category has a uuid - not using cat's name bc user can update the cat's name, but the past expenses under cat would have the old name, thus messing the order of teh pie chart
        
        // dictionary to get the acc totals of each cat
        var categoryTotals: [UUID: Double] = [:]
        
        // for each expense, if uuid NOT in catTotals, add and initialize the amount, ELSE if uuid IN catTotals, update the amount total
        for expense in viewModel.currentMonthExpensesList {
            // if the cat exists w its curr total, then add the new one to the existing total
            if let existing = categoryTotals[expense.categoryID] {
                categoryTotals[expense.categoryID] = existing + expense.amount
            }
            else { // else add new cat to dict
                categoryTotals[expense.categoryID] = expense.amount
            }
        }
        
        // sort the list largest -> least
        // compactMap used for category lookup - what if cat was deleted...
        return categoryTotals.compactMap {id, amount in guard let category = viewModel.category(withID: id)
                                                                // guard bc viewModel.cat returns Category? if cat was deleted
                                                                
            else {return nil}
            return (category: category, amount: amount)
        }
        .sorted {$0.amount > $1.amount
        }
    }
        
    
    /* VAR topCategory
     purpose - to get the category with the most expenses/largest amount
     output - string
     */
    var topCategory: String {
        guard let topCat = categoryGroups.first else {
            return "No expenses have been made yet"
        }
        return topCat.category.name
    }
    
    /*
     VAR recurringCategory
     purpose - get the category with the recurring expense aka, category that has the most entries, regardless of the amount
     output - string
     how - get the category that shows up the most in currmonthexplist and keep a dict w (category : #)
     */
    var recurringCategory: String {
        var countDict: [UUID: Int] = [:]
        
        for expense in viewModel.currentMonthExpensesList {
            countDict[expense.categoryID, default: 0] += 1
        }
        
        guard let maxID = countDict.max(by: {$0.value < $1.value})?.key,
              let category = viewModel.category(withID: maxID)
        else {
            return "No expenses made"
        }
        return category.name
    }
 

    
    
    /* VAR budgetStatusText
     purpose - is user over/under budget
     return - string
     */
    var budgetStatusText: String {
        // no budget set
        guard viewModel.isBudgetExist else {
            return "No budget set" }
        
        // over
        if viewModel.remainingBudget < 0 {
            return "Over by \(abs(viewModel.remainingBudget).formatted(.currency(code: "USD")))"
        }
        
        // under
        return "\(viewModel.remainingBudget.formatted(.currency(code: "USD"))) remaining"
    }
    
    
    /*
     VAR budgetStatusColor
     purpose - color code status
     return - Color
     */
    
    var budgetStatusColor: Color {
        // is there a budget, else
        guard viewModel.isBudgetExist
        else {
            return .secondary
        }
        return viewModel.remainingBudget < 0 ? .red : .green
    }

    func getCurrentMonthName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }
    
    
    
    // header helpers
    // progress 0...1 for the bar (capped at full)
    var budgetProgress: Double {
        guard viewModel.isBudgetExist, viewModel.monthlyBudget > 0 else {
            return 0
        }
        return min(viewModel.currentMonthExpense / viewModel.monthlyBudget, 1.0)
    }

    // the summary line under the month
    var budgetHeaderSummary: String {
        guard viewModel.isBudgetExist
        else {
            return "Tap to set a budget"
        }
        if viewModel.remainingBudget < 0 {
            return "Over by \(abs(viewModel.remainingBudget).formatted(.currency(code: "USD")))"
        }
        return "\(viewModel.remainingBudget.formatted(.currency(code: "USD"))) left of \(viewModel.monthlyBudget.formatted(.currency(code: "USD")))"
    }

    // shows "500" not "500.0" when pre-filling the field
    func budgetString(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(value)
    }
    
    
    
    /*
     add expense BUTTON
     */
    var addExpenseButton: some View {
        Button {
            showAddExpense = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(theme.current.background)
                .frame(width: 60, height: 60)
                .background(Circle().fill(theme.current.accent))
                .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
        }
    }
    
    // the spendings wrapped - revamp
    func insightCard(icon: String, iconColor: Color, label: String, value: String, valueColor: Color? = nil) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: 38, height: 38)
                .background(iconColor.opacity(0.18))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 2) {
                Text(label.uppercased())
                    .font(.caption2)
                    .foregroundColor(theme.current.textSecondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(valueColor ?? theme.current.textPrimary)
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(theme.current.surface)
        .cornerRadius(14)
    }
    
    
    // ***** INSIGHTS VIEW UI ***** --------------------------------------
    
    var body: some View {
        ZStack {
            
            ScrollView {
                VStack(spacing: 8) {
                    // total spent this month (should not be able to edit)
                    Text(viewModel.currentMonthExpense.formatted(.currency(code: "USD")))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(theme.current.textPrimary)

                    Text(getCurrentMonthName())
                        .font(.subheadline)
                        .fontWeight(.heavy)
                        .foregroundColor(theme.current.textSecondary)

                    // budget line — flips between display and edit
                    if isEditingBudget {
                        HStack(spacing: 2) {
                            Text("$").foregroundColor(theme.current.textSecondary)
                            TextField("0", text: $draftBudget)
                                .keyboardType(.decimalPad)
                                .fixedSize()
                                .focused($budgetFieldFocused)
                                .foregroundColor(theme.current.accent)
                                .onAppear {
                                    // *tiny delay so the field exists before we focus it*
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                        budgetFieldFocused = true
                                    }
                                }
                        }
                        .font(.callout)
                        .fontWeight(.medium)
                    } else {
                        Button {
                            draftBudget = viewModel.isBudgetExist ? budgetString(viewModel.monthlyBudget) : ""
                            isEditingBudget = true
                        } label: {
                            HStack(spacing: 6) {
                                Text(budgetHeaderSummary)
                                Image(systemName: "pencil").font(.caption2)
                            }
                            .font(.caption)
                            .foregroundColor(viewModel.isBudgetExist ? theme.current.textSecondary : theme.current.accent)
                        }
                        .buttonStyle(.plain)
                    }

                    // progress bar (only once a budget exists)
                    if viewModel.isBudgetExist {
                        ProgressView(value: budgetProgress)
                            .tint(viewModel.remainingBudget < 0 ? theme.current.overBudget : theme.current.accent)
                            .frame(maxWidth: 200)
                            .padding(.top, 2)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(theme.current.surface)
                .cornerRadius(40)
                .padding(.horizontal)
                .onChange(of: budgetFieldFocused) { _, focused in
                    // commit when the user taps Done or taps away
                    if !focused && isEditingBudget {
                        if let amount = Double(draftBudget), amount > 0 {
                            viewModel.updateBudget(amount)
                        }
                        isEditingBudget = false   // invalid/empty just reverts
                    }
                }
                
                

                // pie chart
                if !viewModel.currentMonthExpensesList.isEmpty {

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Currently...")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        Chart(categoryGroups, id: \.category.id) { item in
                            SectorMark(
                                angle: .value("Amount", item.amount),
                                innerRadius: .ratio(0.6),
                                angularInset: 1.5
                            )
                            .foregroundStyle(item.category.color)
                            .cornerRadius(4)
                        }
                        .frame(height: 300)
                        .overlay { addExpenseButton }
                        .padding(.horizontal)
                        
                        // INSIGHTS
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your month, wrapped")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(theme.current.textPrimary)
                                .padding(.bottom, 2)
                            
                            insightCard(icon: "flame.fill", iconColor: theme.current.overBudget,
                                        label: "Top category", value: topCategory)
                            
                            insightCard(icon: "repeat", iconColor: theme.current.underBudget,
                                        label: "Most frequent", value: recurringCategory)
                            
                            insightCard(icon: "wallet.bifold.fill", iconColor: theme.current.underBudget,
                                        label: "Budget status", value: budgetStatusText, valueColor: budgetStatusColor)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 120)
                    }

                }
                else {
                    // empty state with the button reachable when there are no expenses
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .strokeBorder(style: StrokeStyle(lineWidth: 14, dash: [3, 7]))
                                .foregroundColor(theme.current.textSecondary.opacity(0.35))
                                .frame(width: 200, height: 200)
                            addExpenseButton
                        }
                        Text("No expenses yet — tap + to add one")
                            .font(.caption)
                            .foregroundColor(theme.current.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                }
                                
                
                
            }
        }
        .sheet(isPresented: $showAddExpense) {
            AddExpenseView()
        }
        .background(theme.current.background.ignoresSafeArea())
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { budgetFieldFocused = false }
            }
        }
    }
    
}



#Preview {
    InsightsView()
        .environmentObject(BudgetViewModel())
        .environment(ThemeManager())
}
