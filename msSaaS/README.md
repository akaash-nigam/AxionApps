# MicroSaaS Applications Portfolio

A collection of 28 full-stack SaaS applications deployed on Google Cloud Run with PostgreSQL databases.

## 📌 Project Overview

- **Total Applications**: 28
- **Successfully Deployed**: 24 (85.7%)
- **Technology Stack**: React + Node.js + Express + PostgreSQL + Cloud Run
- **Deployment Date**: December 2024
- **Project Status**: Production Ready

## 🎯 Quick Start

### Prerequisites
- Google Cloud SDK installed
- Node.js 18+ installed
- Access to GCP project `microsaas-projects-2024`

### Accessing Deployed Apps

All deployed applications are live at:
```
https://<service-name>-1022196473572.us-central1.run.app
```

See [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) for complete list of URLs.

### Local Development

```bash
# Navigate to any app
cd msSAAS_<AppName>

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your credentials

# Start development server
npm run dev
```

## 📚 Documentation

- **[QUICK_REFERENCE.md](./QUICK_REFERENCE.md)** - Quick access links, common commands, deployment fixes
- **[DEPLOYMENT_DOCUMENTATION.md](./DEPLOYMENT_DOCUMENTATION.md)** - Complete deployment guide, troubleshooting, architecture

## 🚀 Deployed Applications

### Production-Ready Apps (24)

All applications live and accessible. See QUICK_REFERENCE.md for URLs.

## 💻 Technology Stack

### Frontend
- React 18.3 + TypeScript + TailwindCSS + Vite

### Backend
- Node.js 18 + Express.js + Drizzle ORM + PostgreSQL

### Infrastructure
- Google Cloud Run + Cloud SQL + Cloud Build + Docker

## 🔐 Security

All applications implement: HTTPS, Helmet, Rate Limiting, CSRF Protection, Input Validation, SQL Injection Prevention, XSS Protection, Authentication

## 💰 Cost Breakdown

**Monthly Estimated**: ~$15-160/month (depending on traffic)
- Cloud Run: $0-120/month (scale-to-zero)
- Cloud SQL: $15-30/month
- Cloud Build: $0-10/month

## 📞 Support

- **Project Owner**: Aakash Nigam (nigam.akaash@gmail.com)
- **GCP Project**: microsaas-projects-2024

---

**Last Updated**: December 13, 2024

For detailed information:
- [DEPLOYMENT_DOCUMENTATION.md](./DEPLOYMENT_DOCUMENTATION.md) - Complete guide
- [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) - Quick commands & URLs
