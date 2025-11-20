install:
	pip install --upgrade pip &&\
		pip install -r requirements.txt

format:	
	black *.py 

train:
	python train.py

eval:
	echo "## Model Metrics" > report.md
	cat ./Results/metrics.txt >> report.md
	
	echo '\n## Confusion Matrix Plot' >> report.md
	echo '![Confusion Matrix](./Results/model_results.png)' >> report.md
	
	cml comment create report.md
		
update-branch:
	git config --global user.name $(USER_NAME)
	git config --global user.email $(USER_EMAIL)
	git commit -am "Update with new results"
	git push --force origin HEAD:update

HF_USER ?= wissal098
HF_SPACE ?= Drug_Classification
SPACE_REPO := $(HF_USER)/$(HF_SPACE)

deploy:
	@if [ -z "$(HF)" ]; then echo "Error: HF token missing. Usage: make deploy HF=your_token"; exit 1; fi
	@echo "Installing huggingface_hub..."
	@pip install --upgrade huggingface_hub
	@echo "Deploying to Hugging Face Space: $(SPACE_REPO)"
	@python3 -c 'import os; from huggingface_hub import HfApi; from pathlib import Path; api = HfApi(token=os.environ["HF"]); repo_id = "$(SPACE_REPO)"; print(f"Creating Space: {repo_id}"); api.create_repo(repo_id=repo_id, repo_type="space", space_sdk="gradio", exist_ok=True); print("Uploading app.py..."); api.upload_file(path_or_fileobj="App/drug_app.py", path_in_repo="app.py", repo_id=repo_id, repo_type="space", commit_message="Update app"); print("Uploading requirements.txt..."); api.upload_file(path_or_fileobj="App/requirements.txt", path_in_repo="requirements.txt", repo_id=repo_id, repo_type="space", commit_message="Update requirements"); readme = Path("App/README"); api.upload_file(path_or_fileobj="App/README", path_in_repo="README.md", repo_id=repo_id, repo_type="space", commit_message="Update README") if readme.exists() else None; print("Uploading Model folder..."); api.upload_folder(folder_path="Model", path_in_repo="Model", repo_id=repo_id, repo_type="space", commit_message="Update model"); print("Uploading Results folder..."); api.upload_folder(folder_path="Results", path_in_repo="Results", repo_id=repo_id, repo_type="space", commit_message="Update results"); print("✅ Deployment complete!"); print(f"🚀 https://huggingface.co/spaces/{repo_id}");'

all: install format train eval update-branch deploy