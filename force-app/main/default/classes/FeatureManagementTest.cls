/**
 * @description Test class for FeatureManagement class
 */
@IsTest
private class FeatureManagementTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test users
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User testUser1 = new User(
            ProfileId = p.Id,
            LastName = 'TestUser1',
            Email = 'testuser1@test.com',
            Username = 'testuser1@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'Test User',
            Alias = 'tuser1',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        
        User testUser2 = new User(
            ProfileId = p.Id,
            LastName = 'TestUser2',
            Email = 'testuser2@test.com',
            Username = 'testuser2@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'Test User',
            Alias = 'tuser2',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        
        insert new List<User>{testUser1, testUser2};
    }
    
    @IsTest
    static void testCheckPermission_NonExistentPermission() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'TestUser1' LIMIT 1];
        
        Test.startTest();
        Boolean result = FeatureManagement.checkPermission('NonExistentPermission', testUser.Id);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Non-existent permission should return false');
    }
    
    @IsTest
    static void testCheckPermission_NullPermissionName() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'TestUser1' LIMIT 1];
        
        Test.startTest();
        Boolean result = FeatureManagement.checkPermission(null, testUser.Id);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Null permission name should return false');
    }
    
    @IsTest
    static void testCheckPermission_EmptyPermissionName() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'TestUser1' LIMIT 1];
        
        Test.startTest();
        Boolean result = FeatureManagement.checkPermission('', testUser.Id);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Empty permission name should return false');
    }
    
    @IsTest
    static void testCheckPermission_NullUserId() {
        Test.startTest();
        Boolean result = FeatureManagement.checkPermission('TestPermission', null);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Null user ID should return false');
    }
    
    @IsTest
    static void testCheckPermission_InvalidUserId() {
        Test.startTest();
        Boolean result = FeatureManagement.checkPermission('TestPermission', '001000000000000');
        Test.stopTest();
        
        System.assertEquals(false, result, 'Invalid user ID should return false');
    }
    
    @IsTest
    static void testCheckPermission_UserWithoutPermission() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'TestUser1' LIMIT 1];
        
        Test.startTest();
        Boolean result = FeatureManagement.checkPermission('TestPermission', testUser.Id);
        Test.stopTest();
        
        System.assertEquals(false, result, 'User without permission should return false');
    }
    
    @IsTest
    static void testCheckPermission_WithExistingPermissionSet() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'TestUser1' LIMIT 1];
        
        // Create a permission set (this is allowed in tests)
        PermissionSet permissionSet = new PermissionSet();
        permissionSet.Name = 'TestFeaturePermissionSet';
        permissionSet.Label = 'Test Feature Permission Set';
        permissionSet.Description = 'Permission set for testing feature flags';
        insert permissionSet;
        
        // Assign permission set to user
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = testUser.Id;
        psa.PermissionSetId = permissionSet.Id;
        insert psa;
        
        Test.startTest();
        // Test with a non-existent custom permission (should return false)
        Boolean result = FeatureManagement.checkPermission('NonExistentCustomPermission', testUser.Id);
        Test.stopTest();
        
        System.assertEquals(false, result, 'User with permission set but no custom permission should return false');
    }
    
    @IsTest
    static void testCheckPermission_MultiplePermissionSets() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'TestUser1' LIMIT 1];
        
        // Create multiple permission sets
        List<PermissionSet> permissionSets = new List<PermissionSet>();
        for (Integer i = 0; i < 3; i++) {
            PermissionSet ps = new PermissionSet();
            ps.Name = 'TestFeaturePermissionSet_' + i;
            ps.Label = 'Test Feature Permission Set ' + i;
            ps.Description = 'Permission set for testing feature flags';
            permissionSets.add(ps);
        }
        insert permissionSets;
        
        // Assign only the first permission set to user
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = testUser.Id;
        psa.PermissionSetId = permissionSets[0].Id;
        insert psa;
        
        Test.startTest();
        // Test with a non-existent custom permission (should return false)
        Boolean result = FeatureManagement.checkPermission('NonExistentCustomPermission', testUser.Id);
        Test.stopTest();
        
        System.assertEquals(false, result, 'User with permission set but no custom permission should return false');
    }
    
    @IsTest
    static void testCheckPermission_BulkTest() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'TestUser1' LIMIT 1];
        
        // Test multiple permission checks
        List<String> permissionNames = new List<String>{
            'NonExistentPermission1',
            'NonExistentPermission2',
            'NonExistentPermission3'
        };
        
        Test.startTest();
        List<Boolean> results = new List<Boolean>();
        for (String permissionName : permissionNames) {
            results.add(FeatureManagement.checkPermission(permissionName, testUser.Id));
        }
        Test.stopTest();
        
        System.assertEquals(3, results.size(), 'Should return results for all 3 permissions');
        for (Boolean result : results) {
            System.assertEquals(false, result, 'All non-existent permissions should return false');
        }
    }
    
    @IsTest
    static void testCheckPermission_QueryExceptionHandling() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'TestUser1' LIMIT 1];
        
        Test.startTest();
        // Test with a very long permission name that might cause issues
        String longPermissionName = 'A'.repeat(255);
        Boolean result = FeatureManagement.checkPermission(longPermissionName, testUser.Id);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Very long permission name should return false');
    }
    
    @IsTest
    static void testCheckPermission_CurrentUser() {
        // Test with the current running user
        Test.startTest();
        Boolean result = FeatureManagement.checkPermission('TestPermission', UserInfo.getUserId());
        Test.stopTest();
        
        System.assertEquals(false, result, 'Current user without permission should return false');
    }
} 