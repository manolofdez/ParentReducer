// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import Foundation

extension Collection {
    
    func firstMapped<T>(where mapBlock: (Element) -> T?) -> T? {
        for element in self {
            guard let mappedElement = mapBlock(element) else { continue }
            return mappedElement
        }
        return nil
    }
}
