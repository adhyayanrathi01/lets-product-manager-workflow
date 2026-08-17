---
name: analyze-query-results
description: "Interpret product-data query results and convert them into grounded findings for a PM decision. Use after receiving tables, query output, exports, experiment results, cohort data, or other structured product evidence."
---

# Analyze Query Results

## Contract

- Require the decision, result artifact, generating query or method, metric definition, grain, filters, exclusions, absolute period, and comparison.
- Verify provenance, sample size, denominator, identity mapping, freshness, and cohort maturity before interpreting.
- If provenance or a critical definition is missing, describe observable table properties but block decision-level conclusions.
- Emit the shared evidence handoff for reusable findings.

## Process

1. Read the original question, metric definition, query or method, filters, and exclusions.
2. Verify the result grain, sample size, denominators, missing values, and comparison groups.
3. Look for magnitude, direction, distribution, segments, changes over time, and meaningful anomalies.
4. Check whether the result could be explained by tracking changes, seasonality, selection bias, or small samples.
5. Separate observations from interpretations and causal hypotheses.
6. Compare with other available evidence when relevant.
7. Explain what the result changes—or does not change—about the PM’s decision.

## Output

Provide findings, confidence, limitations, plausible explanations, contradictory evidence, and decision implications. Do not overstate statistical or practical significance.
