//
//  EventEmitter.swift
//
//  Created by Seki Inoue on 2/16/15.
//  Copyright (c) 2015 Mist Technologies, Inc. All rights reserved.
//

/**
A clone of EventEmitter on Node.js v0.12.0.
Conforms to http://nodejs.org/api/events.html


Listener callback is not variadic but receives an array [Any] due to swift language specification.
EventEmitter#removeListener is not implemented because closure on Swift is not comparable. See https://devforums.apple.com/message/1035180#1035180
@class EventEmitter
*/

import Foundation

class EventEmitter : NSObject {
    let eventExceedMaxListener = "kEventExceedMaxListener";
    let eventNewListener = "kEventNewListener";
    let eventRemoveListener = "kEventRemoveListener";
    
    
    private var _listeners : Dictionary<String, [(once:Bool, listener:(args: [Any]) -> Void)]> = [:];
    
    //class var _defaultMaxListeners = 0;
    //Class variables not yet supported. Hacky code here.
    private struct ClassProperty {
        static var defaultMaxListeners = 10;
    }
    
    var _maxListeners:Int = ClassProperty.defaultMaxListeners;
    
    override init() {
        super.init();
        self.once(eventExceedMaxListener) { count in
            println("warning: possible EventEmitter memory leak detected. \(count[0]) listeners added. Use emitter.setMaxListeners() to increase limit.");
        }
    }
    
    func addListener(event: String, listener: (args: [Any]) -> Void)-> EventEmitter {
        return on(event, listener: listener);
    }
    
    func on(event: String, listener:(args: [Any]) -> Void)-> EventEmitter {
        var eventListeners = _listeners[event] ?? [];
        eventListeners.append(once: false, listener:listener);
        _listeners.updateValue(eventListeners, forKey: event);
        
        emit(eventNewListener, args: event, listener);
        if (_maxListeners > 0 && eventListeners.count > _maxListeners) {
            emit(eventExceedMaxListener, args: [eventListeners.count]);
        }
        return self;
    }
    
    func once(event: String, listener:(args: [Any]) -> Void)-> EventEmitter {
        var eventListeners = _listeners[event] ?? [];
        eventListeners.append(once: true, listener:listener);
        _listeners.updateValue(eventListeners, forKey: event);
        return self;
    }
    
    @availability(*, unavailable, message="EventEmitter#removeListener is not implemented due to swift language specification. See https://devforums.apple.com/message/1035180#1035180")
    func removeListener(event: String, listener:(args: [Any]) -> Void) -> EventEmitter {
        return self;
    }
    
    func removeAllListeners(event: String?) -> EventEmitter {
        if event == nil {
            for (ev:String, ts:[(once:Bool, listener:(args: [Any]) -> Void)]) in _listeners {
                for t in ts {
                    emit(eventRemoveListener, args: ev, t.listener);
                }
            }
            _listeners.removeAll(keepCapacity: false);
        }else {
            _listeners.removeValueForKey(event!);
        }
        return self;
    }
    
    func setMaxListeners(n:Int) {
        _maxListeners = n;
    }
    
    class func defaultMaxListeners(n:Int) {
        ClassProperty.defaultMaxListeners = n;
    }
    
    func listeners(event: String) -> [(args: [Any]) -> Void] {
        let ts = _listeners[event] ?? [];
        return ts.map({ (t) -> (args: [Any]) -> Void in
            return t.listener;
        });
    }
    
    func emit(event:String, args: Any...) -> Bool {
        if var ts = _listeners[event] {
            var toBeDeleted:[Int] = [];
            for (idx, t) in enumerate(ts) {
                t.listener(args: args);
                if t.once {
                    toBeDeleted.append(idx);
                }
            }
            for idx in toBeDeleted {
                ts.removeAtIndex(idx);
            }
            _listeners.updateValue(ts, forKey: event);
            return true;
        }
        return false;
    }
    
    class func listenerCount(emitter: EventEmitter, event:String) -> Int {
        return emitter._listeners[event]?.count ?? 0;
    }
}
