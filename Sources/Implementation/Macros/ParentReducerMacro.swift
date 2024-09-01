// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import SwiftDiagnostics
import SwiftOperators
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

public enum ParentReducerMacro {}

extension ParentReducerMacro: MemberAttributeMacro {
    public static func expansion<D: DeclGroupSyntax, M: DeclSyntaxProtocol, C: MacroExpansionContext>(
        of node: AttributeSyntax,
        attachedTo declaration: D,
        providingAttributesFor member: M,
        in context: C
    ) throws -> [AttributeSyntax] {
        guard member.is(StructDeclSyntax.self),
              let reducerTypeName = declaration
                  .as(StructDeclSyntax.self)?
                  .name
                  .text
                  .replacing(".self", with: "")
        else {
            return []
        }
        let attributeName = IdentifierTypeSyntax(name: .identifier("ParentReducerState(of: \(reducerTypeName))"))
        return [AttributeSyntax(attributeName: attributeName)]
    }
}
