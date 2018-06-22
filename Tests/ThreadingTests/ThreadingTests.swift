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
        let q = CircularQueue<Int>()
        for i in 0..<20 {
            print("\(i) -> \(q.index(after: i))")
        }
    }


    static var allTests = [
        ("testAtomic", testAtomic),
        ("testArray", testArray),
        ("testDictionary", testDictionary),
        ("queueTest", testQueue),
    ]
}
