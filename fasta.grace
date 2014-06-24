import "mgcollections" as mgCollections

var last' := 42
var A := 3877
var C := 29573
var M := 139968

method rand(max) {
  last' := ((last' * A) + C) % M
  return ((max * last') / M)
}

var ALU := "GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGGGAGGCCGAGGCGGGCGGATCACCTGAGGTCAGGAGTTCGAGACCAGCCTGGCCAACATGGTGAAACCCCGTCTCTACTAAAAATACAAAAATTAGCCGGGCGTGGTGGCGCGCGCCTGTAATCCCAGCTACTCGGGAGGCTGAGGCAGGAGAATCGCTTGAACCCGGGAGGCGGAGGTTGCAGTGAGCCGAGATCGCGCCACTGCACTCCAGCCTGGGCGACAGAGCGAGACTCCGTCTCAAAAA"

def IUB = mgCollections.map.new
IUB.put("a", 0.27)
IUB.put("c", 0.12)
IUB.put("g", 0.12)
IUB.put("t", 0.27)
IUB.put("B", 0.02)
IUB.put("D", 0.02)
IUB.put("H", 0.02)
IUB.put("K", 0.02)
IUB.put("M", 0.02)
IUB.put("N", 0.02)
IUB.put("R", 0.02)
IUB.put("S", 0.02)
IUB.put("V", 0.02)
IUB.put("W", 0.02)
IUB.put("Y", 0.02)

def HomoSap = mgCollections.map.new
HomoSap.put("a", 0.3029549426680)
HomoSap.put("c", 0.1979883004921)
HomoSap.put("g", 0.1975473066391)
HomoSap.put("t", 0.3015094502008)

def none = object {
  method asString -> String { "none" }
}

method for (coll) doWithBreak(block) {
  for (coll) do { val ->
    block.apply(val, {
      return
    })
  }
}

method makeCumulative(table) {
  var last := none
  var cpt := 0
  if (table.size == 4) then {
    for (["a", "c", "g", "t"]) do { c ->
      if (cpt != 0) then {
        table.put(c, (table.get(c) + table.get(last)))
      }

      cpt := 1
      last := c
    }
  } else {
    if (table.size == 15) then {
      for (["a", "c", "g", "t","B","D","H","K","M","N","R","S","V","W","Y"]) do { c ->
        if (cpt != 0) then {
          table.put(c, (table.get(c) + table.get(last)))
        }
        cpt := 1
        last := c
      }
    }
  }
}

method fastaRepeat(n,seq) {
  var seqi := 0
  var lenOut := 60
  var m := n
  while { m > 0 } do {
    if (m < lenOut) then {
      lenOut:=m
    }

    if ((seqi + lenOut) < (seq.size)) then {
      print "{seq.substringFrom(seqi+1)to(seqi+lenOut)}"
      seqi := seqi + lenOut
    } else {
      var s := seq.substringFrom(seqi+1)to(seq.size)
      seqi := lenOut - s.size
      print "{s}{seq.substringFrom(1)to(seqi)}"
    }

    m := m - lenOut
  }
}

method fastaRandom(n,table) {
  var line := []
  var num := n
  for (1..60) do { i ->
    line.push(i)
  }

  makeCumulative(table)

  while { num > 0 } do {
    if (num < line.size) then {
      line := []
      for (1..num) do { i ->
        line.push(i)
      }
    }

    for (1..(line.size)) do { i ->
      var r := rand(1)
      if (table.size == 4) then {
        for (["a", "c", "g", "t"]) doWithBreak { c, break ->
          if (r < table.get(c)) then {
            line[i] := c
            break.apply
          }
        }
      } else {
        if (table.size == 15) then {
          for (["a", "c", "g", "t","B","D","H","K","M","N","R","S","V","W","Y"]) doWithBreak { c, break ->
            if (r < table.get(c)) then {
              line[i] := c
              break.apply
            }
          }
        }
      }
    }

    print "{line}"
    num := num - line.size
  }
}

var n' := 200

print ">ONE Homo sapiens alu"
fastaRepeat(2 * n', ALU)

print ">TWO IUB ambiguity codes"
fastaRandom(3 * n', IUB)

print ">THREE Homo sapiens frequency"
fastaRandom(5 * n', HomoSap)
