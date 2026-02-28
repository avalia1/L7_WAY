# Patent/IP Considerations

## Potentially Patentable Inventions

### 1. Multi-Tier Confidence Matching System for Longitudinal Participant Re-identification

**Claim:** A method and system for matching incoming survey responses to historical participant records using a tiered confidence scoring algorithm that combines:
- Fuzzy name matching (Jaro-Winkler distance with nickname normalization)
- Date of birth partial matching (exact, month/year, year-only)
- Address proximity scoring (geocoded distance)
- Automated action routing based on confidence thresholds

**Novel aspects:**
- Tiered action system (auto-confirm, queue, review)
- Specific combination of features for longitudinal re-contact
- Integration with automated outreach pipeline

**Prior art to investigate:**
- Record linkage patents in healthcare
- Identity resolution systems (credit bureaus, etc.)
- Academic record linkage algorithms

---

### 2. Knowledge Graph System for Cohort Participant Relationship Tracking

**Claim:** A graph database architecture for modeling participant relationships in longitudinal studies, comprising:
- Entity nodes (participants, contact points, sources, communications)
- Typed relationship edges (HAS_CONTACT, REFERRED_BY, RECRUITED_BY)
- Temporal properties on all entities and relationships
- Query methods for relationship-aware participant lookup

**Novel aspects:**
- Application to longitudinal research
- Integration of communication history as graph edges
- Referral chain analysis for community-based recruitment
- Ambassador/community partner modeling

---

### 3. Automated Multi-Channel Outreach Pipeline for Research Re-contact

**Claim:** An automated system for participant outreach in research studies comprising:
- Workflow orchestration engine (triggering based on eligibility status changes)
- Multi-channel delivery (SMS, email, postal) with channel preference learning
- Opt-out synchronization across channels
- Compliance checking (contact frequency limits, quiet hours)
- Audit trail generation for IRB compliance

**Novel aspects:**
- Research-specific compliance features
- Integration with survey platforms (Qualtrics)
- Human-in-the-loop escalation for edge cases

---

### 4. Interactive Network Visualization for Longitudinal Study Monitoring

**Claim:** A visualization system for research study monitoring comprising:
- Force-directed graph rendering of participant networks
- Time-series animation showing network formation
- 3D navigable graph space for data exploration
- Real-time data binding to backend databases
- Click-to-detail participant information overlay

**Novel aspects:**
- Application to research participant tracking
- Combination of 2D timeline and 3D spatial exploration
- Source clustering visualization
- Coordinator-focused UX design

---

## Trade Secret Considerations

Some elements may be better protected as trade secrets rather than patents:

- Specific weight values in matching algorithm (w₁, w₂, w₃)
- Nickname normalization dictionary
- Channel preference learning model
- Ambassador effectiveness scoring

---

## Copyright

The following are copyrightable:

- Dashboard source code
- Visualization code (D3.js, Three.js implementations)
- Documentation and guides
- Book manuscript
- Research paper

**Recommendation:** Publish code under a dual license:
- Open source (MIT/Apache) for non-commercial research use
- Commercial license required for for-profit applications

---

## Trademark

Consider trademarking:

- "NC Life Study" (if not already)
- Product names for any standalone tools extracted from this work

---

## Next Steps

1. **Prior Art Search**
  - Conduct thorough patent search (Google Patents, USPTO)
  - Review academic literature on record linkage
  - Identify potential blocking patents

2. **Invention Disclosure**
  - File invention disclosure with UNC Office of Technology Commercialization
  - Document all contributors and dates of conception

3. **Provisional Patent**
  - Consider filing provisional patent application ($320 filing fee)
  - Provides 12 months to file full application
  - Establishes priority date

4. **Publication Strategy**
  - Patent before publishing (publication creates prior art)
  - Or use provisional filing to protect before paper submission

5. **Collaboration Agreement**
  - Document AI collaboration (Lapis) contribution
  - Clarify IP ownership between UNC, Alberto, and any other parties

---

## AI Collaboration IP Note

The involvement of an AI system (Lapis/OpenClaw) in developing this work raises novel IP questions:

- AI cannot be named as inventor on US patents (Thaler v. Vidal, 2022)
- Human conception and reduction to practice must be documented
- AI contributions should be characterized as "tool use" similar to other software
- Recommendation: Document that Alberto conceived inventive elements, with AI assisting in implementation

---

## Contact

UNC Office of Technology Commercialization
Phone: (919) 966-3929
Email: otc@unc.edu
Web: otc.unc.edu

---

*Document created: February 5, 2026*
*Authors: Alberto Valido Delgado, Lapis (AI assistant)*
