import std/strutils
import std/sugar
import std/tables

type
    JobKind = enum
        Number
        Operation

    OpKind = enum
        Add = "+"
        Minus = "-"
        Divide = "/"
        Multiply = "*"

    Job = ref object
        name: string
        case kind: JobKind
        of Number:
            val: int
        of Operation:
            op: OpKind
            leftName, rightName: string

func parseJob(s: string): Job =
    let tokens = s.split(':')
    let jobTokens = tokens[1].splitWhiteSpace()
    if jobTokens.len == 1:
        Job(
            name: tokens[0],
            kind: Number,
            val: jobTokens[0].parseInt(),
        )
    else:
        Job(
            name: tokens[0],
            kind: Operation,
            op: parseEnum[OpKind](jobTokens[1]),
            leftName: jobTokens[0],
            rightName: jobTokens[2],
        )

let jobs = collect:
    for line in stdin.lines:
        parseJob(line)

type
    JobNode = ref object
        job: Job
        val: int
        left, right: JobNode

func createNode(name: string, jobs: Table[string, Job]): JobNode =
    let job = jobs[name]

    case job.kind:
    of Number:
        JobNode(
            job: job,
        )
    of Operation:
        JobNode(
            job: job,
            left: createNode(job.leftName, jobs),
            right: createNode(job.rightName, jobs),
        )

func createBinaryExprTree(rootName: string, jobs: seq[Job]): JobNode =
    let lookup = collect:
        for job in jobs:
            {job.name: job}

    createNode(rootName, lookup)

var tree = createBinaryExprTree("root", jobs)

func doOperation(op: OpKind, left, right: int): int =
    case op:
    of Add: left + right
    of Minus: left - right
    of Divide: left div right
    of Multiply: left * right

func evaluate(n: var JobNode): JobNode =
    case n.job.kind:
    of Number:
        n.val = n.job.val
    of Operation:
        n.val = doOperation(
            n.job.op,
            evaluate(n.left).val,
            evaluate(n.right).val,
        )
    return n

echo "Part 1: ", int(tree.evaluate().val)

func hasPath(n: JobNode, name: string, path: var seq[JobNode]): bool =
    if n == nil:
        return false

    path.add(n)

    if n.job.name == name:
        return true

    if hasPath(n.left, name, path) or hasPath(n.right, name, path):
        return true

    discard path.pop()
    return false

func pathToNode(n: JobNode, name: string): seq[JobNode] =
    discard hasPath(n, name, result)

const
    HUMAN_JOB_NAME = "humn"

let pathToHumn = tree.pathToNode(HUMAN_JOB_NAME)[1..^1]
let humnTree = pathToHumn[0]
let target = (if tree.left == humnTree: tree.right.val else: tree.left.val)

func invertOp(op: OpKind): OpKind =
    case op:
    of Add: Minus
    of Minus: Add
    of Divide: Multiply
    of Multiply: Divide

func solveFor(
    name: string,
    target: int,
    pathToName: seq[JobNode]
): int =
    var target = target

    let n = pathToName[0]
    if n.job.name == name:
        return target

    let nameLeft = n.left == pathToName[1]
    if nameLeft:
        # If the equation is of the form `name <op> num`, invert the operation
        # (i.e., `target <inv-op> num`).
        # e.g.,:
        #   name + num = target
        #   name - num = target
        #   name / num = target
        #   name * num = target
        let invOp = invertOp(n.job.op)
        target = doOperation(invOp, target, n.right.val)
    else:
        # Otherwise, the equations is of the form `num <op> name`. Invert the
        # operation (i.e., `target <inv-op> num`) unless it is subtraction
        # (i.e., num - target).
        # e.g.,:
        #   num + name = target
        #   num - name = target
        #   num / name = target
        #   num * name = target
        case n.job.op:
        of Minus:
            target = doOperation(n.job.op, n.left.val, target)
        else:
            let invOp = invertOp(n.job.op)
            target = doOperation(invOp, target, n.left.val)

    solveFor(name, target, pathToName[1..^1])

echo "Part 2: ", solveFor(HUMAN_JOB_NAME, target, pathToHumn)
