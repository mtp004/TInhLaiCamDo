import SwiftUI
import Foundation

struct InterestInputView: View {
	@State private var principal: String = ""
	@State private var interestRate: String = ""
	@State private var isMonthly: Bool = true  // true = monthly, false = yearly
	@State private var intervalCount: String = "" // number of months or years
	
	// NumberFormatter instance for reuse
	private static let numberFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.groupingSeparator = ","
		formatter.locale = Locale(identifier: "vi_VN") // For VND (Vietnamese Dong)
		return formatter
	}()
	
	// Function to format number with commas
	private func formatWithComma(_ value: UInt64) -> String {
		return InterestInputView.numberFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
	}
	
	private var accumulate: Int {
		let cleanedPrincipal = principal.replacingOccurrences(of: ",", with: "")
		
		guard let principalValue = Double(cleanedPrincipal),
			  let rate = Double(interestRate),
			  let count = Double(intervalCount) else {
			return 0 // invalid input
		}
		
		let monthlyRate: Double
		if isMonthly {
			monthlyRate = rate / 100
		} else {
			monthlyRate = (pow(1 + (rate / 100), 1 / 12.0) - 1)
		}
		
		// Compound interest calculation
		let total = principalValue * pow(1 + monthlyRate, count)
		let payment = total - principalValue
		
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
				.onChange(of: principal) { newValue, _ in
					let numericValue = newValue.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
//					
					if let intValue = UInt64(numericValue){
						principal = formatWithComma(intValue)
					} else{
						principal = ""
					}
				}
			
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
			
			HStack(spacing: 6) {
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

