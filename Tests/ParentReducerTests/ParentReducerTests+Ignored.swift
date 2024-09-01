// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroTesting


extension ParentReducerTests {
    func testMacro_whenChildIgnored_skipsMember() throws {
        assertMacro {
            """
            @ParentReducer
            struct TestReducer {
                struct State {
                    @ParentReducerStateIgnored
                    private var child = ChildReducer.State()
                }
            }
            """
        } expansion: {
            """
            struct TestReducer {
                struct State {
                    private var child = ChildReducer.State()
                }
            }
            """
        }
    }
    
    func testMacro_whenChildIgnoredWithAnotherMacroFirst_skipsMember() throws {
        assertMacro {
            """
            @ParentReducer
            struct TestReducer {
                struct State {
                    @AnotherMacro
                    @ParentReducerStateIgnored
                    private var child = ChildReducer.State()
                }
            }
            """
        } expansion: {
            """
            struct TestReducer {
                struct State {
                    @AnotherMacro
                    private var child = ChildReducer.State()
                }
            }
            """
        }
    }
    
    func testMacro_whenChildIgnoredWithAnotherMacroLast_skipsMember() throws {
        assertMacro {
            """
            @ParentReducer
            @AnotherMacro
            struct TestReducer {
                struct State {
                    @ParentReducerStateIgnored
                    @AnotherMacro
                    private var child = ChildReducer.State()
                }
            }
            """
        } expansion: {
            """
            @AnotherMacro
            struct TestReducer {
                struct State {
                    @AnotherMacro
                    private var child = ChildReducer.State()
                }
            }
            """
        }
    }
}
