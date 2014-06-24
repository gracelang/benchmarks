var COUNT := 1000

// These two constants specify how many times a packet is queued and
// how many times a task is put on hold in a correct run of richards.
// They don't have any meaning a such but are characteristic of a
// correct run so if the actual queue or hold count is different from
// the expected there must be a bug in the implementation.

var EXPECTED_QUEUE_COUNT := 2322
var EXPECTED_HOLD_COUNT := 928

var ID_IDLE     := 1
var ID_WORKER   := 2
var ID_HANDLER_A  := 3
var ID_HANDLER_B  := 4
var ID_DEVICE_A   := 5
var ID_DEVICE_B   := 6
var NUMBER_OF_IDS := 6
var KIND_DEVICE   := 0
var KIND_WORK   := 1

// The task is running and is currently scheduled.
var STATE_RUNNING := 0

// The task has packets left to process.
var STATE_RUNNABLE := 1

// The task is not currently running.  The task is not blocked as such and may
// be started by the scheduler.
var STATE_SUSPENDED := 2

// The task is blocked and cannot be run until it is explicitly released.
var STATE_HELD := 4

// var STATE_SUSPENDED_RUNNABLE := STATE_SUSPENDED | STATE_RUNNABLE
var STATE_SUSPENDED_RUNNABLE := 3

// var STATE_NOT_HELD := ~STATE_HELD
var STATE_NOT_HELD := -5

var DATA_SIZE := 4

def none = object {
  method asString -> String { "none" }
}

class Scheduler.new {
  var queueCount := 0
  var holdCount := 0
  var blocks := []

  for (1..NUMBER_OF_IDS) do {
    blocks.push(1)
  }

  var list := none
  var currentTcb := none
  var currentId := none

  // Add an idle task to this scheduler.
  //@param {int} id the identity of the task
  //@param {int} priority the task's priority
  //@param {Packet} queue the queue of work to be processed by the task
  //@param {int} count the number of times to schedule the task
  method addIdleTask(id, priority, queue, count) {
    addRunningTask(id, priority, queue, IdleTask.new(self, 1, count))
  }

  // Add a work task to this scheduler.
  //@param {int} id the identity of the task
  //@param {int} priority the task's priority
  //@param {Packet} queue the queue of work to be processed by the task
  method addWorkerTask(id, priority, queue) {
    addTask(id, priority, queue, WorkerTask.new(self, ID_HANDLER_A, 0))
  }

  // Add a handler task to this scheduler.
  //@param {int} id the identity of the task
  //@param {int} priority the task's priority
  //@param {Packet} queue the queue of work to be processed by the task
  method addHandlerTask(id, priority, queue) {
    addTask(id, priority, queue, HandlerTask.new(self))
  }

  // Add a handler task to this scheduler.
  //@param {int} id the identity of the task
  //@param {int} priority the task's priority
  //@param {Packet} queue the queue of work to be processed by the task
  method addDeviceTask(id, priority, queue) {
    addTask(id, priority, queue, DeviceTask.new(self))
  }

  // Add the specified task and mark it as running.
  //@param {int} id the identity of the task
  //@param {int} priority the task's priority
  //@param {Packet} queue the queue of work to be processed by the task
  //@param {Task} task the task to add
  method addRunningTask(id, priority, queue, task) {
    addTask(id, priority, queue, task)
    currentTcb.setRunning
  }

  // Add the specified task to this scheduler.
  //@param {int} id the identity of the task
  //@param {int} priority the task's priority
  //@param {Packet} queue the queue of work to be processed by the task
  //@param {Task} task the task to add
  method addTask(id, priority, queue, task) {
    currentTcb := TaskControlBlock.new(list, id, priority, queue, task)
    list := currentTcb
    blocks[id] := currentTcb
  }

  // Execute the tasks managed by this scheduler.
  method schedule {
    currentTcb := list
    var cpt := 0

    while { currentTcb != none } do {
      if (currentTcb.isHeldOrSuspended) then {
        currentTcb := currentTcb.link
      } else {
        currentId := currentTcb.id
        currentTcb := currentTcb.run
      }

      cpt := cpt + 1
    }
  }

  // Release a task that is currently blocked and return the next block to run.
  //@param {int} id the id of the task to suspend
  method release(id) {
    var tcb := blocks[id]
    if (tcb == none) then {
      return tcb
    }

    tcb.markAsNotHeld

    if (tcb.getPriority > currentTcb.getPriority) then {
      tcb
    } else {
      currentTcb
    }
  }


  // Block the currently executing task and return the next task control block
  // to run.  The blocked task will not be made runnable until it is explicitly
  // released, even if new work is added to it.
  method holdCurrent {
    holdCount := holdCount +1
    currentTcb.markAsHeld
    currentTcb.link
  }


  // Suspend the currently executing task and return the next task control block
  // to run.  If new work is added to the suspended task it will be made runnable.
  method suspendCurrent {
    currentTcb.markAsSuspended
    currentTcb
  }

  // Add the specified packet to the end of the worklist used by the task
  // associated with the packet and make the task runnable if it is currently
  // suspended.
  //@param {Packet} packet the packet to add
  method queue(packet) {
    var t := blocks[packet.id]
    if (t == none) then {
      return t
    }

    queueCount := queueCount + 1
    packet.link := none
    packet.id := currentId

    t.checkPriorityAdd(currentTcb, packet)
  }
}

// A task control block manages a task and the queue of work packages associated
// with it.
//@param {TaskControlBlock} link the preceding block in the linked block list
//@param {int} id the id of this block
//@param {int} priority the priority of this block
//@param {Packet} queue the queue of packages to be processed by the task
//@param {Task} task the task
//@constructor
class TaskControlBlock.new(link', id', priority', queue', task') {
  var link is public := link'
  var id is public := id'
  var priority := priority'
  var queue := queue'
  var task := task'
  var state := none
  var suspended := false
  var held := false
  var runnable := false

  if (queue == none) then {
    state := STATE_SUSPENDED
  } else {
    state := STATE_SUSPENDED_RUNNABLE
  }

   method getLink{
    return link
  }

  method getId {
    return id
  }

  method getPriority {
    return priority
  }

  method getQueue {
    return queue
  }

  method getTask {
    return task
  }

  method setRunning {
    state := STATE_RUNNING
  }

  method markAsNotHeld {
    if (((state % 8) == 0) || ((state % 8) == 1) || ((state % 8) == 2) || ((state % 8) == 3)) then {
      state := state
    } else {
      state := state - 4
    }

    self.held := false
  }

  method markAsHeld {
    if (((state % 8) == 0) || ((state % 8) == 1) || ((state % 8) == 2) || ((state % 8) == 3)) then {
      state := state + 4
    } else {
      state := state
    }

    self.held := true
  }

  method isHeldOrSuspended {
    if (state <= STATE_HELD) then {
      self.held := false
    } else {
      self.held := true
    }

    if (state == STATE_SUSPENDED) then {
      self.suspended := true
    } else {
      self.suspended := false
    }

    (self.held == true) || (self.suspended == true)
  }

  method markAsSuspended {
    if (((state % 4) == 0) || ((state % 4) == 1)) then {
      state := state + 2
    } else {
      if (((state % 4) == 2) || ((state % 4) == 3)) then {
        state := state
      }
    }

    self.suspended := true
  }

  method markAsRunnable {
    if ((state % 2) == 0) then {
      state := state + 1
    } else {
      if ((state % 2) == 1) then {
        state := state
      }
    }

    self.runnable := true
  }

  // Runs this task, if it is ready to be run, and returns the next task to run.
  method run {
    var packet

    if (state == STATE_SUSPENDED_RUNNABLE) then {
      packet := queue
      queue := packet.getLink
      if (queue == none ) then {
        state := STATE_RUNNING
      } else {
        state := STATE_RUNNABLE
      }
    } else {
      packet := none
    }

    task.run(packet)
  }

  // Adds a packet to the worklist of this block's task, marks this as runnable if
  // necessary, and returns the next runnable object to run (the one
  // with the highest priority).
  method checkPriorityAdd(task, packet) {
    if (queue == none) then {
      queue := packet
      markAsRunnable

      if (priority > task.getPriority) then {
        return self
      }
    } else {
      queue := packet.addTo(queue)
    }

    task
  }

  method asString {
    "tcb {task} + {state}"
  }
}

class IdleTask.new(scheduler', v1', count') {
  var scheduler := scheduler'
  var v1 := v1'
  var count := count'
  var cpt1 := 0

  method run(packet) {
    count := count - 1
    if (count ==0) then {
      return scheduler.holdCurrent
    }

    if (v1 < 500) then {
      v1 := v1 + 1
      scheduler.release(ID_DEVICE_A)
    } else {
      v1 := v1 + 1
      scheduler.release(ID_DEVICE_B)
    }
  }

  method asString {
    "IdleTask"
  }
}

// A task that suspends itself after each time it has been run to simulate
// waiting for data from an external device.
//@param {Scheduler} scheduler the scheduler that manages this task
//@constructor
class DeviceTask.new(scheduler') {
  var scheduler := scheduler'
  var v1 := none

  method run(packet) {
    if (packet == none) then {
      if (v1 == none) then {
        return scheduler.suspendCurrent
      }

      var v := v1
      v1 := none
      scheduler.queue(v)
    } else {
      v1 := packet
      scheduler.holdCurrent
    }
  }

  method asString {
    "DeviceTask"
  }
}

//A task that manipulates work packets.
//@param {Scheduler} scheduler the scheduler that manages this task
//@param {int} v1 a seed used to specify how work packets are manipulated
//@param {int} v2 another seed used to specify how work packets are manipulated
//@constructor
class WorkerTask.new(scheduler', v1', v2') {
  var scheduler := scheduler'
  var v1 := v1'
  var v2 := v2'

  method run(packet) {
    if (packet == none) then {
      scheduler.suspendCurrent
    } else {
      if (v1 == ID_HANDLER_A) then {
        v1 := ID_HANDLER_B
      } else {
        v1 := ID_HANDLER_A
      }

      packet.id := v1
      packet.a1 := 0
      var forWorker := 0

      for (1..DATA_SIZE) do { i ->
        forWorker := forWorker + 1
        v2 := v2 + 1

        if (v2 > 26) then {
          v2 := 1
        }

        packet.a2[i] := v2
      }

      scheduler.queue(packet)
    }
  }

   method asString {
    "WorkerTask"
  }
}

// A task that manipulates work packets and then suspends itself.
//@param {Scheduler} scheduler the scheduler that manages this task
//@constructor
class HandlerTask.new(scheduler') {
  var scheduler := scheduler'
  var v1 := none
  var v2 := none

  method run(packet) {
    if (packet != none) then {
      if (packet.getKind == KIND_WORK) then {
        v1 := packet.addTo(v1)
      } else {
        v2 := packet.addTo(v2)
      }
    }

    if (v1 != none) then {
      var count := v1.a1
      var v

      if (count < DATA_SIZE) then {
        if (v2 != none) then {
          v := v2
          v2 := v2.link
          v.a1 := v1.a2[count+1]
          v1.a1 := count + 1
          return scheduler.queue(v)
        }
      } else {
        v := v1
        v1 := v1.link
        return scheduler.queue(v)
      }
    }

    scheduler.suspendCurrent
   }

   method asString {
    "HandlerTask"
  }
}

class Packet.new(link', id', kind') {
  var link is public := link'
  var id is public := id'
  var kind := kind'
  var a1 is public := 0
  var a2 is public := []

  for (1..DATA_SIZE) do {
    a2.push(1)
  }

  // Add this packet to the end of a worklist, and return the worklist.
  //@param {Packet} queue the worklist to add this packet to

  method addTo(queue) {
    link := none
    if (queue == none) then {
      return self
    }

    var peek
    var next := queue

    while { (next.getLink) != none } do {
      peek := next.getLink
      next := peek
    }

    next.link := self
    queue
   }

  method setLink(theLink) {
    link := theLink
  }

  method getLink {
    link
  }

  method getId {
    id
  }

  method getKind {
    kind
  }

  method asString{
    "Packet"
  }
}

//Main call
runRichards(3)

//Main function
method runRichards(iters) {
  for (1..iters) do { i ->
    var scheduler := Scheduler.new
    scheduler.addIdleTask(ID_IDLE, 0, none, COUNT)
    var queue := Packet.new(none, ID_WORKER, KIND_WORK)
    queue := Packet.new(queue, ID_WORKER, KIND_WORK)

    scheduler.addWorkerTask(ID_WORKER, 1000, queue)
    queue := Packet.new(none, ID_DEVICE_A, KIND_DEVICE)
    queue := Packet.new(queue, ID_DEVICE_A, KIND_DEVICE)

    queue := Packet.new(queue, ID_DEVICE_A, KIND_DEVICE)
    scheduler.addHandlerTask(ID_HANDLER_A, 2000, queue)

    queue := Packet.new(none, ID_DEVICE_B, KIND_DEVICE)
    queue := Packet.new(queue, ID_DEVICE_B, KIND_DEVICE)
    queue := Packet.new(queue, ID_DEVICE_B, KIND_DEVICE)
    scheduler.addHandlerTask(ID_HANDLER_B, 3000, queue)

    scheduler.addDeviceTask(ID_DEVICE_A, 4000, none)

    scheduler.addDeviceTask(ID_DEVICE_B, 5000, none)

    scheduler.schedule
  }
}
