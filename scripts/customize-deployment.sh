#!/bin/bash

echo -e "\e[36mCustomize your Azure deployment environment\e[0m"

# Helper function to set environment variables
set_env_variable() {
    local name=$1
    local prompt=$2
    read -p "$prompt: " value
    if [[ -n "$value" ]]; then
        azd env set "$name" "$value"
        echo -e "\e[32mSet $name to $value\e[0m"
    else
        echo -e "\e[33mSkipped setting $name\e[0m"
    fi
}

# Choose deployment type
echo -e "\n\e[36mChoose your deployment type:\e[0m"
echo "1. Use existing Azure resources"
echo "2. Enable optional features (auth, vision, etc.)"
echo "3. Deploy low-cost options"
echo "4. Deploy with Azure free trial"
echo "5. Deploy as-is without any customizations"
read -p "Enter your choice (1-5): " deployment_choice

case $deployment_choice in
    1)
        echo -e "\n\e[36mConfiguring existing Azure resources...\e[0m"
        set_env_variable "AZURE_RESOURCE_GROUP" "Existing Azure Resource Group name"
        set_env_variable "AZURE_LOCATION" "Existing Azure Resource Group location (e.g., eastus)"
        set_env_variable "AZURE_OPENAI_SERVICE" "Existing Azure OpenAI Service name"
        set_env_variable "AZURE_SEARCH_SERVICE" "Existing Azure AI Search Service name"
        set_env_variable "AZURE_APP_SERVICE_PLAN" "Existing Azure App Service Plan name"
        set_env_variable "AZURE_APP_SERVICE" "Existing Azure App Service name"
        ;;
    2)
        echo -e "\n\e[36mEnabling optional features...\e[0m"
        read -p "Enable authentication? (true/false): " use_auth
        azd env set AZURE_USE_AUTHENTICATION "$use_auth"

        if [[ "$use_auth" == "true" ]]; then
            read -p "Enforce document-level access control? (true/false): " enforce_acl
            azd env set AZURE_ENFORCE_ACCESS_CONTROL "$enforce_acl"
        fi

        read -p "Enable GPT-4 Turbo with Vision? (true/false): " use_vision
        azd env set USE_GPT4V "$use_vision"

        read -p "Enable speech input? (true/false): " speech_input
        azd env set USE_SPEECH_INPUT_BROWSER "$speech_input"

        read -p "Enable speech output? (true/false): " speech_output
        azd env set USE_SPEECH_OUTPUT_BROWSER "$speech_output"
        ;;
    3)
        echo -e "\n\e[36mConfiguring low-cost deployment options...\e[0m"
        azd env set DEPLOYMENT_TARGET appservice
        azd env set AZURE_APP_SERVICE_SKU F1
        azd env set AZURE_SEARCH_SERVICE_SKU free
        azd env set AZURE_DOCUMENTINTELLIGENCE_SKU F0
        azd env set AZURE_COSMOSDB_SKU free
        echo -e "\e[32mConfigured low-cost SKUs.\e[0m"
        ;;
    4)
        echo -e "\n\e[36mConfiguring Azure free trial deployment...\e[0m"
        azd env set AZURE_OPENAI_CHATGPT_DEPLOYMENT_CAPACITY 1
        azd env set AZURE_OPENAI_EMB_DEPLOYMENT_CAPACITY 1
        azd env set DEPLOYMENT_TARGET appservice
        echo -e "\e[32mConfigured Azure free trial settings.\e[0m"
        ;;
    5)
        echo -e "\n\e[36mUsing default deployment settings.\e[0m"
        read -p "This will deploy without any customization. Are you ok to proceed? (Y/N): " deploy_default
        
        if [[ "$deploy_default" == "Y" || "$deploy_default" == "y" ]]; then
            echo -e "\e[32mProceeding with default deployment settings.\e[0m"
            azd up
        else
            echo -e "\e[31mExiting.\e[0m"
            exit 1
        fi
        ;;
    *)
        echo -e "\e[31mInvalid choice. Exiting.\e[0m"
        exit 1
        ;;
esac

echo -e "\n\e[36mConfigurations initialized. Refer to more instruction links for additional customizations based on your choice and modify environment variables before running 'azd up' to deploy.\e[0m"