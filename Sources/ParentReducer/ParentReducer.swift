// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import Foundation
import ComposableArchitecture

@attached(memberAttribute)
public macro ParentReducer() = #externalMacro(
    module: "ParentReducerImplementation",
    type: "ParentReducerMacro"
)

@attached(member, names: arbitrary)
public macro ParentReducerState(of reducer: any Reducer.Type) = #externalMacro(
    module: "ParentReducerImplementation",
    type: "ParentReducerStateMacro"
)

@attached(accessor, names: named(willSet))
public macro ParentReducerStateIgnored() = #externalMacro(
    module: "ParentReducerImplementation",
    type: "ParentReducerStateIgnoredMacro"
)
