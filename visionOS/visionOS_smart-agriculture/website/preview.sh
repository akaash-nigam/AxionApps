#!/bin/bash

# Simple HTTP server to preview the landing page
# Usage: ./preview.sh

echo "🌾 Smart Agriculture Landing Page Preview"
echo "=========================================="
echo ""
echo "Starting local web server..."
echo "Open your browser to: http://localhost:8000"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

cd "$(dirname "$0")"
python3 -m http.server 8000
