var PI := 3.141592653589793

var SOLAR_MASS := 4 * PI * PI

var DAYS_PER_YEAR := 365.24

var NUM_FIELDS := 7
var BYTES_SIZE := NUM_FIELDS * 8
var X := 1
var Y := 2
var Z := 3
var VX := 4
var VY := 5
var VZ := 6
var MASS := 7

class Body.new(x, y, z, vx, vy, vz, mass, buffer, bodyIndex) {
  var storage_ := [0, 0, 0, 0, 0, 0, 0]
  storage_[X] := x
  storage_[Y] := y
  storage_[Z] := z
  storage_[VX] := vx
  storage_[VY] := vy
  storage_[VZ] := vz
  storage_[MASS] := mass

  method offsetMomentum(px, py, pz) {
    storage_[VX] := -px / SOLAR_MASS
    storage_[VY] := -py / SOLAR_MASS
    storage_[VZ] := -pz / SOLAR_MASS
  }

  method getStorage {
    return storage_
  }
}


class Jupiter.new(buffer, bodyIndex) {
  var myJupiter := Body.new(4.84143144246472090,
    -1.16032004402742839,
    -1.03622044471123109 * (10^(-1)),
    1.66007664274403694 *(10^(-03)) * DAYS_PER_YEAR,
    7.69901118419740425 *(10^(-03)) * DAYS_PER_YEAR,
    -6.90460016972063023 *(10^(-05)) * DAYS_PER_YEAR,
    9.54791938424326609 *(10^(-04)) * SOLAR_MASS,
    buffer, bodyIndex)

  method getStorage {
    return myJupiter.getStorage
  }
}


class Saturn.new(buffer, bodyIndex) {
  var mySaturn := Body.new(8.34336671824457987,
    4.12479856412430479,
    -4.03523417114321381*(10^(-01)),
    -2.76742510726862411*(10^(-03)) * DAYS_PER_YEAR,
    4.99852801234917238*(10^(-03)) * DAYS_PER_YEAR,
    2.30417297573763929*(10^(-05)) * DAYS_PER_YEAR,
    2.85885980666130812*(10^(-04)) * SOLAR_MASS,
    buffer, bodyIndex)

  method getStorage {
    mySaturn.getStorage
  }
}

class Uranus.new(buffer, bodyIndex) {
  var myUranus := Body.new(1.28943695621391310 * 10,
    -1.51111514016986312 * 10,
    -2.23307578892655734*(10^(-01)),
    2.96460137564761618*(10^(-03)) * DAYS_PER_YEAR,
    2.37847173959480950*(10^(-03)) * DAYS_PER_YEAR,
    -2.96589568540237556*(10^(-05)) * DAYS_PER_YEAR,
    4.36624404335156298*(10^(-05)) * SOLAR_MASS,
    buffer, bodyIndex)

  method getStorage {
    myUranus.getStorage
  }
}

class Neptune.new(buffer, bodyIndex) {
  var myNeptune := Body.new(1.53796971148509165 * 10,
    -2.59193146099879641 * 10,
    1.79258772950371181*(10^(-01)),
    2.68067772490389322*(10^(-03)) * DAYS_PER_YEAR,
    1.62824170038242295*(10^(-03)) * DAYS_PER_YEAR,
    -9.51592254519715870*(10^(-05)) * DAYS_PER_YEAR,
    5.15138902046611451*(10^(-05)) * SOLAR_MASS,
    buffer, bodyIndex)

  method getStorage {
    myNeptune.getStorage
  }
}

class Sun.new(buffer, bodyIndex) {
  var mySun := Body.new(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, SOLAR_MASS, buffer, bodyIndex)

  method getStorage {
    mySun.getStorage
  }

  method offsetMomentum(px, py, pz) {
    mySun.offsetMomentum(px, py, pz)
  }
}

class NBodySystem.new(bodies') {
  var bodies := bodies'
  var px := 0.0
  var py := 0.0
  var pz := 0.0
  var theSize := bodies.size

  for (1..theSize) do { i ->
    var b := bodies[i]
    var m := b.getStorage[MASS]
    px := px + b.getStorage[VX] * m
    py := py + b.getStorage[VY] * m
    pz := pz + b.getStorage[VZ] * m
  }
  bodies[1].offsetMomentum(px,py,pz)

  method advance(dt) {
    var dx
    var dy
    var dz
    var distance
    var mag

    for (1..theSize) do { i ->
      var bodyi := bodies[i]
      var imass := bodyi.getStorage[MASS]

      for ((i+1)..theSize) do { j ->
        var bodyj := bodies[j]
        var jmass := bodyj.getStorage[MASS]
        dx := bodyi.getStorage[X] - bodyj. getStorage[X]
        dy := bodyi.getStorage[Y] - bodyj. getStorage[Y]
        dz := bodyi.getStorage[Z] - bodyj. getStorage[Z]

        distance := ((dx * dx) + (dy * dy) + (dz * dz)) ^(1/2)
        mag := dt / (distance * distance * distance)

        bodyi.getStorage[VX] := bodyi.getStorage[VX] - (dx * jmass * mag)
        bodyi.getStorage[VY] := bodyi.getStorage[VY] - (dy * jmass * mag)
        bodyi.getStorage[VZ] := bodyi.getStorage[VZ] - (dz * jmass * mag)

        bodyj.getStorage[VX] := bodyj.getStorage[VX] - (dx * imass * mag)
        bodyj.getStorage[VY] := bodyj.getStorage[VY] - (dy * imass * mag)
        bodyj.getStorage[VZ] := bodyj.getStorage[VZ] - (dz * imass * mag)
      }

      bodyi.getStorage[X] := bodyi.getStorage[X] + (dt * bodyi.getStorage[VX])
      bodyi.getStorage[Y] := bodyi.getStorage[Y] + (dt * bodyi.getStorage[VY])
      bodyi.getStorage[Z] := bodyi.getStorage[Z] + (dt * bodyi.getStorage[VZ])
    }
  }


  method energy {
    var dx
    var dy
    var dz
    var distance
    var e := 0.0

    for (1..theSize) do { i ->
      var bodyi := bodies[i]
      e := e + (0.5 * bodyi.getStorage[MASS] * ((bodyi.getStorage[VX] * bodyi.getStorage[VX]) + (bodyi.getStorage[VY] * bodyi.getStorage[VY]) + (bodyi.getStorage[VZ] * bodyi.getStorage[VZ])))

      for ((i+1)..theSize) do { j ->
        var bodyj := bodies[j]
        dx := bodyi.getStorage[X] - bodyj.getStorage[X]
        dy := bodyi.getStorage[Y] - bodyj.getStorage[Y]
        dz := bodyi.getStorage[Z] - bodyj.getStorage[Z]
        distance := ((dx * dx) + (dy * dy) + (dz * dz)) ^(1/2)
        e := e - (bodyi.getStorage[MASS] * bodyj.getStorage[MASS])/distance
      }
    }

    e
  }
}

var number := 3

method runtest(n) {
  var bodybuffer := [BYTES_SIZE * 5]
  var bodies := NBodySystem.new([Sun.new(bodybuffer, 0),
    Jupiter.new(bodybuffer, 1),
    Saturn.new(bodybuffer, 2),
    Uranus.new(bodybuffer, 3),
    Neptune.new(bodybuffer, 4)])

  print "bodies.energy1 = {bodies.energy}"

  for (0..n) do { i ->
    bodies.advance(0.01)
  }

  print "bodies.energy2 = {bodies.energy}"
}

runtest(number)
