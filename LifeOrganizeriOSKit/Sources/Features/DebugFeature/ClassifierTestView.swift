import SwiftUI
import ComposableArchitecture
import CoreUI

/// Simple test view for the ClassifierService
public struct ClassifierTestView: View {
    @Bindable var store: StoreOf<ClassifierTestFeature>

    public init(store: StoreOf<ClassifierTestFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: .lifeSpacingLG) {
                Text("Classifier Test")
                    .font(.lifeTitle1)
                    .foregroundColor(.lifeTextPrimary)

                // Input field
                TextField(
                    "Enter text to classify",
                    text: Binding(
                        get: { store.inputText },
                        set: { store.send(.inputTextChanged($0)) }
                    ),
                    axis: .vertical
                )
                .lineLimit(1...4)
                .font(.lifeBody)
                .foregroundColor(.lifeTextPrimary)
                .padding(.lifeSpacingMD)
                .background(
                    RoundedRectangle(cornerRadius: .lifeRadiusMD)
                        .fill(Color.lifeSurface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: .lifeRadiusMD)
                        .stroke(Color.lifeDivider, lineWidth: 1)
                )

                // Classify button
                Button {
                    store.send(.classifyButtonTapped)
                } label: {
                    if store.isClassifying {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    } else {
                        Text("Classify")
                            .font(.lifeBody)
                            .fontWeight(.medium)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.lifePrimary)
                .foregroundColor(.white)
                .cornerRadius(.lifeRadiusMD)
                .disabled(store.inputText.isEmpty || store.isClassifying)
                .opacity(store.inputText.isEmpty ? 0.5 : 1.0)

                // Result display
                if let result = store.classificationResult {
                    VStack(alignment: .leading, spacing: .lifeSpacingMD) {
                        Text("Result")
                            .font(.lifeTitle2)
                            .foregroundColor(.lifeTextPrimary)

                        HStack {
                            Text("Category:")
                                .font(.lifeBody)
                                .foregroundColor(.lifeTextSecondary)
                            Spacer()
                            Text(result.category.rawValue)
                                .font(.lifeBody)
                                .fontWeight(.semibold)
                                .foregroundColor(.lifePrimary)
                        }

                        HStack {
                            Text("Confidence:")
                                .font(.lifeBody)
                                .foregroundColor(.lifeTextSecondary)
                            Spacer()
                            Text(String(format: "%.2f%%", result.confidence * 100))
                                .font(.lifeBody)
                                .fontWeight(.semibold)
                                .foregroundColor(result.shouldUseFallback ? .orange : .lifeSuccess)
                        }

                        if result.shouldUseFallback {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.lifeIconSM)
                                Text("Low confidence - would fallback to backend")
                                    .font(.lifeCaption)
                                    .foregroundColor(.orange)
                            }
                            .padding(.top, .lifeSpacingXS)
                        }

                        Divider()
                            .padding(.vertical, .lifeSpacingXS)

                        Text("All Scores")
                            .font(.lifeCallout)
                            .foregroundColor(.lifeTextPrimary)

                        ForEach(Array(result.allScores.sorted(by: { $0.value > $1.value })), id: \.key) { category, score in
                            HStack {
                                Text(category.rawValue)
                                    .font(.lifeCaption)
                                    .foregroundColor(.lifeTextSecondary)
                                Spacer()
                                Text(String(format: "%.2f%%", score * 100))
                                    .font(.lifeCaption)
                                    .foregroundColor(.lifeTextSecondary)
                            }
                        }
                    }
                    .padding(.lifeSpacingMD)
                    .background(
                        RoundedRectangle(cornerRadius: .lifeRadiusMD)
                            .fill(Color.lifeSurface)
                    )
                }

                // Error display
                if let error = store.errorMessage {
                    HStack(spacing: .lifeSpacingSM) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.lifeError)
                            .font(.lifeIconMD)

                        Text(error)
                            .font(.lifeCaption)
                            .foregroundColor(.lifeError)
                    }
                    .padding(.lifeSpacingMD)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: .lifeRadiusMD)
                            .fill(Color.lifeError.opacity(0.15))
                    )
                }
            }
            .padding(.lifeSpacingLG)
        }
        .navigationTitle("Classifier Test")
    }
}

#Preview {
    NavigationStack {
        ClassifierTestView(
            store: Store(initialState: ClassifierTestFeature.State()) {
                ClassifierTestFeature()
            }
        )
    }
}
