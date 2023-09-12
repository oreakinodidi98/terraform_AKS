
$env:GITHUB_TOKEN="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"
git init --initial-branch=main
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/oreakinodidi98/terraform_AKS.git
git push -u origin main
git rm terraform.tfstate
git rm terraform.tfstate.backup