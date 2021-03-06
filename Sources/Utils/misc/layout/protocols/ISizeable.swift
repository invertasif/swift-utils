import Foundation

protocol ISizeable:class {//<--new extends class, so that it can be casted correctly without becomming a copy
    var size:CGSize {get set}
    func setSizeValue(_ size:CGSize)
}
/**
 * CAUTION: These extensions can only be used if you dont need to cast the instance to ISizeable
 */
extension ISizeable{
    var width:CGFloat{
        get{
            if(self.size.width.isNaN){fatalError("width can't be NaN")}
            return self.size.width
        }set{
            if(newValue.isNaN){fatalError("width can't be NaN")}
            self.width = newValue
        }
    }
    var height:CGFloat{
        get{
            if(self.size.width.isNaN){fatalError("height can't be NaN")}
            return self.size.height
        } set{
            if(newValue.isNaN){fatalError("height can't be NaN")}
            self.height = newValue
        }
    }
}
