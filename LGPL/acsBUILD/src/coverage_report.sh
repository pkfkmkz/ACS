mkdir -p coverage_reports
shopt -s globstar
cp **/.coverage.* coverage_reports
cd coverage_reports
coverage combine --keep
coverage report > coverage_report_py.txt
