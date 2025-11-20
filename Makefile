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

hf-login:
	git pull origin update
	git switch update
	pip install -U "huggingface_hub[cli]"
	huggingface-cli login --token $(HF) --add-to-git-credential

push-hub:
	huggingface-cli upload kingabzpro/Drug-Classification ./App --repo-type=space --commit-message="Sync App files"
	huggingface-cli upload kingabzpro/Drug-Classification ./Model /Model --repo-type=space --commit-message="Sync Model"
	huggingface-cli upload kingabzpro/Drug-Classification ./Results /Metrics --repo-type=space --commit-message="Sync Model"

deploy: hf-login push-hub