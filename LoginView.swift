//
//  LoginView.swift
//  ExpenseTracker
//
//  Created by Suhana Gupta on 1/5/26.
//

// @State creates a local var that swiftUI tracks for changes (mutable)
// $ = binding to that state var
// @Binding lets LoginView communicate with ContentView if login successful

import SwiftUI

struct LoginView: View {
    
    @State private var email = ""
    @State private var password = ""
    @Binding var isLogin: Bool
    
    
    
    
    var body: some View {
        VStack {
            Text("Expense Tracker (logo)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(10)
            
            // email
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .padding(.horizontal)
                .padding(.bottom, 10)
            
            
            //password
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .padding(.bottom, 10)

        }
        
        Button(action: {
            isLogin = true
        }) {
            Text("Log In")
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.brown)
                .cornerRadius(30)
                .padding(.horizontal)
        }
        
        // to sign up
        Button(action: {
            // signing up
        }) {
            Text("Don't have an account? Sign up")
                .foregroundColor(.blue)
        }
        .padding(.top, 10)
        
    }
    
    
    
    
}



#Preview {
    LoginView(isLogin: .constant(false))
}





