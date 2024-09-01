// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroTesting

#if canImport(ParentReducerImplementation)
import ParentReducerImplementation
#endif

final class ParentReducerTests: XCTestCase {
    
    override func invokeTest() {
        withMacroTesting(macros: [
            ParentReducerMacro.self,
            ParentReducerStateMacro.self,
            ParentReducerStateIgnoredMacro.self
        ]) {
            super.invokeTest()
        }
    }
    
    // MARK: Declaration
    
    func testMacro_whenChildDeclaredWithType_addsMember() throws {
        assertMacro {
            """
            @ParentReducer
            struct TestReducer {
                struct State {
                    var child: ChildReducer.State = .init()
                }
            }
            """
        } expansion: {
            """
            struct TestReducer {
                struct State {
                    var child: ChildReducer.State = .init()
            
                    mutating func child(
                        _ action: ChildReducer.Action
                    ) -> EffectOf<TestReducer> {
                        ChildReducer()
                            .reduce(into: &self.child, action: action)
                            .map(TestReducer.Action.child)
                    }
                }
            }
            """
        }
    }
        
    func testMacro_whenChildDeclaredWithInitializer_addsMember() throws {
        assertMacro {
            """
            @ParentReducer
            struct TestReducer {
                struct State {
                    var child = ChildReducer.State()
                }
            }
            """
        } expansion: {
            """
            struct TestReducer {
                struct State {
                    var child = ChildReducer.State()

                    mutating func child(
                        _ action: ChildReducer.Action
                    ) -> EffectOf<TestReducer> {
                        ChildReducer()
                            .reduce(into: &self.child, action: action)
                            .map(TestReducer.Action.child)
                    }
                }
            }
            """
        }
    }
    
    func testMacro_whenChildDeclaredWithTypeAndInitializer_addsMember() throws {
        assertMacro {
            """
            @ParentReducer
            struct TestReducer {
                struct State {
                    var child: ChildReducer.State = ChildReducer.State()
                }
            }
            """
        } expansion: {
            """
            struct TestReducer {
                struct State {
                    var child: ChildReducer.State = ChildReducer.State()

                    mutating func child(
                        _ action: ChildReducer.Action
                    ) -> EffectOf<TestReducer> {
                        ChildReducer()
                            .reduce(into: &self.child, action: action)
                            .map(TestReducer.Action.child)
                    }
                }
            }
            """
        }
    }
    
    // MARK: Optional
    
    func testMacro_whenOptionalChildDeclaredWithType_addsMember() throws {
        assertMacro {
            """
            @ParentReducer
            struct TestReducer {
                struct State {
                    var child: ChildReducer.State? = .init()
                }
            }
            """
        } expansion: {
            """
            struct TestReducer {
                struct State {
                    var child: ChildReducer.State? = .init()

                    mutating func child(
                        _ action: ChildReducer.Action
                    ) -> EffectOf<TestReducer> {
                        guard var childState = self.child else {
                            return .none
                        }
                        let effect = ChildReducer()
                            .reduce(into: &childState, action: action)
                            .map(TestReducer.Action.child)
                        self.child = childState
                        return effect
                    }
                }
            }
            """
        }
    }
    
    func testMacro_whenOptionalChildDeclaredWithTypeAndInitializer_addsMember() throws {
        assertMacro {
            """
            @ParentReducer
            struct TestReducer {
                struct State {
                    var child: ChildReducer.State? = ChildReducer.State()
                }
            }
            """
        } expansion: {
            """
            struct TestReducer {
                struct State {
                    var child: ChildReducer.State? = ChildReducer.State()

                    mutating func child(
                        _ action: ChildReducer.Action
                    ) -> EffectOf<TestReducer> {
                        guard var childState = self.child else {
                            return .none
                        }
                        let effect = ChildReducer()
                            .reduce(into: &childState, action: action)
                            .map(TestReducer.Action.child)
                        self.child = childState
                        return effect
                    }
                }
            }
            """
        }
    }
}
