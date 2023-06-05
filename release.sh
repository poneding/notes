# generate gitbook summary
gitbook-summary-generator start -f --summary-title Notes --readme-title Notes

# push to github
git pull && git add . && git commit -m "." && git push