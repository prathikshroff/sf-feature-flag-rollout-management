# sf-feature-flag-rollout-management

An enterprise-grade feature flag system for Salesforce.

## Overview

This project provides a framework for managing feature flags and controlling feature rollouts in a Salesforce environment. It allows you to enable or disable features for specific users or a percentage of your user base without deploying new code.

## Key Features

*   **Custom Permissions:** Uses Custom Permissions as the core flag mechanism for easy checking in Apex/Flows.
*   **LWC UI:** Provides a Lightning Web Component (LWC) for admins to manage the flags: activate them, assign them to users, and set a percentage rollout (e.g., "Enable for 10% of users").
*   **Central Apex Class:** Includes a central Apex class `FeatureFlag.isEnabled('MyNewFeature')` that is easy for developers to use.

## Components

*   **`FeatureFlag.cls`:** Apex class that provides the `isEnabled()` method for checking feature flag status. It checks for active flags, user assignments, and permission set assignments. It also handles percentage rollouts.
*   **`FeatureManagement.cls`:** Apex class that checks if a user has a specific custom permission. This is used to determine if a user has access to a feature based on their permission sets.
*   **`featureFlagManager` LWC:** Lightning Web Component for managing feature flags.
    *   `featureFlagManager.js`: JavaScript controller for the LWC. It uses `lightning/uiListApi` to retrieve feature flags and allows admins to create and update feature flags.
    *   `featureFlagManager.html`: HTML template for the LWC. It displays the feature flags in a `lightning-datatable` and allows editing.

## Setup Instructions

1.  **Create Custom Objects:** Create the `Feature_Flag__c` and `Feature_Flag_Assignment__c` custom objects.
    *   `Feature_Flag__c` fields:
        *   `Description__c` (Text Area): Description of the feature flag.
        *   `Is_Active__c` (Checkbox): Indicates whether the flag is active.
        *   `Percentage_Rollout__c` (Number): Percentage of users to enable the flag for (0-100).
    *   `Feature_Flag_Assignment__c` fields:
        *   `Feature_Flag__c` (Lookup to `Feature_Flag__c`): The feature flag being assigned.
        *   `User__c` (Lookup to User): The user to assign the flag to (optional).
2.  **Create a list view named `All_Feature_Flags` for the `Feature_Flag__c` object:**
    *   Go to Setup -> Object Manager -> Feature Flag -> List Views.
    *   Click "New" and create a list view named "All Feature Flags".
    *   Make sure all Feature Flag records are visible in this list view.
3.  **Create Custom Permissions for each feature flag:**
    *   Go to Setup -> Custom Permissions.
    *   Click "New" and create a custom permission for each feature flag.
    *   Use the same name for the custom permission as the feature flag name (e.g., "MyNewFeature").
4.  **Create a Permission Set for each feature flag and assign the corresponding Custom Permission to it:**
    *   Go to Setup -> Permission Sets.
    *   Click "New" and create a permission set for each feature flag.
    *   In the permission set, go to "Custom Permission" and enable the corresponding custom permission.
5.  **Deploy the Apex classes and LWC to your Salesforce org:**
    *   Use Salesforce DX or a similar deployment tool to deploy the components to your org.
6.  **Add the LWC to a Lightning page:**
    *   Edit a Lightning page and drag the `featureFlagManager` LWC onto the page.

## Usage

1.  Create a new Feature Flag record in Salesforce.
2.  Create a Custom Permission with the same name as the Feature Flag.
3.  Create a Permission Set and assign the Custom Permission to it.
4.  Assign the Permission Set to the users who should have the feature enabled.
5.  Use the `FeatureFlag.isEnabled('MyNewFeature')` method in your Apex code to check if the feature is enabled for the current user.

## Code Snippets

**Apex: Checking if a feature is enabled**

```apex
if (FeatureFlag.isEnabled('MyNewFeature')) {
    // Run the new feature code
} else {
    // Run the old code
}
```

**LWC: Displaying Feature Flags**

The `featureFlagManager` LWC displays a list of feature flags and allows admins to manage them.
