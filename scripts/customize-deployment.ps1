# scripts/customize-deployment.ps1

Write-Host "Customize your Azure deployment environment" -ForegroundColor Cyan

# Helper function to set environment variables
function Set-EnvVariable($name, $prompt) {
    $value = Read-Host $prompt
    if (![string]::IsNullOrWhiteSpace($value)) {
        azd env set $name $value
        Write-Host "Set $name to $value" -ForegroundColor Green
    } else {
        Write-Host "Skipped setting $name" -ForegroundColor Yellow
    }
}

# Choose deployment type
Write-Host "`nChoose your deployment type:" -ForegroundColor Cyan
Write-Host "1. Use existing Azure resources"
Write-Host "2. Enable optional features (auth, vision, etc.)"
Write-Host "3. Deploy low-cost options"
Write-Host "4. Deploy with Azure free trial"
Write-Host "5. Deploy as-is without any customizations"
$deploymentChoice = Read-Host "Enter your choice (1-5)"

switch ($deploymentChoice) {
    "1" {
        Write-Host "`nConfiguring existing Azure resources..." -ForegroundColor Cyan
        Set-EnvVariable "AZURE_RESOURCE_GROUP" "Existing Azure Resource Group name"
        Set-EnvVariable "AZURE_LOCATION" "Existing Azure Resource Group location (e.g., eastus)"
        Set-EnvVariable "AZURE_OPENAI_SERVICE" "Existing Azure OpenAI Service name"
        Set-EnvVariable "AZURE_SEARCH_SERVICE" "Existing Azure AI Search Service name"
        Set-EnvVariable "AZURE_APP_SERVICE_PLAN" "Existing Azure App Service Plan name"
        Set-EnvVariable "AZURE_APP_SERVICE" "Existing Azure App Service name"
    }
    "2" {
        Write-Host "`nEnabling optional features..." -ForegroundColor Cyan
        $useAuth = Read-Host "Enable authentication? (true/false)"
        azd env set AZURE_USE_AUTHENTICATION $useAuth

        if ($useAuth -eq "true") {
            $enforceAcl = Read-Host "Enforce document-level access control? (true/false)"
            azd env set AZURE_ENFORCE_ACCESS_CONTROL $enforceAcl
        }

        $useVision = Read-Host "Enable GPT-4 Turbo with Vision? (true/false)"
        azd env set USE_GPT4V $useVision

        $speechInput = Read-Host "Enable speech input? (true/false)"
        azd env set USE_SPEECH_INPUT_BROWSER $speechInput

        $speechOutput = Read-Host "Enable speech output? (true/false)"
        azd env set USE_SPEECH_OUTPUT_BROWSER $speechOutput
    }
    "3" {
        Write-Host "`nConfiguring low-cost deployment options..." -ForegroundColor Cyan
        azd env set DEPLOYMENT_TARGET appservice
        azd env set AZURE_APP_SERVICE_SKU F1
        azd env set AZURE_SEARCH_SERVICE_SKU free
        azd env set AZURE_DOCUMENTINTELLIGENCE_SKU F0
        azd env set AZURE_COSMOSDB_SKU free
        Write-Host "Configured low-cost SKUs." -ForegroundColor Green
    }
    "4" {
        Write-Host "`nConfiguring Azure free trial deployment..." -ForegroundColor Cyan
        azd env set AZURE_OPENAI_CHATGPT_DEPLOYMENT_CAPACITY 1
        azd env set AZURE_OPENAI_EMB_DEPLOYMENT_CAPACITY 1
        azd env set DEPLOYMENT_TARGET appservice
        Write-Host "Configured Azure free trial settings." -ForegroundColor Green
    }
    "5" {
        Write-Host "`nUsing default deployment settings." -ForegroundColor Cyan
        $deployDefault = Read-Host "This will deploy without any customization. Are you ok to proceed ? (Y/N)"
        
        if ($deployDefault -eq "Y" -or $deployDefault -eq "y") {
            Write-Host "Proceeding with default deployment settings." -ForegroundColor Green
            azd up
        } else {
            Write-Host "Exiting." -ForegroundColor Red
            exit 1
        }
    }

    Default {
        Write-Host "Invalid choice. Exiting." -ForegroundColor Red
        exit 1
    }
}

Write-Host "`nConfigurations initialized, also refer to more instruction links for additional customizations based on your choice and modify environment variables before running 'azd up' to deploy." -ForegroundColor Cyan