//
//  main.swift
//  EventEmitter-Swift
//
//  Created by Seki Inoue on 2/16/15.
//  Copyright (c) 2015 Mist Technologies, Inc. All rights reserved.
//

import Foundation

let emitter = EventEmitter();
emitter.on("MessageEvent") { message in
    println("Listen MessageEvent : \(message)");
}
emitter.once("MessageEvent") { message in
    println("Listen MessageEvent Once : \(message)");
}
emitter.on("MessageEvent") { message in
    println("Listen MessageEvent2 : \(message)");
}
emitter.emit("MessageEvent", args: "message1", "message2");
emitter.emit("MessageEvent", args: "message3", "message4");

for i in 0...100 {
    emitter.addListener("ManyListenersEvent") { args in
        println("Listen ManyListenersEvent\(i)");
    }
}

emitter.emit("ManyListenersEvent");

emitter.removeAllListeners("ManyListenersEvent");

emitter.emit("ManyListenersEvent");
emitter.emit("MessageEvent", args: "message5", 6);