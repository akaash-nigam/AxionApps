# msSaaS Portfolio

**Comprehensive collection of 66 micro-SaaS applications spanning multiple markets and industries.**

---

## 📊 Portfolio Overview

- **Total Projects**: 66 SaaS applications
- **Markets**: India (.in), Canada (.ca), United States (.com), Global (.pro, .ai)
- **Tech Stack**: React, Node.js, TypeScript, Express, PostgreSQL, MongoDB
- **Infrastructure**: Docker, Google Cloud Run, Stripe payments
- **Status**: Production-ready with standardized architecture

---

## 🗂️ Directory Structure

```
msSaaS/
├── msSaaS_*/                   # 66 SaaS applications (standardized naming)
├── infrastructure/              # Shared infrastructure and tools
│   ├── branding/               # Brand assets and guidelines
│   ├── stripe/                 # Payment integration (scripts, docs, price IDs)
│   ├── templates/              # Project templates and boilerplates
│   └── terraform/              # Infrastructure as code
├── categories/                  # Market and domain-specific resources
│   ├── canadian/               # Canadian market projects
│   └── gaming/                 # Gaming applications
├── planning/                    # Project planning and backlog
├── personal/                    # Personal projects (non-SaaS)
├── documentation/               # Portfolio-wide documentation
├── scripts/                     # Automation and deployment scripts
└── docs/                        # Generated documentation and landing pages
```

---

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- Docker Desktop
- Google Cloud SDK (for deployment)
- PostgreSQL or MongoDB (depending on project)

### Running a Project Locally

```bash
# Navigate to any project
cd msSaaS_[project-name]

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your configuration

# Run development server
npm run dev

# Build for production
npm run build
```

### Common Commands

```bash
# Run tests
npm test

# Type checking
npm run check

# Database migrations
npm run db:push        # Drizzle ORM projects
npm run db:migrate     # Prisma projects

# Docker build
docker build -t [project-name]:latest .

# Deploy to Google Cloud Run
gcloud run deploy [service-name] --image gcr.io/[project-id]/[project-name]
```

---

## 📁 Project Categories

See [PROJECT_INDEX.md](./PROJECT_INDEX.md) for a complete categorized list of all 66 projects.

### By Market
- **Indian Market (.in)**: 12 projects
- **Canadian Market (.ca)**: 8 projects
- **US/Global (.com)**: 38 projects
- **Professional (.pro, .ai)**: 8 projects

### By Industry
- **AI/ML Tools**: 15 projects
- **Business Tools**: 18 projects
- **Education**: 6 projects
- **Healthcare/Wellness**: 5 projects
- **Finance/Fintech**: 7 projects
- **Content Creation**: 8 projects
- **Other**: 7 projects

---

## 🏗️ Infrastructure

### Stripe Integration
All projects use standardized Stripe integration for payments:
- Location: `infrastructure/stripe/`
- Scripts: Product creation, price management
- Documentation: Setup guides, testing procedures
- Price IDs: Centralized pricing configuration

### Deployment
- **Platform**: Google Cloud Run (serverless containers)
- **CI/CD**: Google Cloud Build
- **Registry**: Google Container Registry
- **Monitoring**: Cloud Run metrics + custom health checks

### Security
- Rate limiting (express-rate-limit)
- Security headers (Helmet.js)
- CORS protection
- Environment-based configuration
- Session management
- Input validation (Zod schemas)

---

## 📚 Documentation

### Portfolio Documentation
- [PROJECT_INDEX.md](./PROJECT_INDEX.md) - Complete project catalog
- [REORGANIZATION_REPORT.md](./REORGANIZATION_REPORT.md) - Portfolio restructuring details
- [LEGACY_PROJECTS_ANALYSIS.md](./LEGACY_PROJECTS_ANALYSIS.md) - Legacy project migration
- [LINKHUB_ANALYSIS.md](./LINKHUB_ANALYSIS.md) - LinkHub cleanup details

### Infrastructure Documentation
- [infrastructure/stripe/documentation/](./infrastructure/stripe/documentation/) - Payment integration
- [infrastructure/templates/](./infrastructure/templates/) - Project templates
- [infrastructure/terraform/](./infrastructure/terraform/) - Infrastructure as code

### Project-Specific Documentation
Each project contains:
- `README.md` - Project overview and setup
- `PRD.md` - Product requirements (if applicable)
- `docs/` - API documentation, user guides, etc.

---

## 🛠️ Scripts

### Maintenance Scripts
Located in `scripts/maintenance/`:
- `reorganize_legacy_projects.sh` - Portfolio reorganization
- `standardize_naming.sh` - Naming convention standardization

### Testing Scripts
Located in `scripts/testing/`:
- `quick-test-linkhub.sh` - Stripe integration testing

### Deployment Scripts
See individual projects for deployment scripts.

---

## 🎯 Naming Convention

All projects follow the standardized naming pattern:
```
msSaaS_[project-name]
```

**Important**: Lowercase `msSaaS_` (not `msSAAS_`)

Examples:
- ✅ `msSaaS_adcreatorpro.com`
- ✅ `msSaaS_comparegenius.pro`
- ❌ `msSAAS_ProjectName` (old format, now deprecated)

---

## 🔐 Environment Variables

Common environment variables across projects:

```bash
# Database
DATABASE_URL=postgresql://user:password@host:5432/dbname
# or
MONGODB_URI=mongodb://user:password@host:27017/dbname

# Security
SESSION_SECRET=your-secret-key-here
NODE_ENV=development|production

# Payment (Stripe)
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Google Cloud
GOOGLE_CLOUD_PROJECT=your-project-id
GCP_REGION=us-central1

# CORS
ALLOWED_ORIGINS=https://yourdomain.com

# Rate Limiting
RATE_LIMIT_MAX=100
RATE_LIMIT_WINDOW=900000
```

---

## 📊 Project Status

### Production Ready
- Full test coverage (>80%)
- Security hardening complete
- Docker images built
- Documentation complete
- Deployment tested

### Beta/Development
- Core features implemented
- Testing in progress
- Documentation in progress

### Planning
- See `planning/webapp_backlog/` for upcoming projects

---

## 🚢 Deployment Workflow

### Standard Deployment Process

1. **Local Development**
   ```bash
   npm run dev
   npm test
   npm run build
   ```

2. **Build Docker Image**
   ```bash
   docker build -t gcr.io/[project-id]/[app-name]:latest .
   # or use Cloud Build
   gcloud builds submit --tag gcr.io/[project-id]/[app-name]:latest
   ```

3. **Deploy to Cloud Run**
   ```bash
   gcloud run deploy [service-name] \
     --image gcr.io/[project-id]/[app-name]:latest \
     --region us-central1 \
     --platform managed \
     --allow-unauthenticated \
     --set-env-vars "NODE_ENV=production,DATABASE_URL=..."
   ```

4. **Verify Deployment**
   ```bash
   curl https://[service-url]/api/health
   ```

---

## 🤝 Contributing

### Adding a New Project

1. Create project directory:
   ```bash
   mkdir msSaaS_[project-name]
   cd msSaaS_[project-name]
   ```

2. Use project template:
   ```bash
   cp -r ../infrastructure/templates/source/* .
   ```

3. Update project details:
   - Edit `package.json`
   - Update `README.md`
   - Configure environment variables

4. Add to PROJECT_INDEX.md

### Code Standards
- TypeScript strict mode enabled
- ESLint + Prettier configured
- 80%+ test coverage required
- Security best practices enforced

---

## 📈 Portfolio Statistics

- **Total Lines of Code**: ~2M+ across all projects
- **Total Dependencies**: 344+ npm packages (average per project)
- **Deployment Size**: Average 386MB per project
- **Cloud Infrastructure**: Google Cloud Platform
- **Active Development**: Continuous updates and improvements

---

## 🔗 Resources

### Documentation
- [Google Cloud Run Docs](https://cloud.google.com/run/docs)
- [Stripe API Reference](https://stripe.com/docs/api)
- [React Documentation](https://react.dev/)
- [Express.js Guide](https://expressjs.com/)

### Internal Resources
- Stripe Dashboard: `infrastructure/stripe/`
- Project Templates: `infrastructure/templates/`
- Terraform Configs: `infrastructure/terraform/`

---

## 📞 Support

For issues or questions:
1. Check project-specific README.md
2. Review documentation in `docs/`
3. Check infrastructure guides in `infrastructure/`

---

## 📝 License

Individual projects may have their own licenses. Check each project's LICENSE file.

---

## 🤖 Generated Documentation

This portfolio was organized and documented with assistance from [Claude Code](https://claude.com/claude-code).

**Last Updated**: 2025-12-28
**Portfolio Version**: 2.0.0 (Post-reorganization)
**Total Projects**: 66
