import Foundation

/// Action to add items to iOS shopping list
public struct AddToShoppingListActionDTO: Codable, Sendable {
    /// Action type discriminator (always "add_to_shopping_list")
    let type: String

    // TODO: Add specific fields when backend schema is finalized

    enum CodingKeys: String, CodingKey {
        case type
    }
}
