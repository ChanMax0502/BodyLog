import Foundation

public struct BudxWrapper<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol BudxCompatible {}

extension BudxCompatible {
    public var bud: BudxWrapper<Self> { BudxWrapper(self) }
    public static var bud: BudxWrapper<Self>.Type { BudxWrapper<Self>.self }
}
