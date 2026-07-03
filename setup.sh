#!/bin/bash

# Acades AI - Quick Start Setup Script
# Run this script to set up the project for the first time

set -e  # Exit on error

echo "🚀 Acades AI - Production Setup"
echo "=================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Check prerequisites
echo -e "${YELLOW}Step 1: Checking prerequisites...${NC}"

if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter not found. Please install Flutter first.${NC}"
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi
echo -e "${GREEN}✅ Flutter found: $(flutter --version | head -n 1)${NC}"

if ! command -v dart &> /dev/null; then
    echo -e "${RED}❌ Dart not found.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Dart found: $(dart --version)${NC}"

if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git not found.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Git found${NC}"

echo ""

# Step 2: Environment setup
echo -e "${YELLOW}Step 2: Setting up environment...${NC}"

if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        echo -e "${GREEN}✅ Created .env file from template${NC}"
        echo -e "${YELLOW}⚠️  Edit .env with your Supabase credentials:${NC}"
        echo "   SUPABASE_URL=your-supabase-url"
        echo "   SUPABASE_ANON_KEY=your-anon-key"
    else
        echo -e "${RED}❌ .env.example not found${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ .env file already exists${NC}"
fi

echo ""

# Step 3: Install dependencies
echo -e "${YELLOW}Step 3: Installing Flutter dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✅ Dependencies installed${NC}"

echo ""

# Step 4: Code generation
echo -e "${YELLOW}Step 4: Running code generation...${NC}"
flutter pub run build_runner build --delete-conflicting-outputs
echo -e "${GREEN}✅ Code generation complete${NC}"

echo ""

# Step 5: Verify setup
echo -e "${YELLOW}Step 5: Verifying setup...${NC}"
flutter doctor
echo ""

echo -e "${GREEN}=================================="
echo "✨ Setup Complete! ${NC}"
echo ""
echo "📝 Next steps:"
echo "1. Edit .env with your Supabase credentials"
echo "2. Run the app: flutter run"
echo "3. Read SETUP_CHECKLIST.md for detailed instructions"
echo ""
echo "📚 Documentation:"
echo "   - PRODUCTION_READY.md - Overview of everything"
echo "   - SETUP_CHECKLIST.md - Step-by-step guide"
echo "   - DEVELOPMENT_GUIDE.md - Development reference"
echo "   - PRODUCTION_SETUP.md - Production deployment"
echo ""
echo -e "${YELLOW}For help: See README.md or DEVELOPMENT_GUIDE.md${NC}"
