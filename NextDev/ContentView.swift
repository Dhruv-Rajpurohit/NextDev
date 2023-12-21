//
//  ContentView.swift
//  NextDev
//
//  Created by Dhruv Rajpurohit on 12/12/23.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    var body: some View {
        Home()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Home: View {
    @State private var start = false
    @State private var count = 0
    @State private var milliseconds = 0
    @State private var startTime: Date?
    @State private var to: CGFloat = 0

    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    // Outer Circle
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke(lineWidth: 5)
                        .frame(width: 200, height: 200)

                    // Inner Circle for showing timer bar - every millisecond
                    Circle()
                        .trim(from: 0, to: self.to)
                        .stroke(Color.red, style: StrokeStyle(lineWidth: 15))
                        .frame(width: 200, height: 200)
                        .rotationEffect(.init(degrees: 90))

                    VStack {
                        if count == 60 {
                            Text("Time up")
                                .font(.system(size: 30))
                                .onTapGesture {
                                    // Reset all values when tapped
                                    self.count = 0
                                    self.milliseconds = 0
                                    self.to = 0
                                    self.startTime = nil
                                    self.start = false
                                }
                        } else {
                            Text(String(format: "%02d:%02d:%02d", count / 60, count % 60, milliseconds / 10))
                                .font(.system(size: 30))
                        }
                    }
                }
                // Buttons for handling timer
                VStack(spacing: 20) {
                    Button(action: {
                        if self.count == 60 {
                            self.count = 0
                            self.milliseconds = 0
                            withAnimation(.easeIn) {
                                self.to = 0
                            }
                        }
                        self.start.toggle()
                        self.startTime = Date() // Set start time when the button is pressed
                    }) {
                        HStack(spacing: 20) {
                            Text(self.start ? "PAUSE" : "TURN-On")
                                .foregroundColor(.green)
                        }
                        .padding(.vertical)
                        .frame(width: 100)
                    }
                    Button(action: {
                        // Reset values on restart
                        self.count = 0
                        self.milliseconds = 0
                        withAnimation(.easeIn) {
                            self.to = 0
                        }
                        self.start = false
                        self.startTime = nil
                    }) {
                        HStack(spacing: 15) {
                            Text("RESTART")
                                .foregroundColor(.red)
                        }
                        .frame(width: 100)
                    }
                }
            }
        }
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { (_, _) in }
        }
        .onReceive(Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()) { _ in
            if self.start {
                let currentTime = Date()
                let elapsedTime = currentTime.timeIntervalSince(self.startTime ?? currentTime)

                self.milliseconds += Int(elapsedTime * 100)
                self.count += self.milliseconds / 100
                self.milliseconds %= 100

                withAnimation(.default) {
                    self.to = CGFloat(self.count) / 60
                }

                self.startTime = currentTime

                if self.count == 60 {
                    self.start.toggle()
                    self.setupNotification()
                }
            }
        }
    }

    // Notifications Setup for banner
    func setupNotification() {
        let nObj = UNMutableNotificationContent()
        nObj.body = "Workout Complete"
        nObj.title = "NextDev-Sports"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(identifier: "Nextdev", content: nObj, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
