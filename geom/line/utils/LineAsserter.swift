import Foundation

class LineAsserter {
    /**
     *
     */
    class func intersects(a:Line,_ b:Line) -> Bool {// :TODO: rename to isSomeName
        return PointAsserter.intersects(a.p1, a.p2, b.p1, b.p2)
    }
}