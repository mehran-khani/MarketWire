import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {}

    enum Action: Equatable {
        case appStarted
    }

    var body: some Reducer<State, Action> {
        Reduce { _, _ in
            .none
        }
    }
}
