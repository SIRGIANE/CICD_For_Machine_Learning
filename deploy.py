#!/usr/bin/env python3
"""Deploy to Hugging Face Space"""
import os
import sys
from pathlib import Path
from huggingface_hub import HfApi

def main():
    # Get token from environment
    token = os.environ.get('HF_TOKEN')
    if not token:
        print("Error: Missing HF_TOKEN environment variable")
        sys.exit(1)
    
    # Initialize API
    api = HfApi(token=token)
    repo_id = 'wissal098/Drug_Classification'
    
    # Create Space
    print(f'Creating/verifying Space: {repo_id}')
    api.create_repo(repo_id=repo_id, repo_type='space', exist_ok=True)
    print('✓ Space ready')
    
    # Upload application files
    print('\nUploading application files...')
    api.upload_file(
        path_or_fileobj='App/drug_app.py',
        path_in_repo='app.py',
        repo_id=repo_id,
        repo_type='space',
        commit_message='Update application'
    )
    print('✓ app.py uploaded')
    
    api.upload_file(
        path_or_fileobj='App/requirements.txt',
        path_in_repo='requirements.txt',
        repo_id=repo_id,
        repo_type='space',
        commit_message='Update requirements'
    )
    print('✓ requirements.txt uploaded')
    
    # Upload README if exists
    readme_path = Path('App/README')
    if readme_path.exists():
        api.upload_file(
            path_or_fileobj='App/README',
            path_in_repo='README.md',
            repo_id=repo_id,
            repo_type='space',
            commit_message='Update README'
        )
        print('✓ README.md uploaded')
    
    # Upload Model folder
    print('\nUploading Model folder...')
    api.upload_folder(
        folder_path='Model',
        path_in_repo='Model',
        repo_id=repo_id,
        repo_type='space',
        commit_message='Update model artifacts'
    )
    print('✓ Model uploaded')
    
    # Upload Results folder
    print('\nUploading Results folder...')
    api.upload_folder(
        folder_path='Results',
        path_in_repo='Results',
        repo_id=repo_id,
        repo_type='space',
        commit_message='Update results and metrics'
    )
    print('✓ Results uploaded')
    
    print('\n✅ Deployment completed successfully')
    print(f'🚀 Space URL: https://huggingface.co/spaces/{repo_id}')

if __name__ == '__main__':
    main()
