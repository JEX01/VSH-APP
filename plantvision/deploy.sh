#!/bin/bash

# NTPC Photo Inspection App Deployment Script
# This script sets up the complete application stack

set -e

echo "🏭 NTPC Photo Inspection App Deployment"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites..."
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed. Please install Node.js 16+ first."
        exit 1
    fi
    
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 16 ]; then
        print_error "Node.js version 16+ is required. Current version: $(node --version)"
        exit 1
    fi
    print_status "Node.js $(node --version) ✓"
    
    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed. Please install Flutter 3.10+ first."
        exit 1
    fi
    print_status "Flutter $(flutter --version | head -n1 | cut -d' ' -f2) ✓"
    
    # Check PostgreSQL
    if ! command -v psql &> /dev/null; then
        print_warning "PostgreSQL client not found. Make sure PostgreSQL is accessible."
    else
        print_status "PostgreSQL client ✓"
    fi
    
    # Check Docker (optional)
    if command -v docker &> /dev/null; then
        print_status "Docker $(docker --version | cut -d' ' -f3 | cut -d',' -f1) ✓"
    else
        print_warning "Docker not found. Manual deployment will be used."
    fi
}

# Setup backend
setup_backend() {
    print_header "Setting up Backend..."
    
    cd backend
    
    # Install dependencies
    print_status "Installing Node.js dependencies..."
    npm install
    
    # Check if .env exists
    if [ ! -f .env ]; then
        print_warning ".env file not found. Copying from .env.example"
        cp .env.example .env
        print_warning "Please edit .env file with your configuration before running the server."
    fi
    
    # Run database migrations (if DB is accessible)
    if [ "$SKIP_DB" != "true" ]; then
        print_status "Running database migrations..."
        npm run migrate || print_warning "Database migration failed. Please check your database connection."
        
        print_status "Seeding initial data..."
        npm run seed || print_warning "Database seeding failed. Please check your database connection."
    fi
    
    cd ..
    print_status "Backend setup completed ✓"
}

# Setup mobile app
setup_mobile() {
    print_header "Setting up Mobile App..."
    
    cd mobile
    
    # Get Flutter dependencies
    print_status "Getting Flutter dependencies..."
    flutter pub get
    
    # Run code generation
    print_status "Running code generation..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
    
    # Check for Android SDK
    if [ "$ANDROID_HOME" != "" ]; then
        print_status "Android SDK found at $ANDROID_HOME ✓"
    else
        print_warning "ANDROID_HOME not set. Android builds may not work."
    fi
    
    cd ..
    print_status "Mobile app setup completed ✓"
}

# Build mobile app
build_mobile() {
    print_header "Building Mobile App..."
    
    cd mobile
    
    # Build APK
    print_status "Building Android APK..."
    flutter build apk --release
    
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        print_status "APK built successfully ✓"
        print_status "APK location: mobile/build/app/outputs/flutter-apk/app-release.apk"
    else
        print_error "APK build failed"
    fi
    
    cd ..
}

# Start services
start_services() {
    print_header "Starting Services..."
    
    # Start backend
    cd backend
    print_status "Starting backend server..."
    
    if [ "$PRODUCTION" == "true" ]; then
        npm start &
    else
        npm run dev &
    fi
    
    BACKEND_PID=$!
    print_status "Backend server started (PID: $BACKEND_PID) ✓"
    
    cd ..
    
    # Save PID for cleanup
    echo $BACKEND_PID > .backend.pid
}

# Stop services
stop_services() {
    print_header "Stopping Services..."
    
    if [ -f .backend.pid ]; then
        BACKEND_PID=$(cat .backend.pid)
        if kill -0 $BACKEND_PID 2>/dev/null; then
            kill $BACKEND_PID
            print_status "Backend server stopped ✓"
        fi
        rm .backend.pid
    fi
}

# Docker deployment
deploy_docker() {
    print_header "Docker Deployment..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is required for containerized deployment"
        exit 1
    fi
    
    # Build backend image
    print_status "Building backend Docker image..."
    cd backend
    docker build -t ntpc-photo-inspection-backend .
    cd ..
    
    # Create docker-compose.yml if it doesn't exist
    if [ ! -f docker-compose.yml ]; then
        cat > docker-compose.yml << EOF
version: '3.8'
services:
  backend:
    image: ntpc-photo-inspection-backend
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    env_file:
      - backend/.env
    depends_on:
      - postgres
      
  postgres:
    image: postgres:14
    environment:
      - POSTGRES_DB=ntpc_photo_inspection
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
      
volumes:
  postgres_data:
EOF
        print_status "Created docker-compose.yml"
    fi
    
    # Start services
    print_status "Starting Docker services..."
    docker-compose up -d
    
    print_status "Docker deployment completed ✓"
}

# Health check
health_check() {
    print_header "Running Health Checks..."
    
    # Check backend health
    print_status "Checking backend health..."
    sleep 5  # Wait for server to start
    
    if curl -f http://localhost:3000/health &> /dev/null; then
        print_status "Backend health check passed ✓"
    else
        print_warning "Backend health check failed. Server may still be starting."
    fi
    
    # Check database connection
    if [ "$SKIP_DB" != "true" ]; then
        print_status "Checking database connection..."
        cd backend
        if npm run migrate:status &> /dev/null; then
            print_status "Database connection successful ✓"
        else
            print_warning "Database connection failed"
        fi
        cd ..
    fi
}

# Display deployment info
show_deployment_info() {
    print_header "Deployment Information"
    echo "========================"
    echo ""
    echo "🏭 NTPC Photo Inspection App"
    echo "📱 Mobile App: mobile/build/app/outputs/flutter-apk/app-release.apk"
    echo "🖥️  Backend API: http://localhost:3000"
    echo "📊 Health Check: http://localhost:3000/health"
    echo "📚 API Docs: See NTPC_README.md for endpoint documentation"
    echo ""
    echo "Default Test Users:"
    echo "  👤 admin / admin123 (Administrator)"
    echo "  👨‍💼 manager1 / manager123 (Manager - Boiler Area)"
    echo "  👨‍💼 manager2 / manager123 (Manager - Turbine Area)"
    echo "  👷 worker1 / worker123 (Worker - Boiler Area)"
    echo "  👷 worker2 / worker123 (Worker - Turbine Area)"
    echo "  👷 worker3 / worker123 (Worker - Generator Area)"
    echo ""
    echo "📋 Next Steps:"
    echo "  1. Configure .env file with your database and AWS credentials"
    echo "  2. Install the APK on Android devices"
    echo "  3. Configure Firebase for push notifications"
    echo "  4. Set up AWS S3 bucket for photo storage"
    echo "  5. Configure SSL/TLS for production deployment"
    echo ""
    print_status "Deployment completed successfully! 🎉"
}

# Cleanup function
cleanup() {
    print_header "Cleaning up..."
    stop_services
}

# Main deployment function
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --production)
                PRODUCTION=true
                shift
                ;;
            --docker)
                USE_DOCKER=true
                shift
                ;;
            --skip-db)
                SKIP_DB=true
                shift
                ;;
            --build-only)
                BUILD_ONLY=true
                shift
                ;;
            --stop)
                stop_services
                exit 0
                ;;
            -h|--help)
                echo "NTPC Photo Inspection App Deployment Script"
                echo ""
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --production    Deploy in production mode"
                echo "  --docker        Use Docker for deployment"
                echo "  --skip-db       Skip database setup"
                echo "  --build-only    Only build, don't start services"
                echo "  --stop          Stop running services"
                echo "  -h, --help      Show this help message"
                echo ""
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Set trap for cleanup
    trap cleanup EXIT
    
    # Run deployment steps
    check_prerequisites
    
    if [ "$USE_DOCKER" == "true" ]; then
        deploy_docker
    else
        setup_backend
        setup_mobile
        
        if [ "$BUILD_ONLY" != "true" ]; then
            start_services
            health_check
        else
            build_mobile
        fi
    fi
    
    show_deployment_info
}

# Run main function
main "$@"