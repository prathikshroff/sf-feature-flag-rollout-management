# Salesforce Feature Flag Management System

A comprehensive feature flag management solution for Salesforce that enables gradual feature rollouts, user-specific feature assignments, and permission-based feature access control.

## 🚀 Features

- **Feature Flag Management**: Create, activate, and manage feature flags through custom objects
- **Gradual Rollouts**: Percentage-based feature rollouts for controlled releases
- **User-Specific Assignments**: Direct feature assignments to individual users
- **Permission-Based Access**: Integration with Salesforce custom permissions and permission sets
- **Lightning Web Component UI**: Modern, responsive interface for managing feature flags
- **Comprehensive Testing**: Full test coverage with edge case handling

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Installation](#installation)
- [Setup](#setup)
- [Usage](#usage)
- [API Reference](#api-reference)
- [Testing](#testing)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## 🏗️ Architecture Overview

### Core Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Feature Flag System                      │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │   FeatureFlag   │  │ FeatureManagement│  │   LWC UI     │ │
│  │     Class       │  │     Class        │  │  Component   │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │ Feature_Flag__c │  │Feature_Flag_    │  │   Custom     │ │
│  │   Custom Object │  │Assignment__c    │  │ Permissions  │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Data Model

- **Feature_Flag__c**: Main feature flag object with activation status and rollout percentage
- **Feature_Flag_Assignment__c**: Junction object for user-specific feature assignments
- **Custom Permissions**: Integration with Salesforce permission system
- **Permission Sets**: Group-based feature access control

## 📦 Installation

### Prerequisites

- Salesforce org with API version 58.0 or higher
- Salesforce CLI (SFDX) installed
- Appropriate permissions to deploy metadata

### Deployment Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd DevHub
   ```

2. **Authenticate with your Salesforce org**
   ```bash
   sfdx auth:web:login -a YourOrgAlias
   ```

3. **Deploy the metadata**
   ```bash
   sfdx force:source:deploy -p force-app/main/default
   ```

4. **Run tests to verify deployment**
   ```bash
   sfdx force:apex:test:run --testlevel RunLocalTests --outputdir test-results
   ```

## ⚙️ Setup

### 1. Create Feature Flags

Navigate to **Setup > Object Manager > Feature Flag** and create your first feature flag:

- **Name**: Unique identifier for the feature
- **Description**: Human-readable description
- **Is Active**: Toggle to enable/disable the feature
- **Percentage Rollout**: Percentage of users who should see the feature (0-100)

### 2. Configure Custom Permissions (Optional)

For permission-based feature access:

1. Go to **Setup > Permission Sets**
2. Create a new permission set
3. Add custom permissions to the permission set
4. Assign the permission set to users

### 3. Add LWC to Lightning Pages

1. Go to **Setup > Lightning App Builder**
2. Edit your desired Lightning page
3. Add the **Feature Flag Manager** component
4. Save and activate the page

## 💻 Usage

### Basic Feature Flag Check

```apex
// Check if a feature is enabled for the current user
Boolean isFeatureEnabled = FeatureFlag.isEnabled('MyNewFeature');

if (isFeatureEnabled) {
    // Show new feature functionality
    showNewFeature();
} else {
    // Show legacy functionality
    showLegacyFeature();
}
```

### Advanced Usage Examples

#### 1. Conditional UI Rendering

```apex
public class MyController {
    @AuraEnabled(cacheable=true)
    public static Boolean isNewUIFeatureEnabled() {
        return FeatureFlag.isEnabled('NewUIFeature');
    }
}
```

```javascript
// In your LWC
import { LightningElement, wire } from 'lwc';
import isNewUIFeatureEnabled from '@salesforce/apex/MyController.isNewUIFeatureEnabled';

export default class MyComponent extends LightningElement {
    @wire(isNewUIFeatureEnabled)
    newUIFeatureEnabled;

    get showNewUI() {
        return this.newUIFeatureEnabled.data;
    }
}
```

#### 2. Gradual Rollout Strategy

```apex
// Start with 10% rollout
Feature_Flag__c flag = new Feature_Flag__c(
    Name = 'BetaFeature',
    Is_Active__c = true,
    Percentage_Rollout__c = 10
);

// Gradually increase to 50%, then 100%
flag.Percentage_Rollout__c = 50;
update flag;
```

#### 3. User-Specific Testing

```apex
// Assign feature to specific users for testing
Feature_Flag_Assignment__c assignment = new Feature_Flag_Assignment__c(
    Feature_Flag__c = featureFlagId,
    User__c = testUserId
);
insert assignment;
```

### Feature Flag Priority Order

The system checks feature flags in the following order:

1. **Direct Assignment**: User has explicit feature flag assignment
2. **Custom Permission**: User has custom permission for the feature
3. **Percentage Rollout**: User falls within the rollout percentage
4. **Default**: Feature is disabled

## 📚 API Reference

### FeatureFlag Class

#### `isEnabled(String featureName)`
Checks if a feature is enabled for the current user.

**Parameters:**
- `featureName` (String): The name of the feature flag

**Returns:**
- `Boolean`: True if the feature is enabled, false otherwise

**Example:**
```apex
Boolean isEnabled = FeatureFlag.isEnabled('MyFeature');
```

### FeatureManagement Class

#### `checkPermission(String permissionName, Id userId)`
Checks if a user has a specific custom permission.

**Parameters:**
- `permissionName` (String): The developer name of the custom permission
- `userId` (Id): The ID of the user to check

**Returns:**
- `Boolean`: True if the user has the permission, false otherwise

**Example:**
```apex
Boolean hasPermission = FeatureManagement.checkPermission('MyCustomPermission', UserInfo.getUserId());
```

## 🎯 Best Practices

### 1. Feature Flag Naming

```apex
// Good naming conventions
FeatureFlag.isEnabled('NewCheckoutFlow');
FeatureFlag.isEnabled('BetaAnalyticsDashboard');
FeatureFlag.isEnabled('EnhancedSearchV2');

// Avoid generic names
FeatureFlag.isEnabled('Feature1'); // ❌ Too generic
FeatureFlag.isEnabled('Test');     // ❌ Too generic
```

### 2. Rollout Strategy

```apex
// Recommended rollout progression
// Phase 1: Internal testing (0-5%)
// Phase 2: Beta users (5-20%)
// Phase 3: Early adopters (20-50%)
// Phase 4: General release (50-100%)
```

### 3. Cleanup Strategy

```apex
// Remove feature flags after full rollout
// 1. Set Percentage_Rollout__c to 100
// 2. Monitor for 2-4 weeks
// 3. Remove feature flag checks from code
// 4. Delete feature flag records
```

### 4. Performance Considerations

```apex
// Cache feature flag results when possible
public class FeatureFlagCache {
    private static Map<String, Boolean> cache = new Map<String, Boolean>();
    
    public static Boolean isEnabled(String featureName) {
        if (!cache.containsKey(featureName)) {
            cache.put(featureName, FeatureFlag.isEnabled(featureName));
        }
        return cache.get(featureName);
    }
}
```

### 5. Error Handling

```apex
// Always handle potential errors
try {
    Boolean isEnabled = FeatureFlag.isEnabled('MyFeature');
    // Use feature flag
} catch (Exception e) {
    // Log error and default to disabled
    System.debug('Feature flag error: ' + e.getMessage());
    // Default behavior
}
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Feature Flag Not Working

**Symptoms**: Feature flag returns false when expected to be true

**Solutions**:
- Check if the feature flag is active (`Is_Active__c = true`)
- Verify the feature flag name matches exactly
- Check for direct user assignments
- Verify custom permissions are properly configured

#### 2. Percentage Rollout Not Working

**Symptoms**: Users not getting features despite percentage rollout

**Solutions**:
- Ensure `Percentage_Rollout__c` is greater than 0
- Check that the feature flag is active
- Verify the rollout percentage is between 0-100

#### 3. Custom Permission Issues

**Symptoms**: Permission-based features not working

**Solutions**:
- Verify custom permission exists
- Check permission set assignments
- Ensure SetupEntityAccess records exist

### Debugging Tips

```apex
// Add debug logging to troubleshoot
System.debug('Feature flag name: ' + featureName);
System.debug('User ID: ' + UserInfo.getUserId());
System.debug('Feature flag active: ' + flag.Is_Active__c);
System.debug('Percentage rollout: ' + flag.Percentage_Rollout__c);
```

### Support

For issues and questions:

1. Check the [Salesforce Developer Documentation](https://developer.salesforce.com/)
2. Review the test classes for usage examples
3. Check the debug logs for error messages
4. Verify org permissions and settings

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

**Note**: This feature flag system is designed for Salesforce orgs and requires appropriate permissions to deploy and use. Always test in a sandbox environment before deploying to production.
