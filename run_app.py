import os
import sys
import time
import subprocess
import threading
import urllib.request
import signal

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
BACKEND_DIR = os.path.join(ROOT_DIR, "backend")

def log(msg, level="INFO"):
    colors = {
        "INFO": "\033[94m",
        "SUCCESS": "\033[92m",
        "WARN": "\033[93m",
        "ERROR": "\033[91m",
        "RESET": "\033[0m"
    }
    prefix = colors.get(level, "")
    reset = colors.get("RESET", "")
    print(f"{prefix}[{level}] {msg}{reset}", flush=True)

def install_backend_dependencies():
    log("Step 1: Installing Python backend dependencies...", "INFO")
    req_path = os.path.join(BACKEND_DIR, "requirements.txt")
    try:
        subprocess.run([sys.executable, "-m", "pip", "install", "-r", req_path], check=True)
        log("Backend dependencies installed successfully.", "SUCCESS")
    except subprocess.CalledProcessError as e:
        log(f"Failed to install python requirements: {e}", "ERROR")

def run_flutter_pub_get():
    log("Step 2: Running 'flutter pub get' for Flutter frontend...", "INFO")
    try:
        subprocess.run(["flutter", "pub", "get"], cwd=ROOT_DIR, check=True, shell=True)
        log("Flutter dependencies fetched successfully.", "SUCCESS")
    except subprocess.CalledProcessError as e:
        log(f"Failed to run flutter pub get: {e}", "ERROR")

def wait_for_backend(url="http://localhost:8000/", timeout=30):
    log("Step 4: Waiting for backend server to become ready...", "INFO")
    start_time = time.time()
    while time.time() - start_time < timeout:
        try:
            with urllib.request.urlopen(url, timeout=2) as response:
                if response.status == 200:
                    log("Backend is online and responding at http://localhost:8000/", "SUCCESS")
                    return True
        except Exception:
            pass
        time.sleep(1)
    log("Timed out waiting for backend to start.", "WARN")
    return False

def stream_logs(process, name):
    for line in iter(process.stdout.readline, ''):
        if line:
            print(f"[{name}] {line.strip()}", flush=True)

def main():
    log("==========================================", "INFO")
    log("  PSYNOVA AI - Single Launch Script       ", "INFO")
    log("==========================================", "INFO")

    # 1. Install python dependencies
    install_backend_dependencies()

    # 2. Run flutter pub get
    run_flutter_pub_get()

    processes = []

    try:
        # 3. Start Python FastAPI Backend
        log("Step 3: Starting FastAPI backend on http://localhost:8000 ...", "INFO")
        backend_cmd = [sys.executable, "-m", "uvicorn", "app.main:app", "--host", "127.0.0.1", "--port", "8000", "--reload"]
        backend_proc = subprocess.Popen(
            backend_cmd,
            cwd=BACKEND_DIR,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1
        )
        processes.append(backend_proc)

        # Thread to display backend logs
        b_thread = threading.Thread(target=stream_logs, args=(backend_proc, "Backend"), daemon=True)
        b_thread.start()

        # 4. Wait for backend readiness
        wait_for_backend()

        # 5. Launch Flutter Web App
        log("Step 5: Launching Flutter Web App (Chrome)...", "INFO")
        flutter_cmd = ["flutter", "run", "-d", "chrome"]
        flutter_proc = subprocess.Popen(
            flutter_cmd,
            cwd=ROOT_DIR,
            shell=True
        )
        processes.append(flutter_proc)

        log("Both services are running! Press Ctrl+C to stop all processes.", "SUCCESS")
        flutter_proc.wait()

    except KeyboardInterrupt:
        log("\nShutting down all processes...", "WARN")
    finally:
        for p in processes:
            if p.poll() is None:
                p.terminate()
                try:
                    p.wait(timeout=3)
                except subprocess.TimeoutExpired:
                    p.kill()
        log("All processes terminated.", "INFO")

if __name__ == "__main__":
    main()
