import SwiftUI

struct AppBackgroundView<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            Group {
                AppVisualStyle.screenBackground
                AppVisualStyle.ambientGlowTopTrailing
                AppVisualStyle.ambientGlowBottomLeading
            }
            .drawingGroup(opaque: false, colorMode: .linear)
            .ignoresSafeArea()

            content()
        }
    }
}
