//
//  Main.swift
//  Game_Janag
//
//  Created by Evan Perry on 2/28/24.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    @State private var NumBlocksFall: Int = 0
    @State private var NumBlocksTapped: Int = 0
    @State private var Score: Int = 0
    var body: some View {
            if (NumBlocksTapped - NumBlocksFall > -1) {
                ZStack{
                    GameView(updateNumBlocksFall: { self.NumBlocksFall = $0 }, updateNumBlocksTapped: { self.NumBlocksTapped = $0 })
                        .ignoresSafeArea(.all)
                    VStack {
                        ProgressView(value: 1 - Float(NumBlocksFall) / 45)
                            .padding()
                            .frame(height: 35)
                        Text("\(Int(45 - Float(NumBlocksFall) ))")
                            .frame(maxHeight: .infinity, alignment: .top)
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .padding()
                        
                    }
                }
            } else {
                ZStack{
                    LinearGradient(gradient: Gradient(colors: [Color.red, Color.black]), startPoint: .center, endPoint: .top)
                        .ignoresSafeArea()
                    VStack {
                        Text("GAME OVER")
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                        
                        Button(action: {
                            NumBlocksTapped = 0
                            NumBlocksFall = 0
                             }) {
                                 Text("Restart")
                                      .font(.largeTitle)
                                      .fontWeight(.heavy)
                                   .foregroundColor(.white)
                                 
                             }
                             .padding(10)
                    }
                }
            }
        }
            
        }



#Preview {
    ContentView()
}
