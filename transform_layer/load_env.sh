#!/bin/bash
# Script to load environment variables from .env file

if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo "Environment variables loaded from .env"
else
    echo "No .env file found. Please create one from .env.example"
    echo "cp .env.example .env"
    echo "Then edit .env with your database credentials"
fi