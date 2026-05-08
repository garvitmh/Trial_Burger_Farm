# Graph Report - lib  (2026-05-07)

## Corpus Check
- 8 files · ~1,216 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 48 nodes · 47 edges · 8 communities (5 shown, 3 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `824ce35e`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter_riverpod/flutter_riverpod.dart` - 3 edges
2. `package:flutter/material.dart` - 2 edges
3. `package:firebase_auth/firebase_auth.dart` - 2 edges
4. `../../domain/entities/user_entity.dart` - 2 edges
5. `../../domain/repositories/auth_repository.dart` - 2 edges
6. `MyApp` - 1 edges
7. `main` - 1 edges
8. `ProviderScope` - 1 edges
9. `build` - 1 edges
10. `MaterialApp` - 1 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Communities (8 total, 3 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.2
Nodes (9): build, dispose, Icon, Scaffold, SizedBox, TestAuthScreen, _TestAuthScreenState, Text (+1 more)

### Community 1 - "Community 1"
Cohesion: 0.22
Nodes (8): build, main, MaterialApp, MyApp, ProviderScope, package:firebase_core/firebase_core.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart

### Community 2 - "Community 2"
Cohesion: 0.22
Nodes (8): AuthNotifier, AuthRepositoryImpl, AuthState, copyWith, resetVerificationId, ../../data/datasources/firebase_auth_data_source.dart, ../../data/datasources/node_auth_remote_data_source.dart, ../../data/repositories/auth_repository_impl.dart

### Community 3 - "Community 3"
Cohesion: 0.25
Nodes (7): AuthRepositoryImpl, Exception, UserEntity, ../datasources/firebase_auth_data_source.dart, ../datasources/node_auth_remote_data_source.dart, ../../domain/entities/user_entity.dart, ../../domain/repositories/auth_repository.dart

### Community 4 - "Community 4"
Cohesion: 0.5
Nodes (3): FirebaseAuthDataSource, dart:async, package:firebase_auth/firebase_auth.dart

## Knowledge Gaps
- **35 isolated node(s):** `MyApp`, `main`, `ProviderScope`, `build`, `MaterialApp` (+30 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:flutter_riverpod/flutter_riverpod.dart` connect `Community 1` to `Community 0`, `Community 2`?**
  _High betweenness centrality (0.350) - this node is a cross-community bridge._
- **Why does `package:firebase_auth/firebase_auth.dart` connect `Community 4` to `Community 2`?**
  _High betweenness centrality (0.100) - this node is a cross-community bridge._
- **Why does `../../domain/entities/user_entity.dart` connect `Community 3` to `Community 2`?**
  _High betweenness centrality (0.089) - this node is a cross-community bridge._
- **What connects `MyApp`, `main`, `ProviderScope` to the rest of the system?**
  _35 weakly-connected nodes found - possible documentation gaps or missing edges._