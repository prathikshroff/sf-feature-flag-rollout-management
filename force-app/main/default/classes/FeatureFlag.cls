/**
 * @description Central class for checking feature flag status.
 */
public class FeatureFlag {
    /**
     * @description Checks if a feature is enabled for the current user.
     * @param featureName The name of the feature flag.
     * @return True if the feature is enabled, false otherwise.
     */
    public static Boolean isEnabled(String featureName) {
        // 1. Check if the feature flag is active.
        Feature_Flag__c flag = getFeatureFlag(featureName);
        if (flag == null || !isFeatureFlagActive(flag)) {
            return false;
        }

        // 2. Check if the current user has a direct assignment.
        if (hasDirectAssignment(flag.Id)) {
            return true;
        }

        // 3. Check if the current user has the feature enabled via custom permission
        if (hasCustomPermission(featureName)) {
            return true;
        }

        // 4. Check the percentage rollout.
        if (isInRolloutPercentage(flag)) {
            return true;
        }

        // 5. Return false if none of the above conditions are met.
        return false;
    }

    /**
     * @description Retrieves the feature flag record by name.
     * @param featureName The name of the feature flag.
     * @return The feature flag record, or null if not found.
     */
    private static Feature_Flag__c getFeatureFlag(String featureName) {
        List<Feature_Flag__c> flags = [SELECT Id, Is_Active__c, Percentage_Rollout__c 
                                      FROM Feature_Flag__c 
                                      WHERE Name = :featureName 
                                      LIMIT 1];
        return flags.isEmpty() ? null : flags[0];
    }

    /**
     * @description Checks if the feature flag is active.
     * @param flag The feature flag record.
     * @return True if the flag is active, false otherwise.
     */
    private static Boolean isFeatureFlagActive(Feature_Flag__c flag) {
        return flag != null && flag.Is_Active__c;
    }

    /**
     * @description Checks if the current user has a direct assignment for this feature flag.
     * @param flagId The ID of the feature flag.
     * @return True if the user has a direct assignment, false otherwise.
     */
    private static Boolean hasDirectAssignment(Id flagId) {
        List<Feature_Flag_Assignment__c> assignments = [
            SELECT Id 
            FROM Feature_Flag_Assignment__c 
            WHERE Feature_Flag__c = :flagId 
            AND User__c = :UserInfo.getUserId() 
            LIMIT 1
        ];
        return !assignments.isEmpty();
    }

    /**
     * @description Checks if the current user has the custom permission for this feature.
     * @param featureName The name of the feature flag.
     * @return True if the user has the custom permission, false otherwise.
     */
    private static Boolean hasCustomPermission(String featureName) {
        return FeatureManagement.checkPermission(featureName, UserInfo.getUserId());
    }

    /**
     * @description Checks if the current user is within the percentage rollout for this feature flag.
     * @param flag The feature flag record.
     * @return True if the user is within the rollout percentage, false otherwise.
     */
    private static Boolean isInRolloutPercentage(Feature_Flag__c flag) {
        if (flag.Percentage_Rollout__c <= 0) {
            return false;
        }

        // Generate a deterministic random number based on user ID
        Integer userHash = generateUserHash();
        Decimal randomNumber = Math.mod(userHash, 100);

        // Check if the user falls within the rollout percentage
        return randomNumber < flag.Percentage_Rollout__c;
    }

    /**
     * @description Generates a hash value from the current user's ID for consistent rollout distribution.
     * @return An integer hash value.
     */
    private static Integer generateUserHash() {
        String userId = UserInfo.getUserId();
        Integer hash = 0;
        for (Integer i = 0; i < userId.length(); i++) {
            hash += userId.substring(i, i + 1).charAt(0);
        }
        return hash;
    }
}