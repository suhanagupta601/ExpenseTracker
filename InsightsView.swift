//
//  InsightsView.swift
//  ExpenseTracker
//
//  Created by Suhana Gupta on 1/7/26.
//

import SwiftUI
import Charts

struct InsightsView: View {
    @State private var allExpenses: [Expense] = []
    @State private var newAmount: String = ""
    @State private var newCategory: String = ""
    @State private var showAddExpense = false
    
    let categoryColors: [String: Color] = [
        "Food": .yellow,
        "Groceries": .green,
        "Transportation": .orange,
        "Clothes": .pink,
        "Entertainment": .purple,
        "Rent": .brown,
        "Other": .gray
    ]
    
    // *** COMPLETE TOTAL EXPENSE of all months
    
    /* allExpenses.reduce(0) {$0 + $1.amount} -> reduce is a function that provides initial acc value of 0. $0 = first parameter passed into expenses, $1 = second parameter or current element being processed from array */
    var totalExp: Double {
        allExpenses.reduce(0) {
            $0 + $1.amount
        }
    }
    
    //*** CURRENT MONTH EXPENSE
    var currMonthExpList: [Expense] {
        let calendar = Calendar.current
        let currentDate = Date()
        
        let monthInt = calendar.component(.month, from: currentDate)
        
        var expInMonth: [Expense] = []
        
        for expense in allExpenses {
            let expenseMonth = calendar.component(.month, from: expense.date)
            
            if (expenseMonth == monthInt) {
                expInMonth.append(expense)
            }
        }
        return expInMonth
    }
    
    //*** TOTAL MONTH'S EXPENSE
    var currMonthExp: Double {
        currMonthExpList.reduce(0) {
            $0 + $1.amount
        }
    }
    
    /*
     FUNCTIONS/HELPERS ---------------------------------------
     */
    
    func getCurrMonthName() -> String {
        let format = DateFormatter()
        format.dateFormat = "MMMM yyyy"
        
        return format.string(from: Date())
    }
    
    // gets all expenses, groups them by category, and adds up the totals for each category creating pie sections
    func getCategoryGroups() -> [(category: String, amount: Double, color: Color)] {
        
        // using a dictionary to store amount to color of category
        var categoryDict: [String: (amount: Double, color: Color)] = [:]
        
        for expense in currMonthExpList {
            if let categoryExists = categoryDict[expense.category] {
                categoryDict[expense.category] = (categoryExists.amount + expense.amount, categoryExists.color)
            }
            
            else {
                categoryDict[expense.category] = (expense.amount, expense.color)
            }
        }
        
        return categoryDict.map{(category: $0.key, amount: $0.value.amount, color: $0.value.color)
            // converting dictionary to array
        }
        .sorted {
            $0.amount > $1.amount
        }
    }
    
    
    // has the biggest section in the pie chart = category with the most accumulated money
    func getTopCategory() -> String {
        let catGroups = getCategoryGroups()
        
        if catGroups.isEmpty {
            return "No expenses have been made yet"
        }
        else {
            return catGroups[0].category + ": " + "$" + String(catGroups[0].amount)
        }
    }
        
    // get category with most entries
    func getRecurringExpense() -> String {
        
        var catDict: [String : Int] = [:]
        catDict["Food"] = 0
        catDict["Groceries"] = 0
        catDict["Transportation"] = 0
        catDict["Clothes"] = 0
        catDict["Entertainment"] = 0
        catDict["Rent"] = 0
        catDict["Other"] = 0
        
        for expense in currMonthExpList {
            catDict[expense.category, default: 0] += 1
        }
        
        var topCat: String = ""
        var mostNum: Int = 0
        
        for (cat, num) in catDict {
            if num > mostNum {
                mostNum = num
                topCat = cat
            }
        }
        return topCat
    }
    

    func getOverBudget() -> String {
        return ""
    }
    
   
    
    
    // ***** VIEW ***** --------------------------------------
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    // current total expense display
                    Text("$" + String(currMonthExp))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                    
                    // subheader of month's name
                    Text(getCurrMonthName())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fontWeight(.heavy)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(40)
                .padding(.horizontal)
                
                // pie chart
                if (!currMonthExpList.isEmpty) { // when rendering: !currMonthExpList
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Currently...")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        Chart(getCategoryGroups(), id: \.category) { item in
                            SectorMark(
                                angle: .value("Amount", item.amount),
                                innerRadius: .ratio(0.6),
                                angularInset: 1.5
                            )
                            .foregroundStyle(item.color)
                            .cornerRadius(4)
                        }
                        .frame(height: 300)
                        .padding(.horizontal)
                        
                        // INSIGHTS AKA current expense wrapped
                        
                        VStack {
                            Text("MONTHLY WRAP ... at least for now")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            HStack {
                                // !!! helper func calculating biggest spending (use getCatGroups as a helper)
                                Text("🔥 Top Category: " + getTopCategory())
                            }
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                            .fontWeight(.medium)
                            
                            // the category that showed up the most so far
                            HStack {
                                Text("💋 Recurring Expense: " + getRecurringExpense())
                            }
                            .font(.subheadline)
                            .foregroundColor(.orange)
                            .padding(.horizontal)
                            .fontWeight(.medium)
                            
                            // calculate the percentage of current spendings/budget and use an emoji scale
                            HStack {
                                Text("💰 Are we over-budget? " + getOverBudget())
                            }
                            .font(.subheadline)
                            .foregroundColor(.yellow)
                            .padding(.horizontal)
                            .fontWeight(.medium)
                            
                            
                        }
                        
                        // add expense button
                        VStack {
                            Button(action: {
                                showAddExpense = true }) {
                                    Image(systemName: "plus")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                }
                                .padding(.trailing, 20)
                                .padding(.bottom, 20)
                        }
                    }
                }
            }
            
            // ADD EXPENSE BUTTON
            VStack {
                HStack {
                    Button(action: {
                        showAddExpense = true
                    }) {
                        Image(systemName: "plus")
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                            .frame(width: 30, height: 30)
                            .background(Color.green)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showAddExpense) {
            AddExpenseView(allExpenses: $allExpenses)
        }
        
    }
}


// *** for testing purposes 
#Preview {
    @Previewable @State var testExpenses: [Expense] = [
            Expense(amount: 50, category: "Food", date: Date(), color: .yellow),
            Expense(amount: 1200, category: "Rent", date: Date(), color: .brown),
            Expense(amount: 30, category: "Transportation", date: Date(), color: .orange),
            Expense(amount: 25, category: "Food", date: Date(), color: .yellow),
            Expense(amount: 80, category: "Entertainment", date: Date(), color: .purple)
        ]
        
        return InsightsView()
}

