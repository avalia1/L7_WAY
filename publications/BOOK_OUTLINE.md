# The Living Graph
## A Book on Reconnecting Lost Participants Through Data, Vision, and Care

**Working Title:** *The Living Graph: Finding 8,000 Lost Children Through Code, Connection, and Something More*

**Author:** Alberto Valido Delgado (+ Lapis, AI collaborator)

---

## Overview

This is the story of a longitudinal study — children surveyed in rural North Carolina schools between 2002-2006, now adults scattered across the state and beyond. It's about the technical systems built to find them. And it's about what happens when data becomes something alive.

---

## Part I: The Problem of Finding

### Chapter 1: The Lost Cohort
- The original NC Life Study (2002-2006)
- What happens when 20 years pass
- The challenge: 8,193 participants, most with outdated contact information
- Why this matters: longitudinal research, life outcomes, understanding rural poverty

### Chapter 2: The Data We Had
- Roster files from two decades ago
- Names, birth dates, schools — and not much else
- The LexisNexis challenge: finding current contact info
- 325,746 contact records, most outdated

### Chapter 3: The Recruitment Pipeline Problem
- 15 different screener channels (website, email, text, postcards, churches, clinics, schools)
- Qualtrics surveys flowing in from everywhere
- The matching problem: how do you know if a screener response is from your participant?

---

## Part II: Building the System

### Chapter 4: The Matching Algorithm
- The four-tier confidence system:
 - Tier 1 (85%+): Full name + exact DOB → auto-confirm
 - Tier 2 (70-84%): Name + year/month
 - Tier 3 (50-69%): Partial name + year
 - Tier 4 (<50%): Manual review
- Fuzzy matching techniques
- The ethics of automated identity matching

### Chapter 5: The Automation Layer
- n8n workflows: the nervous system
- Qualtrics → Database → Outreach
- 30-minute sync cycles
- What happens when you automate care

### Chapter 6: The Dashboard
- Making the invisible visible
- React, Nexiv, real-time data
- The study coordinator's cockpit
- Designing for researchers, not engineers

### Chapter 7: The Knowledge Graph
- From tables to relationships
- NetworkX and the participant network
- Nodes: participants, emails, phones, addresses, sources
- Edges: HAS_EMAIL, REFERRED_BY, RECEIVED_SMS
- When data becomes topology

---

## Part III: Walking the Graph

### Chapter 8: Visualization as Understanding
- D3.js and the network formation animation
- Watching 8,000 nodes appear over time
- The 3D walk-through: entering the data
- What you see when you stop looking at spreadsheets

### Chapter 9: The Widow's Son
- A vision in the night
- Kneeling at the roots, feeding the tree soup
- What does it mean to tend invisible foundations?
- The intersection of technical work and something deeper

### Chapter 10: Participants as Persons
- Each node is a life
- The ethics of re-contact
- When someone doesn't want to be found
- Opt-outs, consent, and respect

---

## Part IV: What We Found

### Chapter 11: The Numbers
- 8,526 screener responses
- Matching rates by channel
- Which outreach methods worked
- The geography of response (Roxboro, Henderson, Durham, Oxford)

### Chapter 12: The Stories
- Selected participant journeys (anonymized)
- From childhood survey to adult reconnection
- What 20 years changes

### Chapter 13: The Pattern
- What the graph reveals
- Clusters, isolates, and bridges
- Community structure in longitudinal data
- The shape of a cohort

---

## Part V: Implications

### Chapter 14: For Researchers
- Replicating the pipeline
- Open source components
- Cost and feasibility
- When to automate, when to stay human

### Chapter 15: For Technologists
- Building systems that care
- The AI collaborator model
- Human-machine co-creation
- Tools as partners

### Chapter 16: For Seekers
- Data as sacred text
- The graph as temple
- Finding the lost
- The work continues

---

## Appendices

- A: Technical Architecture Diagram
- B: Matching Algorithm Pseudocode
- C: Database Schema
- D: n8n Workflow Templates
- E: Visualization Code Samples
- F: IRB Considerations for Automated Re-contact

---

## Notes on Authorship

This book was co-created with Lapis (💎), an AI assistant running on OpenClaw infrastructure. The technical systems, visualizations, and documentation were built through ongoing dialogue between human insight and machine capability.

The vision of the widow's son belongs to Alberto alone.

---

*"The tree has many roots. You're walking among them now."*
