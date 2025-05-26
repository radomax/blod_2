#!/bin/bash

# Health check script for Railway deployment
# Usage: ./check-deployment.sh your-app-name

APP_NAME=${1:-your-app-name}
BASE_URL="https://${APP_NAME}.railway.app"

echo "🔍 Checking deployment health for: $BASE_URL"
echo "================================================"

# Function to check endpoint
check_endpoint() {
    local endpoint=$1
    local description=$2
    
    echo -n "Checking $description... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL$endpoint")
    
    if [ "$response" = "200" ]; then
        echo "✅ OK (HTTP $response)"
        return 0
    else
        echo "❌ Failed (HTTP $response)"
        return 1
    fi
}

# Function to check API endpoint
check_api() {
    local endpoint=$1
    local description=$2
    
    echo -n "Checking $description... "
    
    response=$(curl -s "$BASE_URL$endpoint")
    success=$(echo $response | grep -o '"success":true' | wc -l)
    
    if [ "$success" -gt 0 ]; then
        echo "✅ OK (API responds successfully)"
        return 0
    else
        echo "❌ Failed"
        echo "   Response: $response"
        return 1
    fi
}

# Run checks
echo ""
echo "1. Basic Connectivity"
echo "--------------------"
check_endpoint "/" "Main page"
check_endpoint "/index.html" "Index page"
check_endpoint "/index.css" "CSS file"
check_endpoint "/index.js" "JavaScript file"

echo ""
echo "2. API Endpoints"
echo "----------------"
check_api "/api/blood_pressure.php?action=health" "API health"
check_api "/api/blood_pressure.php?action=statistics" "Statistics endpoint"

echo ""
echo "3. Database Connectivity"
echo "------------------------"
echo -n "Checking database connection... "

# Try to get statistics which requires database
stats_response=$(curl -s "$BASE_URL/api/blood_pressure.php?action=statistics")
if echo "$stats_response" | grep -q '"total"'; then
    echo "✅ OK (Database is connected)"
    
    # Parse some stats
    total=$(echo $stats_response | grep -o '"total":[0-9]*' | cut -d: -f2)
    echo "   - Total measurements: $total"
else
    echo "❌ Failed (Database might not be initialized)"
    echo "   - Run: $BASE_URL/init_database.php"
fi

echo ""
echo "4. Performance Check"
echo "--------------------"
echo -n "Measuring response time... "

time_total=$(curl -s -o /dev/null -w "%{time_total}" "$BASE_URL/api/blood_pressure.php?action=health")
time_ms=$(echo "scale=0; $time_total * 1000 / 1" | bc)

if [ "$time_ms" -lt 1000 ]; then
    echo "✅ OK (${time_ms}ms)"
elif [ "$time_ms" -lt 3000 ]; then
    echo "⚠️  Warning (${time_ms}ms - somewhat slow)"
else
    echo "❌ Poor (${time_ms}ms - very slow)"
fi

echo ""
echo "5. Security Headers"
echo "-------------------"
headers=$(curl -s -I "$BASE_URL")

check_header() {
    local header=$1
    local description=$2
    
    echo -n "Checking $description... "
    if echo "$headers" | grep -qi "$header"; then
        echo "✅ Present"
    else
        echo "⚠️  Missing"
    fi
}

check_header "X-Content-Type-Options" "X-Content-Type-Options"
check_header "X-Frame-Options" "X-Frame-Options"

echo ""
echo "================================================"
echo "Deployment check complete!"
echo ""
echo "📋 Summary:"
echo "   - App URL: $BASE_URL"
echo "   - Database: Check if initialized"
echo "   - Admin login: /index.html (click 'Logg inn')"
echo "   - Default credentials: admin / admin123"
echo ""
echo "⚠️  Important:"
echo "   1. Change admin password immediately"
echo "   2. Delete init_database.php after setup"
echo "   3. Monitor Railway dashboard for usage"
echo ""
echo "🔗 Useful commands:"
echo "   - View logs: railway logs"
echo "   - Open app: railway open"
echo "   - Check status: railway status"