#!/usr/bin/env bash
# Setup and run the Industrial Equipment Failure Prediction ML project.
# Usage: ./setup_and_run.sh [train|run|test]

set -e
cd "$(dirname "$0")"

VENV_DIR=".venv"
PYTHON="${VENV_DIR}/bin/python"
PIP="${VENV_DIR}/bin/pip"

echo "=== Industrial Equipment Failure Prediction - Setup ==="

# On macOS, XGBoost requires OpenMP. If you see libomp errors, run: brew install libomp

# Create virtual environment if it doesn't exist
if [[ ! -d "$VENV_DIR" ]]; then
    echo "Creating virtual environment at $VENV_DIR ..."
    python3 -m venv "$VENV_DIR"
fi

# Install dependencies
echo "Installing dependencies from requirements.txt ..."
"$PIP" install -q --upgrade pip
"$PIP" install -q -r requirements.txt

# Ensure model exists (train if missing)
if [[ ! -f "model.bin" ]]; then
    echo "No model.bin found. Training model (this may take a minute) ..."
    "$PYTHON" train.py
else
    echo "Using existing model.bin"
fi

# Default: run the prediction server
case "${1:-run}" in
    train)
        echo "Training model ..."
        "$PYTHON" train.py
        ;;
    run)
        echo "Starting prediction server at http://0.0.0.0:9696"
        echo "Test with: python predict-test.py local"
        exec "$PYTHON" predict.py
        ;;
    test)
        echo "Starting server in background for quick test ..."
        "$PYTHON" predict.py &
        SERVER_PID=$!
        sleep 3
        "$PYTHON" predict-test.py local
        kill $SERVER_PID 2>/dev/null || true
        ;;
    *)
        echo "Usage: $0 [train|run|test]"
        echo "  train - (re)train the model and save to model.bin"
        echo "  run   - start the Flask prediction server (default)"
        echo "  test  - run a quick local test against the server"
        exit 1
        ;;
esac
