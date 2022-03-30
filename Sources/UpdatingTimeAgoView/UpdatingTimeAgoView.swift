import Foundation
import SwiftUI
import Combine

public class UpdatingTimeAgoViewStore: ObservableObject {

    @Published var currentTimeAgo: TimeInterval

    private let targetDate: Date
    private var cancellables = Set<AnyCancellable>()

    public init(targetDate: Date, updateFrequency: TimeInterval) {
        self.targetDate = targetDate
        self.currentTimeAgo = Self.calculateTimeAgo(targetDate: targetDate)

        Timer.publish(every: updateFrequency, tolerance: updateFrequency / 2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }

                self.currentTimeAgo = Self.calculateTimeAgo(targetDate: self.targetDate)
            }
            .store(in: &cancellables)
    }

    private static func calculateTimeAgo(targetDate: Date) -> TimeInterval {
        return -targetDate.timeIntervalSinceNow
    }
}

public struct UpdatingTimeAgoView<Content: View>: View {

    @ObservedObject var store: UpdatingTimeAgoViewStore

    let formatter: (TimeInterval) -> String
    let label: (String) -> Content

    public init(targetDate: Date,
         updateFrequency: TimeInterval = 5,
         formatter: @escaping (TimeInterval) -> String = { "\($0)" },
         @ViewBuilder label: @escaping (String) -> Content) {
        self.store = UpdatingTimeAgoViewStore(targetDate: targetDate, updateFrequency: updateFrequency)
        self.formatter = formatter
        self.label = label
    }


    public var body: some View {
        label(formatter(store.currentTimeAgo))
    }
}

#if DEBUG
struct UpdatingTimeAgoView_Previews: PreviewProvider {
    static var previews: some View {
        UpdatingTimeAgoView(targetDate: Date().addingTimeInterval(-20), updateFrequency: 1, label: { timeAgoString in
            Text(timeAgoString)
        })
    }
}
#endif
