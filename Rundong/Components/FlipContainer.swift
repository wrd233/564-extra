import SwiftUI

struct FlipContainer<Front: View, Back: View>: View {
    let front: Front
    let back: Back
    @State private var flipped = false
    
    var body: some View {
        ZStack {
            front
                .rotation3DEffect(
                    .degrees(flipped ? 180 : 0),
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
                .opacity(flipped ? 0 : 1)
            
            back
                .rotation3DEffect(
                    .degrees(flipped ? 0 : -180),
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
                .opacity(flipped ? 1 : 0)
        }
        .animation(.easeInOut(duration: 0.35), value: flipped)
        .onTapGesture {
            flipped.toggle()
        }
    }
}
