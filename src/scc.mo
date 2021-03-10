/// Stongly connected components
///
/// This library provides a simple implementation of a SCC algorithm. It is parametrized over the `Node` type, which must be comparable. (The algorithm uses the RBTree from `base` internally).
///
///
/// ```motoko
/// import SCC "mo:scc/scc";
///
/// assert(
///   SCC.scc<Text>(Text.compare, [
///     ("A", ["C"].vals()),
///     ("B", ["B", "A"].vals()),
///     ("C", ["A"].vals()),
///   ].vals())
///   == [["B"],["A", "C"]);
/// ```

import Iter "mo:base/Iter";
import Order "mo:base/Order";
import Option "mo:base/Option";
import RBTree "mo:base/RBTree";
import List "mo:base/List";
import Debug "mo:base/Debug";

module {

  /// Calculates the list of strongly connected components of the graph
  /// described by the parameter `edges`.
  ///
  /// The `edges` parameter lists each node, together with its outgoing edges.
  /// It uses iterators, so that the caller can flexibly use various data
  /// structures.
  ///
  /// The result is the list of strongly connected components, in toplogical order.
  public func scc<Node>
    ( compareTo : (Node, Node) -> Order.Order,
      edges : Iter.Iter<(Node,Iter.Iter<Node>)> ) :
    [[Node]] {

    // Turn the edges into a graph representation
    var es = RBTree.RBTree<Node,[Node]>(compareTo);

    for ((n,ns) in edges) {
      es.put(n,Iter.toArray(ns));
    };

    // Set up maps and stacks for the SCC algorithm
    // following https://en.wikipedia.org/wiki/Path-based_strong_component_algorithm

    var s = List.nil<Node>();
    var p = List.nil<Node>();
    var n = RBTree.RBTree<Node,Nat>(compareTo);
    var done = RBTree.RBTree<Node,()>(compareTo);
    var c = 0;
    var sccs = List.nil<[Node]>();

    func go(v : Node) {
      // Debug.print(debug_show("go",v, List.toArray(s), List.toArray(p), List.toArray(sccs)));

      // Set the preorder number of v to C, and increment C.
      n.put(v,c);
      c += 1;
      // Push v onto S and also onto P.
      s := List.push(v,s);
      p := List.push(v,p);
      // For each edge from v to a neighboring vertex w:
      for (w in Option.get(es.get(v), []).vals()) {
        // If the preorder number of w has not yet been assigned (the edge is a tree edge)
        switch (n.get(w)) {
          // recursively search w;
          case null { go (w) };
          // Otherwise
          case (?nw) {
            // if w has not yet been assigned to a strongly connected component
            if (Option.isNull(done.get(w))) {
              // Repeatedly pop vertices from P
              label done_popping loop {
                let (x, p_tail) = Option.unwrap(p);
                let nx = Option.unwrap(n.get(x));
                // until the top element of P has a preorder number less than or equal to the preorder number of w.
                if (nx <= nw) {break done_popping; };
                p := p_tail;
              };
            };
          };
        };
      };

      // If v is the top element of P:
      let (x, p_tail) = Option.unwrap(p);
      if (compareTo(x,v) == #equal) {
        // Pop vertices from S until v has been popped
        var scc = List.nil<Node>();
        label done_popping loop {
          let (x, s_tail) = Option.unwrap(s);
          s := s_tail;
          done.put(x,());
          scc := List.push(x, scc);
          if (compareTo(x,v) == #equal) { break done_popping; }
        };
        // and assign the popped vertices to a new component.
        sccs := List.push(List.toArray(scc), sccs);
        // Pop v from P.
        p := p_tail;
      };

      // Debug.print(debug_show("go done",v, List.toArray(s), List.toArray(p), List.toArray(sccs)));
    };

    for ((v,_) in es.entries()) {
      switch (n.get(v)) {
        case (?_) {}; // already handled
        case null { go(v) };
      };
    };

    return List.toArray(sccs);
  }
}
