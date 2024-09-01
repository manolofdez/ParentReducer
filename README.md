# ParentReducer
A [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) companion macro that aims to reduce boilerplate code by allowing you to mutate a (child) Reducer's state using actions, directly on the parent's state.

## Motivation
With TCA you have a few ways of updating the state of another reducer. For example, you can: 

A. Manipulate the state directly:
<div>`state.child.theirVariable = "foo"`</div>

B. Recreate the child's state:
<div>`state.child = ChildReducer.State(theirVariable: "foo")`</div>

c) Reduce the state: 

	ChildReducer()
      .reduce(into: &state.childState, action: .theirValue("foo"))
      .map { .child($0) }

etc...

I've gravitated towards option C, the most verbose, because it helps me make the mental model that "only a Reducer knows how to mutate its state". This helps me draw a boundary around how these elements are expected to interact. BUT, as I alluded to before, this is VERY verbose.

The `ParentReducer` macro hopes to alleviate the verbosity of reducing a child reducer's state by allowing you to mutate the child directly from the parent's state, using the child reducer's actions.

## Usage

Everything works automagically, provided you follow the following:

1. Add the `ParentReducer` annotation to your reducer.
2. Name your child reducer with a `Reducer` suffix.
3. Name the parent reducer's action corresponding to the child with the same name as the child.

That's it!

```swift
@Reducer
@ParentReducer
struct TheParentReducer {
    struct State {
        var child: ChildReducer.State = .init()
    }
    
    enum Action {
        case child(ChildReducer.Action)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, _ in
            state.child(.updateValue(1))
        }
    }
}
```

Note how `state.child(.updateValue(1))` will not only mutate your `child` using the child's action, but also will return the correcit parent effect!

### Ignoring state

But what if I don't want a particular state to participate in this madness!? Don't sweat, we got a this other handy dandy macro you can use - `@ParentReducerStateIgnored`:

```swift
@Reducer
@ParentReducer
struct TheParentReducer {
    struct State {
        @ParentReducerStateIgnored
        var child: ChildReducer.State = .init()
    }
    ...    
}
```

## Future

This was written without too much thought, as a way to explore Macros and new ways of interacting with TCA. If this ends up being useful/practical, we'll likely want to relax some of the rules you have to follow in order to make the magic work. Particularly the one about having to "Name your child reducer with a `Reducer` suffix".

## Installation

### Swift Package Manager

This library can be installed using the Swift Package Manager by adding it to your Package Dependencies.

## Requirements

- iOS 16.0+
- MacOS 13.0+
- Swift 5
- Xcoce 15.4+

## License

Licensed under MIT license.
