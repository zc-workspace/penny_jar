import SwiftData
import SwiftUI

@main
struct PennyJarApp: App {
    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try PennyJarModelContainer.make()
        } catch {
            fatalError("Unable to create Penny Jar storage: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(modelContainer)
    }
}
