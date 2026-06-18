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
    @EnvironmentObject var viewModel: BudgetViewModel

    @State private var amount: String = ""
    @State private var selectedCategory: Category? = nil
    @State private var date: Date = Date()
    @State private var descr: String = ""

    // HELPER FUNCTIONS ------------>

    func addExpense() {
        // validate amount is a real number
        guard let amountDouble = Double(amount), amountDouble > 0 else {
            print("Invalid amount.")
            return
        }

        // validate a category was selected
        guard let category = selectedCategory else {
            print("No category selected.")
            return
        }

        let newExpense = Expense(
            amount: amountDouble,
            categoryID: category.id,
            date: date,
            descr: descr
        )

        viewModel.addExpense(newExpense)
        dismiss()
    }

    // MARK: - View

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

                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        Text("Select a category").tag(Category?.none)
                        ForEach(viewModel.categories) { cat in
                            HStack {
                                Image(systemName: cat.icon)
                                    .foregroundColor(cat.color)
                                Text(cat.name)
                            }
                            .tag(Category?.some(cat))
                        }
                    }
                }

                Section(header: Text("Date")) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section(header: Text("Description (optional)")) {
                    TextField("e.g. Lunch with friends", text: $descr)
                }

                Section {
                    Button("Add Expense") {
                        addExpense()
                    }
                    .disabled(amount.isEmpty || selectedCategory == nil)
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

#Preview {
    AddExpenseView()
    @EnvironmentObject var viewModel: BudgetViewModel
}
