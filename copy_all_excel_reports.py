import os
import shutil

def copy_reports():
    base_dir = os.path.dirname(__file__)
    sec_folder = os.path.join(base_dir, "Security-Assessment")
    all_reports_dir = os.path.join(base_dir, "All-Test-Reports-Excel")
    
    for d in [sec_folder, all_reports_dir]:
        if os.path.exists(d):
            shutil.rmtree(d)
        os.makedirs(d, exist_ok=True)

    mappings = [
        ("selenium-tests/test_execution_report.xlsx", "Selenium-Web-E2E-Test-Report.xlsx"),
        ("appium-tests/appium_test_execution_report.xlsx", "Appium-Mobile-E2E-Test-Report.xlsx"),
        ("load-testing/baseline_load_test_report.xlsx", "Baseline-100VU-Load-Test-Report.xlsx"),
        ("Vulnerability Test Results/findings.xlsx", "Security-Assessment-Test-Report.xlsx"),
    ]

    for src_rel, dest_name in mappings:
        src_path = os.path.join(base_dir, src_rel)
        if os.path.exists(src_path):
            shutil.copy2(src_path, os.path.join(sec_folder, dest_name))
            shutil.copy2(src_path, os.path.join(all_reports_dir, dest_name))
            print(f"Copied {dest_name} to Security-Assessment folder.")
        else:
            print(f"Warning: {src_path} does not exist!")

if __name__ == "__main__":
    copy_reports()
