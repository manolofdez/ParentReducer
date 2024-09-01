import ParentReducer
import ComposableArchitecture

@Reducer
struct ChildReducer {
    struct State {
        var number = 1
    }

    enum Action {
        case updateNumber(Int)
    }

    var body: some ReducerOf<Self> {
        Reduce { _, _ in
            return .none
        }
    }
}

@Reducer
@ParentReducer
struct TheParentReducer {
    struct State {
        var child: ChildReducer.State = .init()

        var child2: ChildReducer.State?
        
        @ParentReducerStateIgnored
        var child3 = ChildReducer.State()

        private(set) var child4 = ChildReducer.State()
        
        private var child5 = ChildReducer.State()
        
        @ParentReducerStateIgnored
        public private(set) var temp = 1

        init() {
            child2 = .init()
        }
    }
    
    enum Action {
        case child(ChildReducer.Action)
        case child2(ChildReducer.Action)
        case child3(ChildReducer.Action)
        case child4(ChildReducer.Action)
        case child5(ChildReducer.Action)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, _ in
            state.child(.updateNumber(1))
        }
    }
}
