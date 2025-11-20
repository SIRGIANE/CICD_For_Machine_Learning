install:
	pip install --upgrade pip &&\
		pip install -r requirements.txt

format: install
	black --check --diff *.py || black *.py

train:
	python train.py

eval:
	echo "## Model Metrics" > report.md
	cat ./Results/metrics.txt >> report.md
	echo '\n## Confusion Matrix Plot' >> report.md
	echo '![Confusion Matrix](./Results/model_results.png)' >> report.md
	cml comment create report.md

update-branch:
	@echo "Configuring git for CI environment..."
	git config --global user.name "${USER_NAME:-github-actions[bot]}"
	git config --global user.email "${USER_EMAIL:-github-actions[bot]@users.noreply.github.com}"
	@echo "Checking for changes..."
	@if git diff --quiet && git diff --cached --quiet; then \
		echo "No changes to commit"; \
	else \
		echo "Committing changes..."; \
		git add -A; \
		git commit -m "Update with new results [skip ci]"; \
		echo "Pushing to update branch..."; \
		git push origin HEAD:update || git push --set-upstream origin update; \
	fi

HF_USER ?= wissal098
HF_SPACE ?= Drug_Classification
SPACE_REPO := $(HF_USER)/$(HF_SPACE)
HF_CMD ?= huggingface-cli

# Robust Hugging Face login: handle missing 'update' branch
hf-login:
	git fetch origin
	@if git ls-remote --exit-code origin update; then \
		echo "Remote update branch exists"; \
		git switch update || git switch -c update --track origin/update; \
	else \
		echo "Remote update branch missing - using current branch"; \
	fi
	pip install --upgrade huggingface_hub
	$(HF_CMD) login --token $(HF) --add-to-git-credential

push-hub:
	# Upload Gradio app entrypoint as app.py at repo root
	$(HF_CMD) upload $(SPACE_REPO) ./App/drug_app.py /app.py --repo-type=space --commit-message="Update app.py"
	# Upload Space runtime requirements
	$(HF_CMD) upload $(SPACE_REPO) ./App/requirements.txt /requirements.txt --repo-type=space --commit-message="Update requirements"
	# Optional README for Space
	$(HF_CMD) upload $(SPACE_REPO) ./App/README /README.md --repo-type=space --commit-message="Update README"
	# Upload model artifacts into /Model
	$(HF_CMD) upload $(SPACE_REPO) ./Model /Model --repo-type=space --commit-message="Sync Model"
	# Upload results/metrics into /Results
	$(HF_CMD) upload $(SPACE_REPO) ./Results /Results --repo-type=space --commit-message="Sync Results"

deploy: hf-login push-hub