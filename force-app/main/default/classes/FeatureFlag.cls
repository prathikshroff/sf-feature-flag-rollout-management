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
        List<Feature_Flag__c> flags = [SELECT Id, Is_Active__c, Percentage_Rollout__c FROM Feature_Flag__c WHERE Name = :featureName LIMIT 1];
        if (flags.isEmpty()) return false;
        Feature_Flag__c flag = flags[0];

        if (flag == null || !flag.Is_Active__c) {
            return false;
        }

        // 2. Check if the current user has a direct assignment.
        if ([SELECT Id FROM Feature_Flag_Assignment__c WHERE Feature_Flag__c = :flag.Id AND User__c = :UserInfo.getUserId() LIMIT 1].size() > 0) {
            return true;
        }

        // 3. Check if the current user's profile has a permission set assignment.
        // Get the User's Profile Id
        String profileId = UserInfo.getProfileId();

        // Check if the user has a permission set assigned that is associated with the feature flag
        List<PermissionSetAssignment> permSetAssignments = [SELECT AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()];
        Set<Id> permissionSetIds = new Set<Id>();
        for(PermissionSetAssignment psa : permSetAssignments){
            permissionSetIds.add(psa.PermissionSetId);
        }

        // Query all Custom Permissions
        List<CustomPermission> customPermissions = [SELECT Id, DeveloperName FROM CustomPermission WHERE NamespacePrefix = null];
        Set<String> customPermissionNames = new Set<String>();
        for(CustomPermission cp : customPermissions){
            customPermissionNames.add(cp.DeveloperName);
        }

        // Check if the feature flag is enabled via custom permission
        if(customPermissionNames.contains(featureName)){
            return FeatureManagement.checkPermission(featureName, UserInfo.getUserId());
        }

        // 4. Check the percentage rollout.
        if (flag.Percentage_Rollout__c > 0) {
            // Use the user's ID to generate a random number.
            // Get the User Id and convert it to a decimal
            String userId = UserInfo.getUserId();
            Integer userIdInt = 0;
            for(Integer i = 0; i < userId.length(); i++){
                userIdInt += userId.substring(i, i+1).charAt(0);
            }

            // Generate a random number between 0 and 99
            Decimal randomNumber = math.mod(userIdInt, 100);

            // Compare the random number to the Percentage_Rollout__c value.
            if (randomNumber < flag.Percentage_Rollout__c) {
                return true;
            }
        }

        // 5. Return false if none of the above conditions are met.
        return false;
    }
}