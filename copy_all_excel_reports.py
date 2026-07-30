import os
import shutil

def copy_reports():
    base_dir = os.path.dirname(__file__)
    out_dir = os.path.join(base_dir, "All-Test-Reports-Excel")
    
    # Clear directory to ensure no old names remain
    if os.path.exists(out_dir):
        shutil.rmtree(out_dir)
    os.makedirs(out_dir, exist_ok=True)

    mappings = [
        ("selenium-tests/test_execution_report.xlsx", "Selenium-Web-E2E-Test-Report.xlsx"),
        ("appium-tests/appium_test_execution_report.xlsx", "Appium-Mobile-E2E-Test-Report.xlsx"),
        ("load-testing/baseline_load_test_report.xlsx", "Baseline-100VU-Load-Test-Report.xlsx"),
        ("Vulnerability Test Results/findings.xlsx", "Security-Assessment-Test-Report.xlsx"),
    ]

    for src_rel, dest_name in mappings:
        src_path = os.path.join(base_dir, src_rel)
        dest_path = os.path.join(out_dir, dest_name)
        if os.path.exists(src_path):
            shutil.copy2(src_path, dest_path)
            print(f"Named Excel Report: {dest_name}")
        else:
            print(f"Warning: {src_path} does not exist!")

if __name__ == "__main__":
    copy_reports()
