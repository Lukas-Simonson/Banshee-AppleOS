import Foundation

public struct CoreAlert: Identifiable {
    public let id = UUID()
    public let title: LocalizedStringResource
    public let message: LocalizedStringResource
    public let dismissible: Bool
    
    public let actions: [Action]
    
    public init(title: LocalizedStringResource, message: LocalizedStringResource, dismissible: Bool = true, actions: Action...) {
        self.title = title
        self.message = message
        self.dismissible = dismissible
        self.actions = actions
    }
    
    public struct Action: Identifiable {
        public let id = UUID()
        public let title: LocalizedStringResource
        public let action: () -> Void
        
        public init(title: LocalizedStringResource, action: @escaping () -> Void) {
            self.title = title
            self.action = action
        }
    }
}
