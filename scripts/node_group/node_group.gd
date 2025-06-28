## Local, nonserializable shared node group.

## Not being serializable is a tradeoff for working with Node references 
## directly.

extends Resource
class_name NodeGroup

var nodes:Array[Node] = []

func add_node(n:Node):
	nodes.push_back(n)
	n.tree_exiting.connect(
		remove_node.bind(n)
	)

func remove_node(n:Node):
	for i in nodes.size():
		if nodes[i] == n: 
			nodes.remove_at(i)
