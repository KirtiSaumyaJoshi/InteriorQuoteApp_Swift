//
//  ProductConstraintChecker.swift
//  InteriorQuoteApp_Swift
//
//  Created by Kirti Saumya Joshi on 16/5/2026.
//

import Foundation

struct ProductCompatibilityResult {
    let isCompatible: Bool
    let message: String
}

class ProductConstraintChecker {

    static func check(product: Product, widthMM: Double, heightMM: Double) -> ProductCompatibilityResult {

        if let minHeight = product.minHeight, heightMM < minHeight {
            return ProductCompatibilityResult(
                isCompatible: false,
                message: "Height is too small. Minimum height is \(Int(minHeight)) mm."
            )
        }

        if let maxHeight = product.maxHeight, heightMM > maxHeight {
            return ProductCompatibilityResult(
                isCompatible: false,
                message: "Height is too large. Maximum height is \(Int(maxHeight)) mm."
            )
        }

        guard let minWidth = product.minWidth,
              let maxWidth = product.maxWidth else {
            return ProductCompatibilityResult(
                isCompatible: true,
                message: "Compatible"
            )
        }

        let maxPanels = product.maxPanelCount ?? 1

        if minWidth == maxWidth {
            for panelCount in 1...maxPanels {
                let requiredWidth = minWidth * Double(panelCount)

                if widthMM == requiredWidth {
                    return ProductCompatibilityResult(
                        isCompatible: true,
                        message: "Compatible using \(panelCount) panel(s)."
                    )
                }
            }

            return ProductCompatibilityResult(
                isCompatible: false,
                message: "This product only fits exact widths: \(Int(minWidth)) mm increments up to \(maxPanels) panel(s)."
            )
        }

        if widthMM < minWidth {
            return ProductCompatibilityResult(
                isCompatible: false,
                message: "Width is too small. Minimum width is \(Int(minWidth)) mm."
            )
        }

        if widthMM <= maxWidth {
            return ProductCompatibilityResult(
                isCompatible: true,
                message: "Compatible as a single panel."
            )
        }

        if maxPanels <= 1 {
            return ProductCompatibilityResult(
                isCompatible: false,
                message: "Width exceeds \(Int(maxWidth)) mm and this product does not allow panel splitting."
            )
        }

        for panelCount in 2...maxPanels {
            let panelWidth = widthMM / Double(panelCount)

            if panelWidth >= minWidth && panelWidth <= maxWidth {
                return ProductCompatibilityResult(
                    isCompatible: true,
                    message: "Compatible using \(panelCount) panels of about \(Int(panelWidth)) mm each."
                )
            }
        }

        return ProductCompatibilityResult(
            isCompatible: false,
            message: "Cannot split into \(maxPanels) panel(s) while keeping each panel between \(Int(minWidth)) mm and \(Int(maxWidth)) mm."
        )
    }
}
