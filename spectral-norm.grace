method eval_A(i, j) {
  var ij := i + j
  1.0 / (ij * (ij + 1) / 2 + i + 1)
}

method eval_A_times_u(u) {
  var myTab := []

  for (1..(u.size)) do { i ->
    var sum := 0

    for (1..(u.size)) do { j ->
      sum := sum + (eval_A(i-1, j-1) * (u[j]))
    }

    myTab.push(sum)
  }

  myTab
}

method eval_At_times_u(u) {
  var myTab := []

  for (1..(u.size)) do { i ->
    var sum := 0

    for (1..(u.size)) do { j ->
      sum := sum + (eval_A(j-1, i-1) * (u[j]))
    }

    myTab.push(sum)
  }

  myTab
}

method eval_AtA_times_u(u) {
  eval_At_times_u(eval_A_times_u(u))
}

method main(n) {
  var u := []

  for (1..n) do {
    u.push(1)
  }

  var v
  for (1..10) do { i ->
    v := eval_AtA_times_u(u)
    u := eval_AtA_times_u(v)
  }

  var vBv := 0
  var vv := 0
  for (1..(u.size)) do { i ->
    vBv := vBv + ((u[i]) * (v[i]))
    vv := vv + ((v[i]) * (v[i]))
  }

  print "RESULT = {(vBv/vv)^(1/2)}"
}

main(3)
