import M "mo:matchers/Matchers";
import S "mo:matchers/Suite";
import T "mo:matchers/Testable";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Array "mo:base/Array";
import SCC "../src/scc";

func topoGroups(nodes : [[Text]]) : M.Matcher<[[Text]]> {
  M.equals(T.array(T.arrayTestable(T.textTestable), nodes))
};

let suite = S.suite("scc", [
    S.test("empty input",
      SCC.scc<Text>(Text.compare, [].vals()),
      topoGroups([]),
    ),
    S.test("single node",
      SCC.scc<Text>(Text.compare, [
        ("A", [].vals()),
      ].vals()),
      topoGroups([["A"]]),
    ),
    S.test("single node, with loop",
      SCC.scc<Text>(Text.compare, [
        ("A", ["A"].vals()),
      ].vals()),
      topoGroups([["A"]]),
    ),
    S.test("two nodes, no edges",
      SCC.scc<Text>(Text.compare, [
        ("A", [].vals()),
        ("B", [].vals()),
      ].vals()),
      topoGroups([["B"], ["A"]]),
    ),
    S.test("two nodes, edge A → B",
      SCC.scc<Text>(Text.compare, [
        ("A", ["B"].vals()),
        ("B", [].vals()),
      ].vals()),
      topoGroups([["A"], ["B"]]),
    ),
    S.test("two nodes, edge B → A",
      SCC.scc<Text>(Text.compare, [
        ("A", [].vals()),
        ("B", ["A"].vals()),
      ].vals()),
      topoGroups([["B"], ["A"]]),
    ),
    S.test("two nodes, two edges",
      SCC.scc<Text>(Text.compare, [
        ("A", ["B"].vals()),
        ("B", ["A"].vals()),
      ].vals()),
      topoGroups([["A","B"]]),
    ),
    S.test("two nodes, multi edges",
      SCC.scc<Text>(Text.compare, [
        ("A", ["B"].vals()),
        ("B", ["A", "B", "A"].vals()),
      ].vals()),
      topoGroups([["A","B"]]),
    ),
    S.test("three nodes, circle",
      SCC.scc<Text>(Text.compare, [
        ("A", ["B"].vals()),
        ("B", ["C"].vals()),
        ("C", ["A"].vals()),
      ].vals()),
      topoGroups([["A","B","C"]]),
    ),
    S.test("three nodes, two components, disjoint",
      SCC.scc<Text>(Text.compare, [
        ("A", ["C"].vals()),
        ("B", ["B"].vals()),
        ("C", ["A"].vals()),
      ].vals()),
      topoGroups([["B"],["A", "C"]]),
    ),
    S.test("three nodes, two components, one direction",
      SCC.scc<Text>(Text.compare, [
        ("A", ["C"].vals()),
        ("B", ["B", "A"].vals()),
        ("C", ["A"].vals()),
      ].vals()),
      topoGroups([["B"],["A", "C"]]),
    ),
    S.test("three nodes, two components, other direction",
      SCC.scc<Text>(Text.compare, [
        ("A", ["C"].vals()),
        ("B", ["B"].vals()),
        ("C", ["A", "B"].vals()),
      ].vals()),
      topoGroups([["A", "C"],["B"]]),
    ),
    S.test("chain",
      SCC.scc<Text>(Text.compare, [
        ("A", ["B"].vals()),
        ("B", ["C"].vals()),
        ("C", ["D"].vals()),
        ("D", ["E"].vals()),
      ].vals()),
      topoGroups([["A"], ["B"], ["C"], ["D"], ["E"]]),
    ),
    S.test("chain, reversed",
      SCC.scc<Text>(Text.compare, [
        ("D", ["E"].vals()),
        ("C", ["D"].vals()),
        ("B", ["C"].vals()),
        ("A", ["B"].vals()),
      ].vals()),
      topoGroups([["A"], ["B"], ["C"], ["D"], ["E"]]),
    ),
]);

S.run(suite);
