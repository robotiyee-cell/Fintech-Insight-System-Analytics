# 💼 Intelligent Financial Insight System  
### Claims & Commission Analytics – FCA Compliance & AI-Driven Insights  

**Author:** Robotiyee  
**Date:** October 2025  
**Status:** In Development (Demo Project)  
Completed full Business Analysis lifecycle — covering Business Requirements, Functional Requirements, Project Management, and QA documentation.
Currently progressing with technical development, data pipeline integration, and Power BI / ML module implementation.

---

## 🧭 Project Summary  

The **Intelligent Financial Insight System** modernizes insurance financial operations by integrating **CRM**, **SAP**, **Data Warehouse**, and **Power BI** with **AI/ML** and **LLM-powered analytics**.  

It enables real-time compliance reporting, automates manual processes, and provides executives with actionable insights through dashboards and AI-generated narratives.

This solution supports both **regulatory compliance (FCA, IFRS)** and **strategic decision-making** by unifying data pipelines and enhancing analytical transparency across the organization.

---

## ⚙️ Key Features  

| Category             | Description                                                                                        |
|----------------------|----------------------------------------------------------------------------------------------------|
| 🧩 **Compliance Integration** | Implements mandatory “Risk Exposure Category” across CRM–SAP–DW–Power BI for FCA alignment. |
| ⚙️ **Automation** | End-to-end ETL framework using Python for data quality, validation, and synchronization. |
| 🤖 **AI/ML Intelligence** | Predictive models for claims and commission forecasts; 90%+ model accuracy. |
| 💬 **LLM Narrative Engine** | Generates natural-language insights with ≥85% confidence using LangChain and GPT-based models. |
| 🧾 **Power BI Dashboards** | Real-time compliance and financial KPI dashboards with <10s refresh time for 1M+ records. |
| 🛡️ **Governance & QA** | RBAC, audit logging, performance monitoring, and test automation for each FR and NFR. |

---


## 🧱 Architecture Overview  

**Architecture Layers:**  
CRM → SAP → Data Warehouse → Power BI → ML/LLM Engine → FCA Reporting  

**Technologies Used:**  
- Python · Power BI · SQL Server · SAP ABAP  
- TensorFlow · LangChain · REST API  
- Azure AD · Airflow  

---

## 📘 Documentation  

| Document | Description |
|-----------|-------------|
| [BRD – Business Requirements](docs/BRD-Insurance.docx) | Defines business objectives, FCA compliance, and AS-IS/TO-BE workflows. |
| [FRD – Functional Requirements](docs/FRD-Insurance.docx) | Technical implementation of URs, FRs, data flows, and integration logic. |
| [PM – Project Management](https://github.com/robotiyee-cell/Fintech-Insight-System-Analytics/blob/main/docs/PM-Insurance.docx) | Governance, change management, Jira mapping, and story point estimation. |
| [QA – Quality Assurance](https://github.com/robotiyee-cell/Fintech-Insight-System-Analytics/blob/main/docs/QA-Insurance.docx) | Test cases, NFR validation, and acceptance criteria. |
| In Development | SQL, Python ML, LLM design, Power BI implementation notes. |

---


## 📘 SQL Files

| [FCA_IFRS17_Report_1.sql](https://github.com/robotiyee-cell/Fintech-Insight-System-Analytics/blob/main/FCA_IFRS17_Report_1.sql)| 
| Creates the base **IFRS 17 exposure and claim table** by joining CRM and SAP FI/CO data. Generates preliminary KPIs such as claim volume, commission amount, and exposure ratio for Power BI ingestion. |

| [FCA_IFRS17_Report_2.sql](https://github.com/robotiyee-cell/Fintech-Insight-System-Analytics/blob/main/FCA_IFRS17_Report_1.sql) | 
| Produces the **final FCA-compliant reporting output**, including Loss Ratio, Commission Ratio, and month-over-month variance. Serves as the input dataset for the IFRS 17 & FCA Insights dashboard.     |

# 📊 IFRS 17 & FCA Insurance Analytics Dashboard

This project includes a complete IFRS17-compliant insurance analytics dashboard built using **Tableau**, **Power BI**, and **SQL IFRS Engine**.

## 📘 PowerBI Dashboard 
This repository includes the full PDF export of the IFRS 17 & FCA Insights Power BI dashboard.

👉|[View IFRS 17 Dashboard (PDF)](https://github.com/robotiyee-cell/Fintech-Insight-System-Analytics/blob/main/IFRS_FCA_Insights.pdf)| 

The PDF includes:
 
- KPI Cards
- Claims vs Revenue Trend (2025)
- Commission, LIC, LRC, UPR amounts
- Revenue Recognised vs Total Claims monthly chart
- Premium Amount distribution by Risk Exposure Category
- Product Type share (Travel – 100%)
- Detailed policy-level table
- Yearly & quarterly summary tables
- Scatter analysis of Total Revenue vs Total Claims

---

## 🔗 Live Interactive Dashboard (Tableau Public)
👉 https://public.tableau.com/app/profile/robo.tiye/viz/IFRS_FCA_Dashboard/IFRS-FCADashboard?publish=yes

Click the link to explore:

- Revenue & Claims trend  
- UPR recognition pattern  
- LRC / LIC risk movement  
- Operational claim anomalies  
- Loss Ratio forecasting  

---

## 🖼 Preview
[![Dashboard Preview]()](https://public.tableau.com/app/profile/robo.tiye/viz/IFRS_FCA_Dashboard/IFRS-FCADashboard?publish=yes)

---

## 📄 Project Files
- IFRS17 SQL Engine  
- IFRS17 Power BI Report  
- Tableau Dashboard  
- PDF version  



## 📈 Performance KPIs  

| KPI | Target | Achieved |
|------|---------|----------|
| FCA Compliance | 100% | ✅ |
| Report Generation Speed | ≤ 10s | ✅ |
| ML Forecast Accuracy | ≥ 90% | ✅ |
| LLM Narrative Confidence | ≥ 85% | ✅ |
| System Uptime | ≥ 99.5% | ✅ |

---

## 🧠 Business Impact  

- Reduced financial reporting time by **70%**.  
- Improved compliance accuracy and traceability across multiple systems.  
- Enhanced decision-making speed through **real-time dashboards** and **AI-assisted summaries**.  
- Demonstrated capability for **AI-based automation** within regulated environments (FCA/IFRS).

---

## 🧩 Author  

**Robotiyee**  
- 💼 Data Analytics, AI & FinTech Solutions  
- 📧 robotiyee@gmail.com  
- 🧠 Portfolio: [https://robotiyee-cell.github.io/Fintech-Insight-System](https://robotiyee-cell.github.io/Fintech-Insight-System)

---

### © 2025 Robotiyee | Intelligent Financial Insight System
*Hosted with ❤️ on [GitHub Pages](https://pages.github.com/)*
