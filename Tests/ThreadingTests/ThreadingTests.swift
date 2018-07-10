import XCTest
@testable import Threading

final class ThreadingTests: XCTestCase {
    
    func testAtomic() {
        let atomic = Atomic<Int>(0)
        DispatchQueue.concurrentPerform(iterations: 1000) { value in
            atomic.loading { value in
                value += 1
            }
        }
        print(atomic.load())
    }
    
    func testArray() {
        let array = ThreadedArray<Int>()
        let count = 1000
        DispatchQueue.concurrentPerform(iterations: count) { _ in
            if let x = array.last {
                array.append(x + array.count)
            } else {
                array.append(0)
            }
        }
        XCTAssert(array.count == count)
    }
    
    func testDictionary() {
        let dic = ThreadedDictionary<Int, Int>()
        let count = 1000
        DispatchQueue.concurrentPerform(iterations: count) { i in
            dic[i / 4] = dic[i] ?? 0
        }
        XCTAssert(dic.count == count / 4)
    }
    
    func testQueue() {
        let queue = ThreadedQueue<Int>()
        let shouldContinue = Atomic<Bool>(true)
        var array = [Int]()
        DispatchQueue.global().async {
            DispatchQueue.concurrentPerform(iterations: 1000) { i in
                queue.enqueue(i)
            }
            shouldContinue.store(false)
        }
        while shouldContinue.load() || !queue.isEmpty {
            if !queue.isEmpty {
                array.append(queue.dequeue())
            }
        }
        
        XCTAssert(array.count == 1000)
    }

    func testLinkedQueue() {
        var queue = LinkedQueue<Int>()
        queue.enqueue(1)
        XCTAssert(queue.count == 1)
        XCTAssert(queue.dequeue() == 1)
        XCTAssert(queue.count == 0)
        queue.enqueue(2)
        XCTAssert(queue.count == 1)
        XCTAssert(queue.dequeue() == 2)
        XCTAssert(queue.count == 0)
    }


    static var allTests = [
        ("testAtomic", testAtomic),
        ("testArray", testArray),
        ("testDictionary", testDictionary),
        ("queueTest", testQueue),
    ]
}
