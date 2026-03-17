# Bellabeat Smart Device Usage Analysis. akan

![Project Status](https://img.shields.io/badge/Status-Complete-success)
![SQL](https://img.shields.io/badge/SQL-MySQL-blue)
![Tableau](https://img.shields.io/badge/Tableau-Dashboard-orange)

> **Google Data Analytics Professional Certificate Capstone Project**  
> Analyzing smart device fitness data to provide marketing strategy recommendations for Bellabeat, a wellness technology company for women.

---

## 📋 Table of Contents
- [Business Task](#business-task)
- [Data Source](#data-source)
- [Tools Used](#tools-used)
- [Project Deliverables](#project-deliverables)
- [Key Findings](#key-findings)
- [Recommendations](#recommendations)
- [How to Use This Repository](#how-to-use-this-repository)
- [Contact](#contact)

---

## 🎯 Business Task

**Objective**: Analyze smart device fitness data to identify consumer usage trends and provide high-level marketing recommendations to help Bellabeat grow its market presence in the global smart device market.

**Focus Product**: Bellabeat App (digital wellness platform)

**Key Questions**:
1. What are the trends in smart device usage?
2. How do these trends apply to Bellabeat customers?
3. How can these trends influence Bellabeat's marketing strategy?

---

## 📊 Data Source

**Dataset**: [FitBit Fitness Tracker Data](https://www.kaggle.com/datasets/arashnic/fitbit)  
**License**: CC0: Public Domain  
**Period**: April 12, 2016 - May 12, 2016 (31 days)  
**Sample Size**: 33 unique users  

**Tables Analyzed**:
- `dailyActivity_merged` - Daily activity metrics (steps, distance, calories, active minutes)
- `sleepDay_merged` - Sleep tracking data (time in bed, time asleep)
- `weightLogInfo_merged` - Manual weight logging records

**Data Limitations**:
- Small sample size (33 users)
- No demographic information (gender, age, location)
- Data from 2016 may not reflect current user behavior
- FitBit users may not represent Bellabeat's target audience

---

## 🛠 Tools Used

| Tool | Purpose |
|------|---------|
| **MySQL** | Data cleaning, transformation, and analysis |
| **Tableau Public** | Interactive dashboard and data visualization |
| **Microsoft Word** | Executive summary report |
| **GitHub** | Version control and project documentation |

---

## 📦 Project Deliverables

1. **SQL Analysis** ([`bellabeat_analysis.sql`](bellabeat_analysis.sql))
   - Data cleaning and validation
   - Exploratory data analysis
   - User segmentation
   - Statistical analysis

2. **Tableau Dashboard** ([View on Tableau Public](#)) ← *Add your link here*
   - 5 interactive dashboards
   - 18+ visualizations
   - Key insights and trends

3. **Executive Summary** ([`bellabeat_executive_summary.docx`](bellabeat_executive_summary.docx))
   - 6-page professional report
   - Key findings and recommendations
   - Data quality documentation

---

## 🔍 Key Findings

### 1. User Segmentation
Users were classified into three behavioral segments based on daily steps:

| Segment | Criteria | Users | Avg Steps | Avg Sedentary Minutes |
|---------|----------|-------|-----------|----------------------|
| **Fitness Enthusiasts** | ≥10,000 steps/day | 7 (21%) | 12,406 | 700 |
| **Casual Users** | 5,000-9,999 steps/day | 18 (55%) | 7,283 | 818 |
| **Beginners** | <5,000 steps/day | 8 (24%) | 3,474 | 1,019 |

**Insight**: Beginners represent the largest growth opportunity with the highest sedentary time.

---

### 2. Feature Adoption Patterns

| Feature | Adoption Rate | Users |
|---------|---------------|-------|
| **Daily Activity Tracking** | 100% | 33/33 |
| **Sleep Tracking** | 71% | 24/33 |
| **Weight Logging** | 9% | 3/33 |

**Insight**: Users strongly prefer passive tracking (automated) over manual logging features.

---

### 3. Activity Patterns by Day of Week

- **Saturday**: Highest activity (8,153 avg steps)
- **Friday**: Lowest activity (7,448 avg steps) - 9% drop
- **Weekend Effect**: 5% more active on weekends vs weekdays

**Insight**: Friday activity dip represents an engagement opportunity.

---

### 4. Sleep Quality Analysis

| Segment | Avg Hours in Bed | Avg Hours Asleep | Sleep Efficiency |
|---------|-----------------|------------------|------------------|
| **Beginners** | 10.0 | 7.2 | 72% |
| **Casual Users** | 6.9 | 6.9 | 100% |
| **Fitness Enthusiasts** | 6.4 | 6.4 | 100% |

**Insight**: Fitness Enthusiasts may be sleep-deprived (6.4 hrs < recommended 7-9 hrs).

---

### 5. Device Usage Consistency

| Segment | Avg Usage Rate | Engagement Level |
|---------|----------------|------------------|
| **Casual Users** | ~100% | Consistent |
| **Fitness Enthusiasts** | 96%+ | High |
| **Beginners** | <69% | Inconsistent |

**Insight**: Beginners show 31% lower device adherence - retention risk.

---

## 💡 Recommendations

### High Priority

| # | Recommendation | Target Segment | Rationale |
|---|----------------|----------------|-----------|
| 1 | **Movement reminder notifications** | Beginners | Address high sedentary time (1,019 min/day) and low adherence |
| 2 | **Friday motivation campaigns** | All Users | Counter 9% activity drop; push notifications, challenges |
| 3 | **Weekend fitness challenges** | All Users | Leverage natural 5% weekend activity increase |
| 4 | **Streak & reward systems** | Beginners & Casual | Gamification to increase device adherence and progression |

### Medium Priority

| # | Recommendation | Target Segment | Rationale |
|---|----------------|----------------|-----------|
| 5 | **Sleep wellness content** | Fitness Enthusiasts | Address potential sleep deprivation (6.4 hrs average) |
| 6 | **Habit-building program** | Beginners | Guide progression from <5K to 5K+ steps/day |
| 7 | **Automate weight tracking** | All Users | Only 9% adoption; integrate with smart scales |

### Low Priority

| # | Recommendation | Target Segment | Rationale |
|---|----------------|----------------|-----------|
| 8 | **Inactivity streak alerts** | Beginners | Re-engage users after 2-3 days of zero activity |
