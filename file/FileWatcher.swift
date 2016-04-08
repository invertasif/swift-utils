import Foundation

public class FileWatcher {
    let filePaths: [String]
    var hasStarted = false
    var streamRef:FSEventStreamRef?
    public private(set) var lastEventId: FSEventStreamEventId/*<- this needs to be public private or an error will happen when in use*/
    public init(_ paths: [String], _ sinceWhen: FSEventStreamEventId) {
        self.lastEventId = sinceWhen
        self.filePaths = paths
    }
    /**
     *
     */
    private let eventCallback: FSEventStreamCallback = { (stream: ConstFSEventStreamRef, contextInfo: UnsafeMutablePointer<Void>, numEvents: Int, eventPaths: UnsafeMutablePointer<Void>, eventFlags: UnsafePointer<FSEventStreamEventFlags>, eventIds: UnsafePointer<FSEventStreamEventId>) in
        Swift.print("eventCallback()")
        let fileSystemWatcher: FileWatcher = unsafeBitCast(contextInfo, FileWatcher.self)
        let paths = unsafeBitCast(eventPaths, NSArray.self) as! [String]
        for index in 0..<numEvents {
            fileSystemWatcher.handleEvent(eventIds[index], paths[index], eventFlags[index])
        }
        fileSystemWatcher.lastEventId = eventIds[numEvents - 1]
    }
    /**
     * NOTE: I think you need to create a switch to differentiate between eventFlags
     */
    private func handleEvent(eventId: FSEventStreamEventId, _ eventPath: String, _ eventFlags: FSEventStreamEventFlags) {
        Swift.print("\t eventId: \(eventId) - eventFlags:  \(eventFlags) - eventPath:  \(eventPath)")
        switch eventFlags{
        case 128000:
            Swift.print("modified")
        case 67584:
            Swift.print("rename,add,remove")
        case 111872:
            Swift.print("delete")
        default:
            Swift.print("unsupported event: " + "\(eventFlags)")
            break;
        }
    }
    /**
     * Start listening for FSEvents
     */
    public func start() {
        Swift.print("start - has started: " + "\(hasStarted)")
        if(hasStarted){return}/*<--only start if its not already started*/
        var context = FSEventStreamContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = UnsafeMutablePointer<Void>(unsafeAddressOf(self))
        let flags = UInt32(kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents)
        streamRef = FSEventStreamCreate(kCFAllocatorDefault, eventCallback, &context, filePaths, lastEventId, 0, flags)
        FSEventStreamScheduleWithRunLoop(streamRef!, CFRunLoopGetMain(), kCFRunLoopDefaultMode)
        FSEventStreamStart(streamRef!)
        hasStarted = true
    }
    /**
     * Stop listening for FSEvents
     */
    public func stop() {
        Swift.print("stop - has started: " + "\(hasStarted)")
        if(!hasStarted){return}/*<--only stop if it has been started*/
        FSEventStreamStop(streamRef!)
        FSEventStreamInvalidate(streamRef!)
        FSEventStreamRelease(streamRef!)
        streamRef = nil
        hasStarted = false
    }
    deinit {
        //stop()
    }
}
extension FileWatcher{
    convenience public init(_ pathsToWatch: [String]) {
        self.init(pathsToWatch, FSEventStreamEventId(kFSEventStreamEventIdSinceNow))
    }
}