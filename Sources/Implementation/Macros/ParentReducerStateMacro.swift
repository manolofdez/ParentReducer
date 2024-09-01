// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import SwiftDiagnostics
import SwiftOperators
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

public enum ParentReducerStateMacro {}

extension ParentReducerStateMacro: MemberMacro {
    public static func expansion<D: DeclGroupSyntax, C: MacroExpansionContext>(
        of node: AttributeSyntax,
        providingMembersOf declaration: D,
        in context: C
    ) throws -> [DeclSyntax] {
        guard let parentReducerTypeName = {
            guard let arguments = node.arguments?.as(LabeledExprListSyntax.self),
                  let argument = arguments.first(where: { $0.label?.text == "of" }),
                  let expression = argument.expression.as(DeclReferenceExprSyntax.self) else {
                return String?.none
            }
            return expression.baseName.text
        }() else {
            return []
        }

        var output: [DeclSyntax] = []
        declaration
            .as(StructDeclSyntax.self)?
            .memberBlock
            .as(MemberBlockSyntax.self)?
            .members
            .forEach { member in
                guard let variableDeclaration = member
                      .as(MemberBlockItemSyntax.self)?
                      .decl
                      .as(VariableDeclSyntax.self),
                      !isIgnored(variableDeclaration: variableDeclaration),
                      variableDeclaration.bindingSpecifier.text == "var",
                      let variableBinding = variableDeclaration.bindings.first?.as(PatternBindingSyntax.self),
                      let childReducerTypeName = reducer(variableBinding: variableBinding)
                else {
                    return
                }
                
                let modifier = modifier(variableDeclaration: variableDeclaration)
                let variableName = variableBinding.pattern.trimmedDescription
                let isOptional = isOptional(variableBinding: variableBinding)
                let memberOutput = isOptional
                    ? newOptionalMemberDeclaration(
                        modifier: modifier,
                        variable: variableName,
                        childReducer: childReducerTypeName,
                        parentReducer: parentReducerTypeName
                    )
                    : newMemberDeclaration(
                        modifier: modifier,
                        variable: variableName,
                        childReducer: childReducerTypeName,
                        parentReducer: parentReducerTypeName
                    )
                
                output.append(memberOutput)
            }
        
        return output
    }
    
    private static func newMemberDeclaration(
        modifier: String,
        variable: String,
        childReducer: String,
        parentReducer: String
    ) -> DeclSyntax {
        let modifier = modifier.isEmpty ? "" : (modifier + " ")
        return """
        \(raw: modifier)mutating func \(raw: variable)(
            _ action: \(raw: childReducer).Action
        ) -> EffectOf<\(raw: parentReducer)> {
            \(raw: childReducer)()
                .reduce(into: &self.\(raw: variable), action: action)
                .map(\(raw: parentReducer).Action.\(raw: variable))
        }
        """
    }
    
    private static func newOptionalMemberDeclaration(
        modifier: String,
        variable: String,
        childReducer: String,
        parentReducer: String
    ) -> DeclSyntax {
        let modifier = modifier.isEmpty ? "" : (modifier + " ")
        return """
        \(raw: modifier)mutating func \(raw: variable)(
            _ action: \(raw: childReducer).Action
        ) -> EffectOf<\(raw: parentReducer)> {
            guard var childState = self.\(raw: variable) else {
                return .none
            }
            let effect = \(raw: childReducer)()
                .reduce(into: &childState, action: action)
                .map(\(raw: parentReducer).Action.\(raw: variable))
            self.\(raw: variable) = childState
            return effect
        }
        """
    }
    
    private static func reducer(variableBinding: PatternBindingSyntax) -> String? {
        reducerFromTypeAnnotation(variableBinding: variableBinding)
        ?? reducerFromOptionalTypeAnnotation(variableBinding: variableBinding)
        ?? reducerFromInitializer(variableBinding: variableBinding)
    }
    
    private static func reducerFromTypeAnnotation(variableBinding: PatternBindingSyntax) -> String? {
        guard let type = variableBinding.typeAnnotation?.type.as(MemberTypeSyntax.self) else {
            return nil
        }
        let reducerTypeName = type.baseType.trimmedDescription
        guard reducerTypeName.hasSuffix("Reducer"), type.name.trimmedDescription == "State" else {
            return nil
        }
        return reducerTypeName
    }
    
    private static func reducerFromOptionalTypeAnnotation(variableBinding: PatternBindingSyntax) -> String? {
        guard let optionalType = variableBinding.typeAnnotation?.type.as(OptionalTypeSyntax.self),
              let type = optionalType.wrappedType.as(MemberTypeSyntax.self) else {
            return nil
        }
        let reducerTypeName = type.baseType.trimmedDescription
        guard reducerTypeName.hasSuffix("Reducer"), type.name.trimmedDescription == "State" else {
            return nil
        }
        return reducerTypeName
    }
    
    private static func reducerFromInitializer(variableBinding: PatternBindingSyntax) -> String? {
        guard let initializer = variableBinding.initializer,
              let functionCall = initializer.value.as(FunctionCallExprSyntax.self),
              let callExpression = functionCall.calledExpression.as(MemberAccessExprSyntax.self),
              let reducerTypeName = callExpression.base?.trimmedDescription,
              reducerTypeName.hasSuffix("Reducer"),
              callExpression.declName.baseName.trimmedDescription == "State" else {
            return nil
        }
        return reducerTypeName
    }
    
    private static func isIgnored(variableDeclaration: VariableDeclSyntax) -> Bool {
        return variableDeclaration.attributes.firstMapped {
            guard let attribute = $0.as(AttributeSyntax.self),
                  attribute.attributeName.trimmedDescription == "ParentReducerStateIgnored" else {
                return nil
            }
            return true
        } == true
    }
    
    private static func isOptional(variableBinding: PatternBindingSyntax) -> Bool {
        variableBinding.typeAnnotation?.type.as(OptionalTypeSyntax.self) != nil
    }
    
    private static func modifier(variableDeclaration: VariableDeclSyntax) -> String {
        guard let setModifier = variableDeclaration.modifiers.first(where: {
            $0.detail?.detail.trimmedDescription == "set"
        }) else {
            return variableDeclaration.modifiers.first?.name.trimmedDescription ?? ""
        }
        return setModifier.name.trimmedDescription
    }
}
