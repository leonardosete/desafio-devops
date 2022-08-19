name: Deploy GKE App
on:
  # pull_request:
  #   branches: [develop, master]
  push:
    branches: [develop, master]

  workflow_dispatch:
    inputs:
      should-destroy:
        description: 'Run terraform destroy -auto-approve? (desmarcado = false)'
        default: false
        required: false
        type: boolean
  
jobs:
  create_gke_cluster:
    runs-on: ubuntu-latest
    env:
      # tf_actions_working_dir: "./infra-gcp/terraform/"
      tf_actions_working_dir: "./terraform-gke/"
    ## Add "id-token" with the intended permissions.
    permissions:
      contents: read
      id-token: write

    defaults:
      run:
        working-directory: ${{ env.tf_actions_working_dir }}

    steps:
      - name: Checkout Actions
        uses: actions/checkout@v3

      - id: auth
        name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v0
        with:
          credentials_json: ${{ secrets.GCP_CREDENTIALS }}

      - name: Set up Cloud SDK
        uses: google-github-actions/setup-gcloud@v0
          
      - name: Install Kubectl
        run: |
          gcloud components install gke-gcloud-auth-plugin --quiet
          gcloud container clusters get-credentials tembici-devops-sre-prod --region us-central1 --project xenon-axe-359616

      - name: Run Kubectl
        run: kubectl get nodes
