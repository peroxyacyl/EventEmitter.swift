# EventEmitter.swift
A clone of EventEmitter on Node.js v0.12.0.
Conforms to http://nodejs.org/api/events.html

## Notes
* Listener callback is not variadic but receives an array [Any] due to the swift language specification.
* EventEmitter#removeListener is not implemented because closures on Swift are not comparable. See https://devforums.apple.com/message/1035180#1035180
