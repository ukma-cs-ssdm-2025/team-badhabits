# Railway Deployment - Wellity Backend

## Production Environment

**Deployment Date:** 2025-10-26
**Platform:** Railway.app
**Region:** Europe West (europe-west4)
**Status:** ✅ Active (Always On)

---

## Deployment Information

### Service Details

```
Project Name:   wellity-backend
Service ID:     fa22aaf2-b94c-4162-88cd-1c7852511a5b
Project ID:     5f01f6cd-f6fa-44b4-b409-a7139565d658
Workspace:      avdieienkodmytro's Projects
```

### URLs

**Production API:**
```
https://wellity-backend-production.up.railway.app
```

**API Documentation:**
```
https://wellity-backend-production.up.railway.app/api-docs
```

**Health Check:**
```
https://wellity-backend-production.up.railway.app/health
```

---

## Configuration

### Environment Variables

| Variable | Value | Description |
|----------|-------|-------------|
| `NODE_ENV` | `production` | Node.js environment |
| `PORT` | `8080` | Server port |

### Build Configuration

**Source Directory:** `src/backend`
**Build Command:** `npm ci --only=production`
**Start Command:** `node app.js` (from Procfile)
**Builder:** Nixpacks (Railpack 0.9.2)
**Node Version:** 22.21.0

---

## Deployment Settings

### Always On Configuration

- **Serverless Mode:** Disabled
- **Cold Starts:** None (always active)
- **Auto-Scaling:** Enabled
- **Region:** europe-west4 (Belgium)

### Resource Limits

- **CPU:** 2 vCPU (default)
- **Memory:** 1 GB (default)
- **Restart Policy:** On Failure (max 10 retries)

---

## API Endpoints

### Available Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check endpoint |
| `/api-docs` | GET | Swagger API documentation |
| `/` | GET | API info and endpoints list |
| `/api/v1/adaptive/recommend` | POST | Generate adaptive workout recommendation |
| `/api/v1/payments/subscribe` | POST | Process subscription payment |
| `/api/v1/analytics/trainer/:id` | GET | Get trainer analytics |
| `/api/v1/workouts/:id/verify` | POST | Verify workout quality |
| `/api/v1/recommendations/recovery` | POST | Get recovery recommendations |

---

## Monitoring & Logs

### View Logs

```bash
railway logs
```

### View Service Status

```bash
railway status
```

### View Metrics

Access Railway dashboard:
```
https://railway.com/project/5f01f6cd-f6fa-44b4-b409-a7139565d658
```

---

## Deployment Process

### Initial Deployment

Deployed via Railway CLI from `src/backend` directory:

```bash
# Initialize Railway project
railway init

# Deploy to Railway
railway up

# Link service
railway service

# Set environment variables
railway variables --set NODE_ENV=production
railway variables --set PORT=8080

# Generate public domain
railway domain
```

### Continuous Deployment

Railway automatically redeploys on:
- Push to connected GitHub branch
- Manual trigger via `railway up`
- Configuration changes

---

## Cost Estimation

### Current Usage

- **Free Tier Credits:** $5/month
- **Estimated Cost:** $10-15/month (with Always On)
- **Net Cost:** $5-10/month (after free credits)

### Cost Breakdown

- **Compute:** ~$10/month (Always On, 512MB RAM, 0.5 vCPU)
- **Network:** Free (under 100 GB bandwidth)
- **Storage:** Minimal (ephemeral)

---

## Security

### CORS Configuration

- **Enabled:** Yes
- **Allow Origin:** `*` (configured in `app.js`)

### HTTPS

- **SSL Certificate:** Automatic (Railway-managed)
- **Protocol:** HTTPS only

---

## Troubleshooting

### Common Issues

**Issue: Service not responding**
```bash
railway logs
railway restart
```

**Issue: Environment variables not applied**
```bash
railway variables
railway restart
```

**Issue: Build fails**
- Check build logs in Railway dashboard
- Verify `package.json` scripts
- Ensure all dependencies are in `dependencies` (not `devDependencies`)

---

## Team Information

**Deployed by:** Team BadHabits
**Contact:** avdieienkodmytro
**Repository:** GitHub - team-badhabits

---

## Version History

| Date | Version | Changes |
|------|---------|---------|
| 2025-10-26 | 1.0.0 | Initial production deployment |

---

**Last Updated:** 2025-10-26
