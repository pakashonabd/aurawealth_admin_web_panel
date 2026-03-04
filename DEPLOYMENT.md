# Deployment Guide

## 🚀 Quick Deployment Options

### Option 1: Firebase Hosting (Recommended)

**1. Install Firebase CLI:**
```bash
npm install -g firebase-tools
```

**2. Login to Firebase:**
```bash
firebase login
```

**3. Initialize Firebase:**
```bash
firebase init hosting
```

Select:
- Use existing project or create new one
- Public directory: `build/web`
- Configure as single-page app: Yes
- Set up automatic builds: No (we'll build manually)

**4. Build and Deploy:**
```bash
# Build for production
flutter build web --release

# Deploy to Firebase
firebase deploy --only hosting
```

**5. Access your app:**
Your app will be live at: `https://your-project.firebaseapp.com`

### Option 2: Netlify

**1. Build the app:**
```bash
flutter build web --release
```

**2. Deploy via Netlify CLI:**
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Deploy
netlify deploy --prod --dir=build/web
```

**Or via Web UI:**
1. Go to https://app.netlify.com
2. Drag and drop the `build/web` folder
3. Done!

**3. Configure redirects:**
Create `build/web/_redirects`:
```
/*    /index.html   200
```

### Option 3: Vercel

**1. Install Vercel CLI:**
```bash
npm install -g vercel
```

**2. Build and Deploy:**
```bash
# Build
flutter build web --release

# Deploy
cd build/web
vercel --prod
```

**3. Configure:**
Create `vercel.json` in project root:
```json
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
```

### Option 4: AWS S3 + CloudFront

**1. Build the app:**
```bash
flutter build web --release
```

**2. Create S3 Bucket:**
- Go to AWS S3 Console
- Create new bucket
- Enable static website hosting
- Set index document: `index.html`

**3. Upload Files:**
```bash
aws s3 sync build/web/ s3://your-bucket-name --delete
```

**4. Configure CloudFront:**
- Create CloudFront distribution
- Set origin to S3 bucket
- Configure error pages to redirect to `/index.html`
- Set SSL certificate

**5. Update DNS:**
Point your domain to CloudFront distribution

### Option 5: Traditional Web Server (Nginx)

**1. Build the app:**
```bash
flutter build web --release
```

**2. Copy files to server:**
```bash
scp -r build/web/* user@server:/var/www/html/admin/
```

**3. Configure Nginx:**
```nginx
server {
    listen 80;
    server_name admin.aurawealth.com;
    
    root /var/www/html/admin;
    index index.html;

    # Enable gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

**4. Enable HTTPS:**
```bash
# Install certbot
sudo apt-get install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d admin.aurawealth.com
```

## 🔧 Pre-Deployment Checklist

### Configuration
- [ ] Update API base URL to production endpoint
- [ ] Verify all environment variables are set
- [ ] Test API connectivity from production domain
- [ ] Configure CORS for production domain
- [ ] Set up proper error logging

### Security
- [ ] Enable HTTPS/SSL
- [ ] Configure Content Security Policy
- [ ] Set secure headers
- [ ] Verify token expiry handling
- [ ] Test authentication flow
- [ ] Remove any debug/test credentials

### Performance
- [ ] Build with `--release` flag
- [ ] Enable gzip compression
- [ ] Set up CDN (if needed)
- [ ] Configure caching headers
- [ ] Optimize images (if any added)
- [ ] Test loading times

### Testing
- [ ] Test on multiple browsers (Chrome, Firefox, Safari, Edge)
- [ ] Test responsive layouts (desktop, tablet, mobile)
- [ ] Test all features end-to-end
- [ ] Verify error handling
- [ ] Test with slow network
- [ ] Test offline behavior

### Monitoring
- [ ] Set up error tracking (Sentry, etc.)
- [ ] Configure analytics (Google Analytics, etc.)
- [ ] Set up uptime monitoring
- [ ] Configure log aggregation

## 📊 Build Configuration

### Standard Build
```bash
flutter build web --release
```

### With Specific Renderer
```bash
# HTML renderer (better for text-heavy apps)
flutter build web --release --web-renderer html

# CanvasKit renderer (better for complex UI)
flutter build web --release --web-renderer canvaskit
```

### Build with Source Maps (for debugging production issues)
```bash
flutter build web --release --source-maps
```

## 🌐 Domain Configuration

### DNS Settings

For `admin.aurawealth.com`:

**A Record:**
```
Type: A
Name: admin
Value: Your-Server-IP
TTL: 3600
```

**Or CNAME (for CDN):**
```
Type: CNAME
Name: admin
Value: your-cdn-domain.cloudfront.net
TTL: 3600
```

## 🔒 SSL/HTTPS Setup

### Using Let's Encrypt (Free)

```bash
sudo certbot --nginx -d admin.aurawealth.com
```

### Force HTTPS Redirect

**Nginx:**
```nginx
server {
    listen 80;
    server_name admin.aurawealth.com;
    return 301 https://$server_name$request_uri;
}
```

## 📈 Performance Optimization

### 1. Enable Compression

**Nginx:**
```nginx
gzip on;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
gzip_min_length 1000;
```

### 2. Browser Caching

**Nginx:**
```nginx
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### 3. CDN Setup

Use CloudFlare or AWS CloudFront for:
- Global content delivery
- DDoS protection
- SSL termination
- Automatic caching

## 🔐 Security Headers

Add these headers in your web server:

```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Content-Security-Policy "default-src 'self' https:; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline';" always;
```

## 📱 PWA Configuration

### Make it Installable

The app is already configured as a PWA. Users can install it:

**Desktop (Chrome):**
- Click install icon in address bar
- Or: Menu → Install AuraWealth Admin

**Mobile:**
- Open in mobile browser
- Tap "Add to Home Screen"

### Service Worker (Optional)

To enable offline support, configure service worker in `web/index.html`.

## 🔄 Continuous Deployment

### GitHub Actions Example

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Firebase

on:
  push:
    branches: [ main ]

jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.4'
      
      - run: flutter pub get
      - run: flutter build web --release
      
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          channelId: live
          projectId: your-firebase-project
```

## 🌍 Multi-Environment Setup

### Development
```dart
// lib/core/config/environment.dart
class Environment {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000',
  );
}
```

### Build Commands
```bash
# Development
flutter build web --release --dart-define=API_URL=http://localhost:8000

# Staging
flutter build web --release --dart-define=API_URL=https://staging-api.aurawealth.com

# Production
flutter build web --release --dart-define=API_URL=https://api.aurawealth.com
```

## 📝 Post-Deployment

### 1. Verify Deployment
- [ ] Access the URL
- [ ] Test login functionality
- [ ] Check API connectivity
- [ ] Test responsive layouts
- [ ] Verify all features work

### 2. Monitor
- Set up monitoring tools
- Check error logs
- Monitor API usage
- Track user sessions

### 3. Backup
- Backup deployment configuration
- Document deployment process
- Keep rollback plan ready

## 🆘 Rollback Procedure

If deployment fails:

**Firebase:**
```bash
firebase hosting:rollback
```

**Manual:**
1. Keep previous build in `build/web.backup/`
2. Copy backup files back to deployment location
3. Clear CDN cache if applicable

## 📞 Support

For deployment issues:
- Check build logs
- Verify API connectivity
- Test in incognito/private browsing
- Clear browser cache
- Check server logs

## 🎉 Success!

Once deployed, your admin panel will be accessible at your configured URL. Test thoroughly and monitor for any issues.
