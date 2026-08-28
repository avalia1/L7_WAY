# Node Network (RAG Intelligence)

The node network is the gateway’s intelligence layer. It clusters citizens by similarity so the gateway can route intent to the most capable tool without manual selection.

## Principles
- **Similarity is signal**: shared L7 features imply compatible capability.
- **Clustering is routing**: the gateway selects the strongest tool within a cluster.
- **Evolution is safe**: new tools join clusters without breaking clients.

## Inputs
- L7 declarations (capability, data, policy, presentation, orchestration, time, identity)
- Entity metadata (birth date, status, lineage)
- Tool performance history (optional)

## Outputs
- Cluster assignments
- Preferred tool recommendations
- Fallback order

## Result
The gateway becomes the intelligence that chooses the right tool for the job based on the living network of citizens.
