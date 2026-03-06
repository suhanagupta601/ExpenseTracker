//
//  AddExpenseView.swift
//  ExpenseTracker

/* NOTES --->
 @Binding = this data does not belong to this file, but i am borrowing it from another file and modifying it for it
 @State = only belongs to THIS view in local variables
 */


import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var allExpenses: [Expense] // need to add new expense to list (update everything)
    
    @State private var amount: String = ""
    @State private var category: String = ""
    @State private var date: Date = Date()
    
    @State private var otherCategory: String = ""
    @State private var otherColor: Color = .blue
    @State private var showOtherCategory: Bool = false
    
    
    @State private var categoryColors: [String: Color] = [
        "Food": .yellow,
        "Groceries": .green,
        "Transportation": .orange,
        "Clothes": .pink,
        "Entertainment": .purple,
        "Rent": .brown,
        "Other": .gray
    ]
    
    let categories: [String] = ["Food", "Groceries", "Transportation", "Clothes", "Entertainment", "Rent", "Other"]
    
    
    // ***** HELPER FUNCs ***** --------------------------------------
    
    func addExpense() {
        /*
         - add this new expense to the allExpenses list as an EXPENSE
         - add it to the pie chart
         - add to history // LATER //
         
         - extract information inputted into variables as an Expense Struct
         */
        if let amountDoub = Double(amount) {
            let newExpense = Expense (
                amount: amountDoub,
                category: category,
                date: date,
                color: getCategoryColor(ctg: category)
            )
            
            allExpenses.append(newExpense)
            
            dismiss()
        }
        
        else {
            print("Invalid amount. Enter a decimal value number.")
            return
        }
    }
    
    func getCategoryColor(ctg: String) -> Color {
        switch ctg {
            
        case "Food":
            return .yellow
            
        case "Groceries":
            return .green
            
        case "Transportation":
            return .orange
            
        case "Clothes":
            return .pink
            
        case "Entertainment":
            return .purple
            
        case "Rent":
            return .brown
            
            // change into drop down for color choosing and entering custom color //LATER//
        case "Other":
            return .gray
            
        default:
            return .black
        }
        
    }
    
    
    
    // ***** VIEW ***** --------------------------------------
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Amount")) {
                    HStack {
                        Text("$")
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                }
                
                // makae it into a dropdown menu
                Section(header: Text("Category")) {
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    
                    .onChange(of: category) {
                        oldValue,
                        newValue in
                        
                        if (newValue == "Other") {
                            showOtherCategory = true
                        }
                    }
                }
                
                Section(header: Text("Date")) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                
                
                Section {
                    Button("Add Expense") {
                        addExpense()
                    }
                    .disabled(amount.isEmpty || category.isEmpty)
                }
            }
            .navigationTitle("New Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

