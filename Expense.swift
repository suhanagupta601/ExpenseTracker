//
//  Expense.swift
//  ExpenseTracker
//
//  Created by Suhana Gupta on 1/7/26.
//

import SwiftUI

struct Expense: Identifiable {
    var id: UUID = UUID()
    var amount: Double
    var categoryID: UUID // points to Category ... for any edits to a category/deletions
    var date: Date
    var descr: String = "" // expense description - optional
}


