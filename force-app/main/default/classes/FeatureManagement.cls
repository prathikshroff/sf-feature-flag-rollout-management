public class FeatureManagement {
    /**
     * @description Checks if a user has a specific custom permission.
     * @param permissionName The name of the custom permission.
     * @param userId The ID of the user to check.
     * @return True if the user has the custom permission, false otherwise.
     */
    public static Boolean checkPermission(String permissionName, Id userId) {
        // Query the CustomPermission object to get the ID of the permission
        CustomPermission customPermission = [SELECT Id FROM CustomPermission WHERE DeveloperName = :permissionName LIMIT 1];

        if (customPermission == null) {
            return false; // Custom permission not found
        }    

        Set<Id> permissionSetIds = new Set<Id>();
        for (SetupEntityAccess sea : [
            SELECT ParentId
            FROM SetupEntityAccess
            WHERE SetupEntityId IN (                
                SELECT Id
                FROM CustomPermission
                WHERE DeveloperName = :permissionName
            )
        ]) {
            permissionSetIds.add(sea.ParentId);
        }

        // Check if the user has any of the permission sets
        List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();        
        if( !permissionSetIds.isEmpty()) {
            permissionSetAssignments = [
                SELECT AssigneeId
                FROM PermissionSetAssignment
                WHERE AssigneeId = :userId AND PermissionSetId IN :permissionSetIds
            ];            
        }
        return !permissionSetAssignments.isEmpty();
    }
}