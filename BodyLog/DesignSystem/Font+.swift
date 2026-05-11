import SwiftUI

extension Font: BudxCompatible {}

extension BudxWrapper where Base == Font {
    private static func custom(
        name: String,
        size: CGFloat,
        weight: Font.Weight = .regular
    ) -> Font {
        Font.custom(name, size: size).weight(weight)
    }

    public static func courierPrime(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let postScriptName: String = {
            switch weight {
            case .semibold, .bold, .heavy, .black:
                return "CourierPrime-Bold"
            default:
                return "CourierPrime-Regular"
            }
        }()
        return Font.custom(postScriptName, size: size).weight(weight)
    }

    public static func regular(size: CGFloat) -> Font {
        .bud.courierPrime(size: size)
    }
    public static func medium(size: CGFloat) -> Font {
        .bud.courierPrime(size: size, weight: .medium)
    }
    public static func semibold(size: CGFloat) -> Font {
        .bud.courierPrime(size: size, weight: .semibold)
    }
    public static func bold(size: CGFloat) -> Font {
        .bud.courierPrime(size: size, weight: .bold)
    }
    public static func heavy(size: CGFloat) -> Font {
        .bud.courierPrime(size: size, weight: .heavy)
    }
    public static func black(size: CGFloat) -> Font {
        .bud.courierPrime(size: size, weight: .black)
    }
}
