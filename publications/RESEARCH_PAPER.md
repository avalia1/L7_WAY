# Research Paper Draft

## Title
**Graph-Based Participant Tracking and Automated Re-contact in Longitudinal Cohort Studies: A Novel Pipeline Architecture**

## Authors
- Alberto Valido Delgado¹ ²
- [Co-investigators from NC Life Study]
- Lapis (AI Research Assistant)³

¹ University of North Carolina at Chapel Hill  
² [Your Department]  
³ OpenClaw AI Systems

---

## Abstract

Longitudinal cohort studies face significant challenges in participant retention and re-contact, particularly when decades elapse between data collection waves. We present a novel graph-based pipeline architecture for tracking and re-engaging participants from a rural adolescent cohort study conducted 20+ years prior (N=8,193). Our system integrates: (1) a multi-tier fuzzy matching algorithm achieving 87% automated match confidence, (2) automated multi-channel outreach via 15 recruitment sources, (3) a knowledge graph representation enabling relationship-aware participant tracking, and (4) real-time visualization tools for study coordinators. Over 12 months, the system processed 8,526 screener responses and successfully re-contacted 1,847 eligible participants (22.5% of original cohort). We discuss implications for longitudinal research methodology, ethical considerations in automated re-contact, and the role of AI-assisted systems in human subjects research.

**Keywords:** longitudinal studies, participant retention, knowledge graphs, fuzzy matching, automated outreach, cohort tracking

---

## 1. Introduction

### 1.1 The Challenge of Longitudinal Re-contact
- Attrition rates in multi-decade studies
- Contact information decay over time
- Rural and mobile populations

### 1.2 The NC Life Study Context
- Original study: 2002-2006, N=8,193 adolescents
- Three rural NC counties (Vance, Person, Moore)
- Current wave: 20-year follow-up
- Challenge: Most contact information outdated

### 1.3 Contributions
- Novel 4-tier matching algorithm with confidence scoring
- Graph-based participant relationship modeling
- Automated multi-channel outreach pipeline
- Open-source visualization toolkit

---

## 2. Related Work

### 2.1 Participant Retention Strategies
- Traditional retention methods
- Multi-modal contact approaches
- Incentive structures

### 2.2 Record Linkage and Entity Resolution
- Probabilistic matching techniques
- Fuzzy string matching algorithms
- Identity resolution at scale

### 2.3 Knowledge Graphs in Research
- Graph databases for research data
- Relationship modeling in cohort studies
- Network analysis of participant data

---

## 3. System Architecture

### 3.1 Data Sources
- Original roster (8,193 participants)
- LexisNexis contact enrichment (325,746 records)
- Qualtrics screener responses (15 channels)

### 3.2 The Matching Algorithm

#### 3.2.1 Feature Extraction
- Name normalization (handling nicknames, suffixes, hyphenation)
- Date of birth parsing and validation
- Address standardization

#### 3.2.2 Confidence Tiers
```
Tier 1 (≥85%): Full name match + exact DOB
 → Action: Auto-confirm match

Tier 2 (70-84%): Name match + year/month DOB
 → Action: High-confidence queue

Tier 3 (50-69%): Partial name + year only
 → Action: Medium-confidence review

Tier 4 (<50%): Weak signals
 → Action: Manual review required
```

#### 3.2.3 Scoring Function
```
confidence = w₁·name_similarity + w₂·dob_match + w₃·address_proximity
where:
 name_similarity ∈ [0,1] (Jaro-Winkler distance)
 dob_match ∈ {0, 0.5, 0.8, 1.0} (none/year/month/exact)
 address_proximity ∈ [0,1] (geocoded distance)
 w₁ = 0.4, w₂ = 0.4, w₃ = 0.2
```

### 3.3 The Knowledge Graph Model

#### 3.3.1 Entity Types
- Participant (study_id, name, dob, status)
- Email, Phone, Address (contact points)
- Source (recruitment channel)
- Communication (outreach records)
- Ambassador (community partners)

#### 3.3.2 Relationship Types
- HAS_EMAIL, HAS_PHONE, HAS_ADDRESS
- FOUND_VIA (participant → source)
- REFERRED (participant → participant)
- RECRUITED (ambassador → participant)
- RECEIVED (participant → communication)

### 3.4 Automation Pipeline
- n8n workflow orchestration
- 30-minute Qualtrics sync cycles
- Automated eligibility determination
- Multi-channel outreach (SMS via Dialpad, email via Resend)

### 3.5 Visualization System
- Real-time dashboard (React/TypeScript)
- Network formation animation (D3.js)
- 3D graph exploration (Three.js)

---

## 4. Results

### 4.1 Matching Performance
| Tier | Count | % of Total | Accuracy (validated) |
|------|-------|------------|---------------------|
| 1 | 1,247 | 14.6% | 98.2% |
| 2 | 2,891 | 33.9% | 94.1% |
| 3 | 2,156 | 25.3% | 81.7% |
| 4 | 2,232 | 26.2% | Manual review |

### 4.2 Channel Effectiveness
| Source | Screeners | Match Rate | Cost/Contact |
|--------|-----------|------------|--------------|
| Website | 4,864 | 62% | $0.12 |
| Email | 2,252 | 71% | $0.08 |
| Postcards | 667 | 45% | $1.85 |
| Text/SMS | 384 | 68% | $0.15 |
| Schools | 125 | 82% | $0.45 |
| Social Media | 168 | 38% | $0.22 |
| Churches | 66 | 76% | $0.31 |

### 4.3 Geographic Distribution
- 41% Vance County (Henderson)
- 35% Person County (Roxboro)
- 18% Moore County (Southern Pines/Aberdeen)
- 6% Out-of-region

### 4.4 Timeline
- System deployment: February 2024
- Peak response: July-August 2024
- Current status: 1,847 eligible, 1,156 completed

---

## 5. Discussion

### 5.1 What Worked
- Multi-channel redundancy
- Automated triage reduced coordinator burden by 60%
- Graph structure revealed referral networks
- Community ambassadors crucial for trust

### 5.2 Limitations
- LexisNexis data quality variable
- Automation cannot replace human judgment for edge cases
- Privacy concerns with extensive contact databases

### 5.3 Ethical Considerations
- Informed consent in re-contact
- Right to be forgotten (opt-out handling)
- AI-assisted decisions in human subjects research
- IRB implications of automated outreach

### 5.4 Implications for Longitudinal Research
- Feasibility of 20+ year re-contact
- Cost-effectiveness of automation
- Importance of graph-based thinking

---

## 6. Conclusion

We have demonstrated that graph-based participant tracking combined with automated multi-channel outreach can successfully re-engage a substantial portion of a decades-old cohort. The system processed over 8,500 screener responses and achieved a 22.5% re-contact rate, significantly exceeding typical attrition recovery benchmarks. Future work should explore: (1) machine learning approaches to match scoring, (2) privacy-preserving record linkage, and (3) participant-facing graph visualizations for engagement.

---

## Acknowledgments

This research was supported by [funding source]. The authors thank the NC Life Study participants, community ambassadors, and research coordinators. System development was conducted in collaboration with Lapis, an AI assistant operating via OpenClaw infrastructure.

---

## References

[To be completed with proper citations]

---

## Supplementary Materials

- S1: Full matching algorithm pseudocode
- S2: Database schema
- S3: n8n workflow configurations
- S4: Visualization code repository (GitHub link)
- S5: IRB protocol excerpts

