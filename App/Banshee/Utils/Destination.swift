import Foundation

protocol Destination: Hashable {
    
}

extension Destination where Self: Identifiable, Self.ID == UUID {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
