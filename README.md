# Azure SPA Deployment – PRODYNA Bewerbungsaufgabe

## 🧩 Überblick
Dieses Repository stellt die Umsetzung einer vollständigen DevOps-Lösung für eine Vue.js Single Page Application (SPA) und ein Node.js Backend auf Azure dar. Ziel war es, eine moderne, saubere GitOps-Pipeline mit Infrastruktur-as-Code (Terraform), Versionierung, dynamischem Deployment und CI/CD auf GitLab zu implementieren.

---

## 🏗️ Projektstruktur

```bash
.
├── backend/              # Node.js Backend mit Express & Mongoose
├── frontend/             # Vue.js SPA
├── terraform/            # Terraform-Konfiguration für Azure
├── .gitlab-ci.yml        # GitLab CI/CD Pipeline
└── README.md
```

---

## ☁️ Infrastruktur
Bereitstellung via **Terraform (OpenTofu)** mit getrennten `.tfvars`-Dateien für **dev**, **stage** und **live**.

**Provisioniert werden:**
- Azure Resource Group
- Azure Container Registry (ACR)
- Azure Linux Web App (Backend per Docker)
- Azure Static Web App (Frontend)
- Azure Key Vault (MongoDB Secret)

**Dynamische Komponenten:**
- Backend URL wird über Terraform-Output bereitgestellt
- Versionierung wird via `package.json` gelesen und automatisch in der Pipeline verwendet

---

## 🧪 CI/CD Pipeline – Übersicht

Die GitLab-CI-Pipeline ist in folgende Stages gegliedert:

- `.pre` → Versions-Erkennung aus `package.json`
- `build` → Docker Build für Backend, npm build für Frontend
- `detect` → Git-Diff & Tag-Release bei Änderungen
- `deploy` → Terraform Apply, `.env`-Erzeugung mit dynamischer Backend-URL, Azure-Deployment

### 🔄 Versionierung & Releases
- Die Version wird aus `frontend/package.json` und `backend/package.json` gelesen.
- Git-Tags wie `vfe-1.0.0-be-1.0.0` werden erstellt, wenn Änderungen vorhanden sind.
- Wenn kein Unterschied zum letzten Tag besteht, erfolgt kein neues Release/Deployment.

### 🔐 Secrets
- MongoDB URI wird in Azure Key Vault verwaltet
- CI-Variablen wie `AZURE_CLIENT_ID`, etc. sind in GitLab hinterlegt (masked + protected)

---

## 📄 Branching- & Deployment-Strategie

| Branch               | Umgebung  | Deployment     | Beschreibung                                     |
|---------------------|-----------|----------------|--------------------------------------------------|
| `main`              | dev       | automatisch     | Jeder Merge auf main triggert volles Deployment  |
| `release/stage`     | stage     | manuell         | Branch wird auf main-Commit gesetzt              |
| `release/live`      | live      | manuell         | Branch wird auf main-Commit gesetzt              |

> **Hinweis:** Auf Stage/Live erfolgt kein automatisches Image-Build, es wird nur deployed.

---

## 💡 Entscheidungsfindung / Varianten

### Warum kein reines Terraform-Deployment für die Static Web App?
Die Terraform-Ressource `azurerm_static_web_app` unterstützt keine Parameter wie `output_location` oder `app_location`. Diese sind jedoch essenziell für das Vue-Build (`dist/`). Daher habe ich das Deployment per `az staticwebapp upload` aus der CI gewählt.

### Alternativen:
- 🟥 **Nur Terraform:** nicht möglich ohne `app_location`
- 🟩 **Hybrid (gewählt):** Terraform für Ressourcen, CI/CD für Builds
- ✅ Vorteile: Build-Verzeichnis flexibel, kompatibel mit Azure CLI, CI-Flow besser kontrollierbar

### Monorepo vs. Multi-Repo
- 🔧 In diesem Projekt wurde ein Monorepo gewählt, um die Komplexität gering zu halten.
- ✅ In größeren, produktiven Umgebungen würde ich jedoch  empfehlen, **Frontend und Backend getrennt zu versionieren und zu deployen** (Multi-Repo-Ansatz), um:
  - Deployments unabhängig zu machen
  - Releases granular steuern zu können
  - Repositories leichter wartbar und skalierbar zu halten

### Terraform Module & GitLab CI Components
- 🧱 In produktiven Systemen würde ich statt Einzeldateien, **wiederverwendbare Terraform Module** nutzen, z. B. für Netzwerke, App Services, Monitoring etc.
- 🔁 Auch die GitLab CI/CD kann über **CI Components / Templates** modularisiert werden – z. B. für einheitliches Versioning oder Releasemanagement über Projekte hinweg.

---

## ✅ Ergebnis

- 🔧 Dynamische Umgebungen (`dev`, `stage`, `live`)
- 📦 Docker-basierter Backend-Deploy auf Azure App Service
- 🌐 Frontend als Azure Static Web App
- 🔄 Automatische Versionierung & Git-Release mit Tags
- 🔐 Sichere Secret-Verwaltung über Key Vault + Identity

---

## 🧪 Lokale Entwicklung
```bash
cd frontend
npm install
npm run serve

cd ../backend
npm install
node src/index.js
```