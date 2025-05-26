#!/bin/bash

# Setup script for Railway deployment
# Run this script to prepare your project for Railway deployment

echo "🚂 Preparing Blood Pressure App for Railway deployment..."

# Create necessary directories
echo "📁 Creating directory structure..."
mkdir -p app/api
mkdir -p files

# Backup existing files
echo "💾 Backing up existing files..."
if [ -f "Dockerfile" ]; then
    cp Dockerfile Dockerfile.backup
    echo "  - Backed up Dockerfile to Dockerfile.backup"
fi

if [ -f "app/api/blood_pressure.php" ]; then
    cp app/api/blood_pressure.php app/api/blood_pressure.php.backup
    echo "  - Backed up blood_pressure.php to blood_pressure.php.backup"
fi

# Check if Railway CLI is installed
if command -v railway &> /dev/null; then
    echo "✅ Railway CLI is installed"
else
    echo "❌ Railway CLI is not installed"
    echo "   Install it with: npm install -g @railway/cli"
fi

# Check if git is initialized
if [ -d ".git" ]; then
    echo "✅ Git repository exists"
else
    echo "📝 Initializing git repository..."
    git init
fi

# Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    echo "📝 Creating .gitignore..."
    cat > .gitignore << 'EOL'
# Docker volumes
db-data/

# OS files
.DS_Store
Thumbs.db

# IDE files
.idea/
.vscode/
*.sublime-project
*.sublime-workspace

# Environment files
.env
.env.local
.env.*.local

# Log files
*.log
logs/

# PHP files
vendor/
composer.lock

# Backups
*.bak
*.backup
*.swp

# Docker override
docker-compose.override.yml
EOL
    echo "✅ Created .gitignore"
fi

# Create a simple health check file
echo "📝 Creating health check endpoint..."
cat > app/health.php << 'EOL'
<?php
header('Content-Type: application/json');
echo json_encode([
    'status' => 'healthy',
    'service' => 'Blood Pressure Monitoring System',
    'timestamp' => date('Y-m-d H:i:s'),
    'php_version' => PHP_VERSION
]);
?>
EOL

echo "✅ Created health check endpoint"

# Summary
echo ""
echo "🎉 Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Review and update the Dockerfile with the Railway-optimized version"
echo "2. Update app/api/blood_pressure.php with the Railway-compatible version"
echo "3. Add railway.json configuration file"
echo "4. Add app/init_database.php for database initialization"
echo "5. Commit your changes: git add . && git commit -m 'Prepare for Railway deployment'"
echo "6. Deploy to Railway using the deployment guide"
echo ""
echo "📚 Files to update:"
echo "   - Dockerfile (use the Railway-optimized version)"
echo "   - app/api/blood_pressure.php (use the Railway-compatible API)"
echo "   - railway.json (add the configuration file)"
echo "   - app/init_database.php (add the database initialization script)"
echo ""
echo "🔗 Useful links:"
echo "   - Railway Dashboard: https://railway.app"
echo "   - Railway Docs: https://docs.railway.app"
echo "   - Create Railway Account: https://railway.app/signup"