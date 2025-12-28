import Brute
import SwiftUI

public struct LoadingIndicator: View {
    
    @Environment(\.bruteContext) private var context
    
    public init() {}
    
    public var body: some View {
//        squareCircle
        offsetDotsThree
    }
    
//    @ViewBuilder
//    private var squareCircle: some View {
//        let rectangle = Rectangle().fill(context.color.accentBackground).brutalized()
//        
//        PhaseAnimator(1...8) { value in
//            VStack {
//                HStack {
//                    rectangle
//                        .scaleEffect(value != 1 ? 0.75 : 1)
//                    rectangle
//                        .scaleEffect(value != 2 ? 0.75 : 1)
//                    rectangle
//                        .scaleEffect(value != 3 ? 0.75 : 1)
//                }
//                
//                HStack {
//                    rectangle
//                        .scaleEffect(value != 8 ? 0.75 : 1)
//                    Rectangle().fill(Color.clear)
//                    rectangle
//                        .scaleEffect(value != 4 ? 0.75 : 1)
//                }
//                
//                HStack {
//                    rectangle
//                        .scaleEffect(value != 7 ? 0.75 : 1)
//                    rectangle
//                        .scaleEffect(value != 6 ? 0.75 : 1)
//                    rectangle
//                        .scaleEffect(value != 5 ? 0.75 : 1)
//                }
//            }
//            .aspectRatio(1, contentMode: .fit)
//        }
//        .frame(maxWidth: 100)
//    }
    
    private var offsetDotsThree: some View {
        PhaseAnimator([1, 2, 3, 4, 3, 2, 1, 4]) { value in
            HStack {
                Rectangle()
                    .fill(context.color.accentBackground)
                    .frame(width: 30, height: 30)
                    .brutalized()
                    .offset(y: value == 1 ? -10 : 0)
                Rectangle()
                    .fill(context.color.accentBackground)
                    .frame(width: 30, height: 30)
                    .brutalized()
                    .offset(y: value == 2 ? -10 : 0)
                Rectangle()
                    .fill(context.color.accentBackground)
                    .frame(width: 30, height: 30)
                    .brutalized()
                    .offset(y: value == 3 ? -10 : 0)
            }
        } animation: { value in
                .easeInOut(duration: 0.25)
        }
    }
}

#Preview {
    BruteStyle {
        LoadingIndicator()
            .padding()
    }
}
