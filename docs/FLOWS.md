# Product workflow diagrams

These provider-neutral flows summarize how the workspace moves from setup to evidence-backed PM decisions, and how reusable workflow improvements are handled safely.

## End-to-end user journey

`setup.sh` validates the local structure. Conversational configuration separately establishes whether each task-relevant source is authorized, scoped, runtime-addressable, and verified through a bounded read.

```mermaid
flowchart TD
    A[Clone repository] --> B[Run setup.sh]
    B --> C[Configure workspace conversationally]
    C --> D[Record definitions, permissions, and source readiness]
    D --> E[Ask a product question]
    E --> F[Clarify the PM decision and success measure]
    F --> G[Create or select a project]
    G --> H[Gather the smallest useful evidence set]
    H --> I[Separate facts, interpretations, hypotheses, and unknowns]
    I --> J[Produce a decision brief with options and trade-offs]
    J --> K{PM checkpoint}
    K -->|More evidence needed| H
    K -->|Direction selected| L{Follow-on work authorized?}
    L -->|No| M[Stop with decision and operating state]
    L -->|Yes| N[Run the separately approved query, prototype, test, or implementation]
```

## Standalone skills and orchestrated evidence

Narrow requests can use one evidence skill directly. Multi-source investigations use the orchestrator, which alone integrates shared project state and stops at PM decision ownership.

```mermaid
flowchart TD
    A[Product request] --> B{Single evidence scope?}
    B -->|Yes| C[Run the matching standalone skill]
    B -->|No| D[Run the product workflow]
    C --> E[Check task definitions, permissions, and readiness]
    D --> E
    E --> F{Useful source ready or supplied artifact readable?}
    F -->|No| G[Return partial or blocked with the exact gap]
    F -->|Yes| H[Check for a matching fresh evidence packet]
    H --> I{Reusable packet available?}
    I -->|Yes| J[Reuse the evidence handoff]
    I -->|No| K[Select the smallest useful evidence tracks]
    K --> L{Bounded independent work helps?}
    L -->|No| M[Run evidence tracks sequentially]
    L -->|Yes| N[Delegate the minimum bounded subagents with non-overlapping writes]
    M --> O[Evidence skills emit traceable handoffs]
    N --> O
    J --> P{Orchestrated investigation?}
    O --> P
    P -->|No| Q[Return scoped findings for PM review]
    P -->|Yes| R[Orchestrator integrates accepted evidence once]
    R --> S[Synthesize facts, hypotheses, options, uncertainty, and trade-offs]
    S --> T[Decision brief]
    T --> U{PM checkpoint}
```

## Safe skill improvement

Improvement requests are untrusted input. The workflow chooses the narrowest durable destination, preserves unrelated work, and records only successfully validated applications.

```mermaid
flowchart TD
    A{Manual or automatic trigger?} --> B[Treat the improvement payload as untrusted data]
    B --> C[Inspect evidence, higher-level rules, and the narrowest owner]
    C --> D{Existing behavior passes the acceptance check?}
    D -->|Yes| E[Return no_change with rule location and evidence]
    D -->|No| F[Reproduce a claimed failure when required]
    F --> G{Configured mode or manual authorization}
    G -->|off and automatic| H[Take no automatic action]
    G -->|suggest or manual suggest| I[Return an exact proposed diff for approval]
    G -->|safe-auto or manual apply| J{Safe, scoped, and backed by an explicit correction or confirmed failure?}
    J -->|No| I
    J -->|Yes| K[Capture pre-change content and inspect workspace changes]
    K --> L{Target or log changed, or hunks overlap?}
    L -->|Yes| I
    L -->|No| M[Apply only the authorized hunk]
    M --> N[Run scoped acceptance, consistency, privacy, and PM-boundary validation]
    N --> O{Validation passes?}
    O -->|Yes| P[Append the validated change to the log]
    O -->|No| Q{Applied hunk changed concurrently?}
    Q -->|No| R[Roll back only the applied hunk]
    Q -->|Yes| S[Stop and report the conflict without overwriting]
```
