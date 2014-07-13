method for(coll) doWithBreak(block) {
    for(coll) do { val ->
        block.apply(val, {
            return
        })
    }
}

def none = object {
      method asString -> String { "none" }
  }

class Treenode.new(left',right',item'){
    var left := left'
    var right := right'
    var item := item'

    method itemCheck(){
        if(left == none)then{
            return item
        }else{
            return (item + (left.itemCheck()) - (right.itemCheck()))
        }
    }
}


method bottomUpTree(item, depth){
    if(depth > 0)then{
        return Treenode.new(bottomUpTree(((2*item)-1), (depth - 1)), bottomUpTree((2*item), (depth - 1)), item)
    }else{
        return Treenode.new(none,none,item)
    }
}

binaryTree()

method binaryTree(){
    var minDepth := 4
    var n := 8
    var maxDepth := 0
    if((minDepth+2) < n)then{
        maxDepth := n
    }else{
        maxDepth := minDepth + 2
    }
    var stretchDepth := maxDepth + 1

    var check := bottomUpTree(0,stretchDepth).itemCheck()
    print "stretch tree of depth {stretchDepth}\t check: {check}"

    var longLivedTree := bottomUpTree(0,maxDepth)
    var depth := 0
    var cpt := 0
    for(minDepth..maxDepth)doWithBreak{i', break->
        if(cpt==0)then{
            depth := i'
        }else{
            depth := depth + 2
        }
        if(depth > maxDepth)then{
            break.apply
        }
        cpt := 1
        var iterations := 2 ^ (maxDepth - depth + minDepth)
        check := 0
        for(1..iterations)do{i->
            check := check + bottomUpTree(i,depth).itemCheck()
            check := check + bottomUpTree(-i,depth).itemCheck()
        }
        print "{iterations*2}\t trees of depth {depth}\t check: {check}"
    }
    print "long lived tree of depth {maxDepth}\t check: {longLivedTree.itemCheck()}"
}