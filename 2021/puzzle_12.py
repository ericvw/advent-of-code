import fileinput

Graph = dict[str, set[str]]

# Parse
connections = [tuple(line.rstrip().split("-")) for line in fileinput.input()]

# Init
graph: Graph = {}
for a, b in connections:
    graph.setdefault(a, set()).add(b)
    graph.setdefault(b, set()).add(a)


# Main
def num_paths(graph: Graph, start: str, end: str, *, twice: bool = False) -> int:
    def recursive_num_paths(
        graph: Graph, cave: str, visited: set[str], twice: bool
    ) -> int:
        if cave == end:
            return 1

        if cave.islower():
            twice &= cave not in visited
            visited.add(cave)

        return sum(
            recursive_num_paths(graph, n, visited.copy(), twice)
            for n in graph[cave]
            if n != start and (n not in visited or twice)
        )

    return recursive_num_paths(graph, start, set(), twice)


print("Part 1:", num_paths(graph, 'start', 'end'))
print("Part 2:", num_paths(graph, 'start', 'end', twice=True))
