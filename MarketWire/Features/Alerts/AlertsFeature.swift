import ComposableArchitecture

@Reducer
struct AlertsFeature {
    @ObservableState
    struct State: Equatable {}

    enum Action: Equatable {}

    var body: some Reducer<State, Action> {
        Reduce { _, _ in .none }
    }
}
