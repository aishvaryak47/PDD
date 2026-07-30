import asyncio
import time
import json
import statistics
import os
import urllib.request
import urllib.error

TARGET_URL = os.getenv("TARGET_URL", "http://127.0.0.1:8000/api/v1/therapists")
VIRTUAL_USERS = 100
DURATION_SECONDS = 60

class LoadTestRunner:
    def __init__(self, target_url, vus, duration):
        self.target_url = target_url
        self.vus = vus
        self.duration = duration
        self.latencies = []
        self.success_count = 0
        self.error_count = 0
        self.start_time = 0
        self.end_time = 0

    def send_request(self):
        req_start = time.perf_counter()
        try:
            req = urllib.request.Request(
                self.target_url,
                headers={"User-Agent": "PSYNOVA-LoadTester/1.0", "Accept": "application/json"}
            )
            with urllib.request.urlopen(req, timeout=5) as response:
                _ = response.read()
                latency_ms = (time.perf_counter() - req_start) * 1000.0
                return True, latency_ms
        except Exception:
            latency_ms = (time.perf_counter() - req_start) * 1000.0
            return False, latency_ms

    async def worker(self, worker_id, stop_event, loop):
        while not stop_event.is_set():
            success, latency = await loop.run_in_executor(None, self.send_request)
            if success:
                self.success_count += 1
            else:
                self.error_count += 1
            self.latencies.append(latency)
            await asyncio.sleep(0.01)

    async def run(self):
        print("=========================================================================")
        print("  PSYNOVA AI - 100 Virtual Users Baseline Load Test Execution            ")
        print("=========================================================================")
        print(f"Target URL:         {self.target_url}")
        print(f"Virtual Users (VU): {self.vus} Concurrent Workers")
        print(f"Test Duration:      {self.duration} Seconds (1 Minute)")
        print("-------------------------------------------------------------------------")
        print("Launching 100 concurrent Virtual Users... Please wait 60 seconds...\n")

        stop_event = asyncio.Event()
        loop = asyncio.get_running_loop()
        self.start_time = time.time()

        workers = [
            asyncio.create_task(self.worker(i, stop_event, loop))
            for i in range(self.vus)
        ]

        for elapsed in range(1, self.duration + 1):
            await asyncio.sleep(1)
            total_reqs = len(self.latencies)
            current_rps = total_reqs / elapsed
            print(f"[{elapsed:02d}/{self.duration}s] Requests Sent: {total_reqs:5d} | Current RPS: {current_rps:6.1f} req/sec", end="\r", flush=True)

        stop_event.set()
        await asyncio.gather(*workers, return_exceptions=True)
        self.end_time = time.time()

        self.print_results()

    def print_results(self):
        actual_duration = self.end_time - self.start_time
        total_requests = len(self.latencies)
        rps = total_requests / actual_duration if actual_duration > 0 else 0

        min_latency = min(self.latencies) if self.latencies else 0.0
        max_latency = max(self.latencies) if self.latencies else 0.0
        avg_latency = statistics.mean(self.latencies) if self.latencies else 0.0
        p95_latency = statistics.quantiles(self.latencies, n=20)[18] if len(self.latencies) >= 20 else avg_latency
        p99_latency = statistics.quantiles(self.latencies, n=100)[98] if len(self.latencies) >= 100 else max_latency

        print("\n\n=========================================================================")
        print("LOAD TEST EXECUTION RESULTS SUMMARY")
        print("=========================================================================")
        print(f"Total Test Duration:       {actual_duration:.2f} seconds")
        print(f"Total Requests Sent:       {total_requests} requests")
        print(f"Successful Requests (2xx): {self.success_count} ({ (self.success_count/total_requests*100) if total_requests else 0:.1f}%)")
        print(f"Failed / Error Requests:   {self.error_count}")
        print("-------------------------------------------------------------------------")
        print(f"Requests Per Second (RPS): {rps:.2f} req/sec")
        print("-------------------------------------------------------------------------")
        print("RESPONSE TIME METRICS (LATENCY):")
        print(f"   * Minimum Response Time:  {min_latency:.2f} ms")
        print(f"   * Average Response Time:  {avg_latency:.2f} ms")
        print(f"   * Maximum Response Time:  {max_latency:.2f} ms")
        print(f"   * 95th Percentile (p95):  {p95_latency:.2f} ms")
        print(f"   * 99th Percentile (p99):  {p99_latency:.2f} ms")
        print("=========================================================================\n")

        results_data = {
            "target_url": self.target_url,
            "vus": self.vus,
            "duration_seconds": round(actual_duration, 2),
            "total_requests": total_requests,
            "success_count": self.success_count,
            "error_count": self.error_count,
            "rps": round(rps, 2),
            "min_ms": round(min_latency, 2),
            "avg_ms": round(avg_latency, 2),
            "max_ms": round(max_latency, 2),
            "p95_ms": round(p95_latency, 2),
            "p99_ms": round(p99_latency, 2)
        }

        out_json = os.path.join(os.path.dirname(__file__), "load_test_results.json")
        with open(out_json, "w") as f:
            json.dump(results_data, f, indent=2)
        print(f"Results saved to {out_json}")

if __name__ == "__main__":
    runner = LoadTestRunner(TARGET_URL, VIRTUAL_USERS, DURATION_SECONDS)
    asyncio.run(runner.run())
