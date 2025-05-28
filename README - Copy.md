# Railway Deployment Guide for Blood Pressure Measurement App

## Prerequisites
- Railway account (https://railway.app)
- GitHub account (for easy deployment)
- Git installed locally

## Step 1: Prepare Your Project

1. **Update your project files:**
   - Replace your current `Dockerfile` with the Railway-optimized version
   - Replace `app/api/blood_pressure.php` with the Railway-compatible API version
   - Add `railway.json` to your project root
   - Add `app/init_database.php` to your project

2. **Create a `.gitignore` file if you don't have one:**
   ```
   db-data/
   .DS_Store
   .env
   .env.local
   vendor/
   *.log
   ```

3. **Commit your changes:**
   ```bash
   git add .
   git commit -m "Prepare for Railway deployment"
   ```

## Step 2: Deploy to Railway

### Option A: Deploy via GitHub (Recommended)

1. **Push your code to GitHub:**
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/blood-pressure-app.git
   git push -u origin main
   ```

2. **In Railway Dashboard:**
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Choose your repository
   - Railway will automatically detect the Dockerfile

### Option B: Deploy via Railway CLI

1. **Install Railway CLI:**
   ```bash
   npm install -g @railway/cli
   ```

2. **Login and deploy:**
   ```bash
   railway login
   railway init
   railway up
   ```

## Step 3: Add MySQL Database

1. **In your Railway project:**
   - Click "New Service"
   - Select "Database" → "Add MySQL"
   - Railway will automatically create a MySQL instance

2. **Connect services:**
   - Railway automatically injects database credentials as environment variables
   - The app will use the `MYSQL_URL` variable automatically

## Step 4: Configure Environment Variables

1. **In your Railway project settings, add these variables:**
   ```
   # These are automatically set by Railway MySQL:
   # MYSQL_URL, MYSQLHOST, MYSQLPORT, MYSQLDATABASE, MYSQLUSER, MYSQLPASSWORD
   
   # Optional custom variables:
   APP_NAME=Blood Pressure Monitoring System
   TIMEZONE=Europe/Oslo
   ```

## Step 5: Initialize the Database

1. **After deployment, access your app:**
   ```
   https://your-app-name.railway.app/init_database.php
   ```

2. **You should see:**
   ```
   Connected to database successfully!
   Created blood_pressure_measurements table successfully!
   Created users table successfully!
   Default admin user created (username: admin, password: admin123)
   Created bp_statistics view successfully!
   Created bp_categories view successfully!
   Inserted sample data successfully!
   
   Database initialization completed successfully!
   ```

3. **Important:** Delete or rename `init_database.php` after initialization for security.

## Step 6: Configure Custom Domain (Optional)

1. **In Railway project settings:**
   - Go to "Settings" → "Domains"
   - Add your custom domain
   - Update your DNS records as instructed

## Step 7: Verify Deployment

1. **Access your application:**
   - Main app: `https://your-app-name.railway.app`
   - API health check: `https://your-app-name.railway.app/api/blood_pressure.php?action=health`

2. **Test the application:**
   - Try registering a blood pressure measurement
   - Check the statistics page
   - Test the admin login (username: admin, password: admin123)

## Troubleshooting

### Database Connection Issues
- Check Railway logs: `railway logs`
- Verify environment variables are set correctly
- Ensure MySQL service is running

### Application Errors
- Check PHP error logs in Railway dashboard
- Verify file permissions (should be handled by Dockerfile)
- Check API endpoints are accessible

### Performance Issues
- Railway provides automatic scaling
- Monitor usage in Railway dashboard
- Consider upgrading plan if needed

## Security Recommendations

1. **Change default passwords immediately:**
   - Update admin password through the application
   - Consider implementing stronger authentication

2. **Environment variables:**
   - Never commit sensitive data to Git
   - Use Railway's environment variable management

3. **Database security:**
   - Restrict database access to only your app
   - Regular backups (Railway provides automatic backups on paid plans)

## Maintenance

### Updating the Application
```bash
git add .
git commit -m "Update description"
git push origin main
```
Railway will automatically redeploy.

### Database Backups
- Railway provides automatic backups on paid plans
- Manual backup: Use phpMyAdmin or MySQL dump commands

### Monitoring
- Railway provides built-in metrics
- Set up alerts for downtime or high usage

## Cost Considerations

- Railway offers $5 free credit monthly
- MySQL database counts toward usage
- Monitor usage in Railway dashboard
- Consider upgrading for production use

## Support

- Railway Documentation: https://docs.railway.app
- Railway Discord: https://discord.gg/railway
- GitHub Issues: For app-specific problems