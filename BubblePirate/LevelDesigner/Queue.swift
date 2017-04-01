// Copyright (c) 2017 NUS CS3217. All rights reserved.

/**
 An enum of errors that can be thrown from the `Queue` struct.
 */
enum QueueError: Error {
    /// Thrown when trying to access an element from an empty queue.
    case emptyQueue
}


/**
 A generic `Queue` class whose elements are first-in, first-out.
 
 - Authors: CS3217
 - Date: 2017
 */
struct Queue<T> {
    
    private var arr = [T]()
    var numElement : Int = 0
    
    /// Adds an element to the tail of the queue.
    /// - Parameter item: The element to be added to the queue
    mutating func enqueue(_ item: T) {
        arr.append(item)
        numElement += 1
    }
    
    /// Removes an element from the head of the queue and return it.
    /// - Returns: item at the head of the queue
    /// - Throws: QueueError.EmptyQueue
    mutating func dequeue() -> T? {
        guard !arr.isEmpty else{
            return nil
        }
        
        numElement -= 1
        return arr.removeFirst()
    }
    
    /// Returns, but does not remove, the element at the head of the queue.
    /// - Returns: item at the head of the queue
    /// - Throws: QueueError.EmptyQueue
    func peek() -> T? {
        guard !arr.isEmpty else{
            return nil
        }
        
        return arr[0]
    }
    
    /// The number of elements currently in the queue.
    var count: Int {
        return numElement
    }
    
    /// Whether the queue is empty.
    var isEmpty: Bool {
        return arr.isEmpty
    }
    
    /// Removes all elements in the queue.
    mutating func removeAll() {
        arr = [T]()
    }
    
    /// Returns an array of the elements in their respective dequeue order, i.e.
    /// first element in the array is the first element to be dequeued.
    /// - Returns: array of elements in their respective dequeue order
    func toArray() -> [T] {
        return arr
    }
}
