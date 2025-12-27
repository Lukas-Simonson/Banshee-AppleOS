import Brute
import SwiftUI

struct SeekSlider: View {
    
    @Environment(\.bruteContext) private var context
    
    @Binding var value: Int
    let range: ClosedRange<Int>
    
    @State private var dragValue: Double
    @GestureState private var isDragging: Bool = false
    
    let thumbSize: CGFloat = 25
    let trackSize: CGFloat = 15
    
    init(value: Binding<Int>, in range: ClosedRange<Int> = 0...100) {
        self._value = value
        self.range = range
        self._dragValue = State(initialValue: Double(value.wrappedValue))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                track
                activeTrack(width: max(0, geometry.size.width))
                // thumb(width: geometry.size.width)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($isDragging) { _, state, _ in
                        state = true
                    }
                    .onChanged { gesture in
                        updateDragValue(
                            location: gesture.location.x,
                            width: geometry.size.width
                        )
                    }
                    .onEnded { _ in
                        // Only update the binding when drag ends, converting to Int
                        value = Int(dragValue.rounded())
                    }
            )
        }
        .frame(height: context.dimen.paddingMedium)
        .onChange(of: value) { newValue in
            // Update dragValue when binding changes externally
            if !isDragging {
                dragValue = Double(newValue)
            }
        }
    }
    
    // MARK: - Computed Properties for Components
    
    private var track: some View {
        RoundedRectangle(cornerRadius: context.dimen.cornerRadius)
            .fill(context.color.background)
            .stroke(context.color.border, lineWidth: context.dimen.borderWidth)
            .padding(.horizontal, thumbSize / 2)
            .frame(height: trackSize)
    }
    
    private func activeTrack(width: CGFloat) -> some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: context.dimen.cornerRadius)
                .fill(context.color.accentBackground)
                .stroke(context.color.border, lineWidth: context.dimen.borderWidth)
                .frame(width: activeTrackWidth(totalWidth: width))
            Spacer(minLength: 0)
        }
        .padding(.horizontal, thumbSize / 2)
        .frame(height: trackSize)
    }
    
    private func thumb(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: context.dimen.cornerRadius)
            .fill(context.color.neutralBackground)
            .frame(width: thumbSize, height: thumbSize)
            .bruteStroked()
            .offset(x: thumbOffset(totalWidth: width))
            
    }
    
    // MARK: - Helper Methods
    
    private func normalizedValue() -> Double {
        let lowerBound = Double(range.lowerBound)
        let upperBound = Double(range.upperBound)
        let normalized = (dragValue - lowerBound) / (upperBound - lowerBound)
        return min(max(normalized, 0), 1)
    }
    
    private func thumbOffset(totalWidth: CGFloat) -> CGFloat {
        let usableWidth = totalWidth - thumbSize
        return usableWidth * normalizedValue()
    }
    
    private func activeTrackWidth(totalWidth: CGFloat) -> CGFloat {
        let usableWidth = totalWidth - thumbSize
        return usableWidth * normalizedValue()
    }
    
    private func updateDragValue(location: CGFloat, width: CGFloat) {
        let usableWidth = width - thumbSize
        let normalizedLocation = (location - thumbSize / 2) / usableWidth
        let clampedNormalized = min(max(normalizedLocation, 0), 1)
        
        let lowerBound = Double(range.lowerBound)
        let upperBound = Double(range.upperBound)
        dragValue = lowerBound + (clampedNormalized * (upperBound - lowerBound))
    }
}

#Preview {
    @Previewable @State var value = 10
    
    VStack {
        Text(value, format: .number)
        
        SeekSlider(
            value: $value,
            in: 0...10
        )
    }
}
