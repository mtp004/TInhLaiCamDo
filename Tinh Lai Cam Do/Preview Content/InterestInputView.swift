//
//  InterestInputView.swift
//  Tinh Lai Cam Do
//
//  Created by Tri Pham on 5/9/25.
//
import SwiftUI
import Foundation

struct InterestInputView: View {
	@State private var principal: String = ""
	@State private var interestRate: String = ""
	@State private var isMonthly: Bool = true  // true = monthly, false = yearly
	@State private var intervalCount: String = "" // number of months or years
	private var accumulate: Int {
		guard
			let principal = Double(principal),
			let rate = Double(interestRate),
			let count = Double(intervalCount)
		else {
			return 0 // invalid input
		}

		// Convert the interest rate depending on whether it is monthly or yearly
		let monthlyRate: Double
		if isMonthly {
			monthlyRate = rate / 100 // Convert percentage to decimal for monthly rate
		} else {
			// Convert yearly interest rate to monthly using compound interest formula
			monthlyRate = (pow(1 + (rate / 100), 1 / 12.0) - 1)
		}
		
		// Compound interest calculation
		let total = principal * pow(1 + monthlyRate, count)
		let payment = total - principal
		
		// Round the payment to the nearest 100 VND
		let roundedPayment = round(payment / 100) * 100

		return Int(roundedPayment)
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Text("Thông tin cầm đồ")
				.font(.headline)

			TextField("Số tiền gốc", text: $principal)
				.keyboardType(.decimalPad)
				.textFieldStyle(RoundedBorderTextFieldStyle())

			HStack {
				TextField("Lãi suất (%)", text: $interestRate)
					.keyboardType(.decimalPad)
					.textFieldStyle(RoundedBorderTextFieldStyle())
				Image(systemName: "percent")
				Picker("Kỳ hạn lãi", selection: $isMonthly) {
					Text("Theo tháng").tag(true)
					Text("Theo năm").tag(false)
				}
				.pickerStyle(SegmentedPickerStyle())
				.frame(maxWidth: .infinity)
			}

			HStack(spacing: 12) {
				TextField("Số kỳ", text: $intervalCount)
					.keyboardType(.numberPad)
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.frame(width: 80)
				Text("Tháng")
			}
			
			Text("Tiền lãi thu: \(accumulate) VND")
				.font(.title2)
				.fontWeight(.semibold)


			Spacer()
		}
		.padding()
	}
}
#Preview {
	InterestInputView()
}

