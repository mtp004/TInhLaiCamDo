import SwiftUI
import Foundation

struct InterestInputView: View {
	@State private var principal: String = ""
	@State private var interestRate: String = ""
	@State private var isMonthly: Bool = true
	@State private var intervalCount: String = ""

	@FocusState private var focusedField: Field?

	private enum Field: Hashable {
		case principal, rate, intervalCount
	}

	private static let numberFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.groupingSeparator = ","
		formatter.locale = Locale(identifier: "vi_VN")
		return formatter
	}()

	private func formatWithComma(_ value: UInt64) -> String {
		return InterestInputView.numberFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
	}

	private var accumulate: Int {
		let cleanedPrincipal = principal.replacingOccurrences(of: ",", with: "")
		guard let principalValue = Double(cleanedPrincipal),
			  let rate = Double(interestRate),
			  let count = Double(intervalCount) else {
			return 0
		}

		let monthlyRate: Double
		if isMonthly {
			monthlyRate = rate / 100
		} else {
			monthlyRate = (pow(1 + (rate / 100), 1 / 12.0) - 1)
		}

		let total = principalValue * pow(1 + monthlyRate, count)
		var payment = total - principalValue
		payment = round(payment / 100) * 100

		return Int(payment)
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Text("Thông tin cầm đồ")
				.font(.headline)

			TextField("Số tiền gốc", text: $principal)
				.keyboardType(.numberPad)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.focused($focusedField, equals: .principal)
				.onChange(of: principal) { newValue, _ in
					let numericValue = newValue.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
					if let intValue = UInt64(numericValue) {
						principal = formatWithComma(intValue)
					} else {
						principal = ""
					}
				}

			HStack {
				TextField("Lãi suất (%)", text: $interestRate)
					.keyboardType(.decimalPad)
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.focused($focusedField, equals: .rate)

				Image(systemName: "percent")
				Picker("Kỳ hạn lãi", selection: $isMonthly) {
					Text("Theo tháng").tag(true)
					Text("Theo năm").tag(false)
				}
				.frame(maxWidth: .infinity)
				.pickerStyle(SegmentedPickerStyle())
			}

			HStack(spacing: 6) {
				TextField("Số kỳ", text: $intervalCount)
					.keyboardType(.numberPad)
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.focused($focusedField, equals: .intervalCount)
				Text("Tháng")
			}

			Text("Tiền lãi thu: \(accumulate) VND")
				.font(.title2)
				.fontWeight(.semibold)

			Spacer()
		}
		.padding()
		.toolbar {
			ToolbarItemGroup(placement: .keyboard) {
				Spacer()
				Button("Done") {
					focusedField = nil
				}
			}
		}
	}
}

#Preview {
	InterestInputView()
}

