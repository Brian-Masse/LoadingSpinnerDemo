//
//  ContentView.swift
//  LoadingSpinnerDemo
//
//  Created by Brian Masse on 7/9/24.
//

import SwiftUI

//MARK: StyledSpinner
private struct StyledSpinner: View{
    
    private class StyledSpinnerViewModel: ObservableObject {
        static let shared = StyledSpinnerViewModel()
        
        @Published var shouldAnimate: Bool = false
        var animating: Bool = false
        
        var animatingMask: Int = 0
        
        func animate(mask: Int = -1) {
            self.animatingMask = mask
            
            if !animating {
                shouldAnimate.toggle()
                animating = true
            }
        }
        
        func checkSpinnerInMask( _ mask: Int ) -> Bool {
            self.animatingMask == mask || self.animatingMask == -1
        }
    }
    
    @ObservedObject private var viewModel: StyledSpinnerViewModel = StyledSpinnerViewModel.shared
    
//    MARK: StyledSpinner Vars
    let primaryColor: Color
    let secondaryColor: Color
    
    let duration: Double
    
    let clockwise: Bool
    let startingAngle: Double
    
    let animatingMask: Int
    let delay: Double
    
    init( _ primaryColor: Color, _ secondaryColor: Color,
          for duration: Double = 3,
          at startingAngle: Double = 90,
          clockwise: Bool = true,
          delay: Double = 0,
          animatingMask: Int = 0) {
        
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.duration = duration
        self.startingAngle = startingAngle
        self.clockwise = clockwise
        self.animatingMask = animatingMask
        self.delay = delay
    }
    
    @State private var angle: Double = 0
    
//    MARK: StyledSpinner Methods
    static func animateAll() {
        StyledSpinnerViewModel.shared.animate()
    }
    
    static func animate( _ mask: Int ) {
        StyledSpinnerViewModel.shared.animate(mask: mask)
    }
    
    
//    MARK: StyledSpinner Body
    var body: some View {
        
        AngularGradient(colors: [primaryColor, secondaryColor],
                        center: .center,
                        angle: .init(degrees: angle))
        
        .aspectRatio(1, contentMode: .fit)
        .clipShape(Circle())
        
        .onAppear { self.angle = startingAngle }
        .onChange(of: viewModel.shouldAnimate ) {
            if !viewModel.checkSpinnerInMask(self.animatingMask) { return }
            
            self.angle = startingAngle
            
            withAnimation(.spring(duration: duration).delay(delay)  ) {
                self.angle = startingAngle + (clockwise ? 360 : -360)
            } completion: {
                viewModel.animating = false
            }
        }
        
    }
}


//MARK: ContentView
struct ContentView: View {

    @State private var colors: [Color] = [.blue, .purple]
    
    @ViewBuilder
    private func makeButton( icon: String, title: String, action: @escaping () -> Void ) -> some View {
        HStack {
            Image(systemName: icon)
            Text( title )
        }
        .padding(.horizontal)
        .opacity(0.8)
        .onTapGesture { withAnimation { action() } }
    }
    
    private func makeRandomColor() -> Color{
        Color(red: Double.random(in: 0...1), 
              green: Double.random(in: 0...1),
              blue: Double.random(in: 0...1))
    }
    
    private func randomizeColors() {
        let color1 = makeRandomColor()
        let color2 = makeRandomColor()
        let arr = [color1, color2]
        self.colors = arr
    }
    
    var body: some View {
        
        Text("Loading Spinner Demo")
            .font(.title3)
            .bold()
            .padding(.bottom)
        
        HStack {
            Spacer()
            
            makeButton(icon: "play", title: "Animate") { StyledSpinner.animateAll() }
            
            makeButton(icon: "circle.hexagongrid", title: "Shuffle Colors") { randomizeColors() }
            
            Spacer()
        }
        
        VStack {
            StyledSpinner(colors[0], colors[1], for: 2, at: 90, clockwise: false)
            
            StyledSpinner(colors[1], colors[0], for: 2, at: -90, clockwise: false)
        }
        .padding(.vertical)
    }
}

#Preview {
    ContentView()
}
