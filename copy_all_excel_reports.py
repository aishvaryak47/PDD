import os
import shutil

def copy_reports():
    base_dir = os.path.dirname(__file__)
    out_dir = os.path.join(base_dir, "All-Test-Reports-Excel")
    os.makedirs(out_dir, exist_ok=True)

    mappings = [
        ("selenium-tests/test_execution_report.xlsx", "1-Selenium-E2E-Web-Test-Report.xlsx"),
        ("appium-tests/appium_test_execution_report.xlsx", "2-Appium-Mobile-E2E-Test-Report.xlsx"),
        ("load-testing/baseline_load_test_report.xlsx", "3-Baseline-100VU-Load-Test-Report.xlsx"),
        ("Vulnerability Test Results/findings.xlsx", "4-Security-Assessment-Findings-Report.xlsx"),
        ("Vulnerability Test Results/endpoint-inventory.xlsx", "5-API-Endpoint-Inventory-Report.xlsx"),
    ]

    for src_rel, dest_name in mappings:
        src_path = os.path.join(base_dir, src_rel)
        dest_path = os.path.join(out_dir, dest_name)
        if os.path.exists(src_path):
            shutil.copy2(src_path, dest_path)
            print(f"Copied {src_rel} -> {dest_name}")
        else:
            print(f"Warning: {src_path} does not exist!")

if __name__ == "__main__":
    copy_reports()
