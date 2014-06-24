method do(block) while(cond) {
  block.apply

  while (cond) do {
    block.apply
  }
}

method doWithBreak(block) while(cond) {
  do {
    block.apply {
      return
    }
  } while (cond)
}

method for(coll) doWithBreak(block) {
  for (coll) do { val ->
    block.apply(val, {
      return
    })
  }
}

method fannkuch(n){
  var p := []
  var q := []
  var s := []

  var sign := 1
  var maxflips := 0
  var sum := 0
  var m := n - 1

  for (0..n) do { i ->
    p.push(i)
    q.push(i)
    s.push(i)
  }

  do {
    var q0 := p[1]
    if (q0 != 0) then {
      for (2..n) do {i->
        q[i] := p[i]
      }
      var flips := 1
      doWithBreak { break ->
        var qq := q[q0+1]
        var pp := p[q0+1]
        if (qq==0) then {
          sum := sum + (sign * flips)
          if (flips > maxflips) then {
            maxflips := flips
          }
          break.apply
        }
        q[q0+1] := q0
        if (q0 >= 3) then {
          var i:= 1
          var j := q0 - 1
          var t

          while { i < j } do {
            t := q[i+1]
            q[i+1] := q[j+1]
            q[j+1] := t
            i := i + 1
            j := j - 1
          }
        }
        q0 := qq
        flips := flips + 1
      } while { true }
    }
    if (sign == 1) then {
      var t := p[2]
      p[2] := p[1]
      p[1] := t
      sign := -1
    } else {
      var t := p[2]
      p[2] := p[3]
      p[3] := t
      sign := 1
      for (2..n) doWithBreak { i, break ->
        var sx := s[i+1]
        if (sx!=0) then {
          s[i+1] := sx - 1
          break.apply
        }
        if ((i) == m) then {
          return [sum,maxflips]
        }
        s[i+1] := i
        t := p[1]
        for (1..(i+1)) do {j->
          p[j] := p[j+1]
        }
        p[i+2] := t
      }
    }
  } while { true }
}

var n := 5
var pf := fannkuch(n)
print "sum = {pf[1]}"
print "Pfannkuchen({n}) = {pf[2]}"
