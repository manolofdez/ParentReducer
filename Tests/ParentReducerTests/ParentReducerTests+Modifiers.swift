// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroTesting


extension ParentReducerTests {
    func testMacro_whenChildDeclaredWithPrivateModifier_addsMemberWithPrivateModifier() throws {
        assertMacro {
            """
            @ParentReducer
            struct TestReducer {
                struct State {
                    private var child = ChildReducer.State()
                }
            }
            """
        } expansion: {
            """
            struct TestReducer {
                struct State {
                    private var child = ChildReducer.State()

                    private mutating func child(
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
    
    
    func testMacro_whenChildDeclaredWithPublicModifier_addsMemberWithPublicModifier() throws {
        assertMacro {
            """
            @ParentReducer
            struct TestReducer {
                struct State {
                    public var child = ChildReducer.State()
                }
            }
            """
        } expansion: {
            """
            struct TestReducer {
                struct State {
                    public var child = ChildReducer.State()
            
                    public mutating func child(
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
    
    func testMacro_whenChildDeclaredWithPrivateSetModifier_addsMemberWithoutPrivateModifier() throws {
        assertMacro {
            """
            @ParentReducer
            struct TestReducer {
                struct State {
                    private(set) var child = ChildReducer.State()
                }
            }
            """
        } expansion: {
            """
            struct TestReducer {
                struct State {
                    private(set) var child = ChildReducer.State()

                    private mutating func child(
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
        
    func testMacro_whenChildDeclaredWithPrivateSetPublicModifier_addsMemberWithPrivateModifier() throws {
        assertMacro {
            """
            @ParentReducer
            struct TestReducer {
                struct State {
                    private(set) public var child = ChildReducer.State()
                }
            }
            """
        } expansion: {
            """
            struct TestReducer {
                struct State {
                    private(set) public var child = ChildReducer.State()
            
                    private mutating func child(
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
    
    func testMacro_whenChildDeclaredWithPublicPrivateSetModifier_addsMemberWithPrivateModifier() throws {
        assertMacro {
            """
            @ParentReducer
            struct TestReducer {
                struct State {
                    public private(set) var child = ChildReducer.State()
                }
            }
            """
        } expansion: {
            """
            struct TestReducer {
                struct State {
                    public private(set) var child = ChildReducer.State()

                    private mutating func child(
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

}
