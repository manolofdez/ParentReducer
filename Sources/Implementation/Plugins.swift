// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ParentReducerPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ParentReducerMacro.self,
        ParentReducerStateMacro.self,
        ParentReducerStateIgnoredMacro.self
    ]
}
