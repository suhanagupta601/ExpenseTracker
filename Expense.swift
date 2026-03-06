//
//  Expense.swift
//  ExpenseTracker
//
//  Created by Suhana Gupta on 1/7/26.
//

import SwiftUI

struct Expense: Identifiable {
    var id = UUID()
    var amount: Double
    var category: String
    var date: Date
    var color: Color
}


