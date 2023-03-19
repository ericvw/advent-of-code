import std/deques
import std/strutils
import std/tables

type
    Command = enum
        CmdCd = "cd"
        CmdLs = "ls"

    NodeKind = enum
        File
        Directory

    Node = ref object
        name: string
        size: int
        case kind: NodeKind
        of File:
            discard
        of Directory:
            nodes: Table[string, Node]


iterator directories(t: Table[string, Node]): Node =
    for v in t.values:
        if v.kind == Directory:
            yield v

let root = Node(kind: Directory, name: "/")

var dirStack: Deque[Node]
for line in stdin.lines:
    let tokens = line.splitWhitespace()
    case tokens[0]:
    of "$":
        case parseEnum[Command](tokens[1])
        of CmdCd:
            case tokens[2]:
            of "/":
                dirStack.clear()
                dirStack.addLast(root)
            of "..":
                dirStack.popLast()
            else:
                # Check to make sure we traverse each unique directory once.
                assert dirStack.peekLast().nodes[tokens[2]].size == 0
                dirStack.addLast(dirStack.peekLast().nodes[tokens[2]])
        of CmdLs:
            # Nothing to process because non-Commands are `ls` output.
            continue
    of "dir":
        dirStack.peekLast().nodes[tokens[1]] = Node(
            kind: Directory,
            name: tokens[1]
        )
    else:
        let size = parseInt(tokens[0])
        dirStack.peekLast().nodes[tokens[1]] = Node(
            kind: File,
            name: tokens[1],
            size: size
        )

# Without knowing the guarantees of the `cd` commands, compute directory sizes
# after building the initial filesystem hierarchy.
proc computeDirSize(node: Node) =
    assert node.kind == Directory
    for v in node.nodes.values:
        if v.kind == Directory:
            computeDirSize(v)
        inc(node.size, v.size)

computeDirSize(root)

const FILE_SIZE_THRESHOLD = 100000
var sizeSum = 0

dirStack.clear()
dirStack.addLast(root)
while dirStack.len > 0:
    let cur = dirStack.popLast()
    if cur.size <= FILE_SIZE_THRESHOLD:
        inc(sizeSum, cur.size)
    for v in cur.nodes.directories:
        dirStack.addLast(v)

echo "Part 1: ", sizeSum

const
    TOTAL_SPACE_AVAILABLE = 70000000
    UNUSED_SPACE_THRESHOLD = 30000000

let
    currentUnused = TOTAL_SPACE_AVAILABLE - root.size
    deleteToMeetThreshold = UNUSED_SPACE_THRESHOLD - currentUnused

var smallestDirSize = root.size

dirStack.clear()
dirStack.addLast(root)
while dirStack.len > 0:
    let cur = dirStack.popLast()
    if cur.size >= deleteToMeetThreshold:
        smallestDirSize = min(cur.size, smallestDirSize)
    for v in cur.nodes.directories:
        dirStack.addLast(v)

echo "Part 2: ", smallestDirSize
