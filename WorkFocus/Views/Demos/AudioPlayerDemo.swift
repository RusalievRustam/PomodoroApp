//
//  SwiftUIView.swift
//  WorkFocus
//
//  Created by Rustam Rusaliev on 19/12/24.
//

import SwiftUI

struct AudioPlayerDemo: View {
    var audioPlayer = WorkFocusAudio()
    
    var body: some View {
        VStack{
            Button ("play done"){
                audioPlayer.play(.done)
            }
            }
        }
    }

#Preview {
    AudioPlayerDemo()
}
