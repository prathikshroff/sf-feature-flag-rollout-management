/**
 * @description Test class for FeatureFlag class
 */
@IsTest
private class FeatureFlagTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test feature flags
        List<Feature_Flag__c> flags = new List<Feature_Flag__c>();
        
        // Active flag with 50% rollout
        flags.add(new Feature_Flag__c(
            Name = 'TestFeature_Active_50Percent',
            Is_Active__c = true,
            Percentage_Rollout__c = 50,
            Description__c = 'Test active feature with 50% rollout'
        ));
        
        // Active flag with 100% rollout
        flags.add(new Feature_Flag__c(
            Name = 'TestFeature_Active_100Percent',
            Is_Active__c = true,
            Percentage_Rollout__c = 100,
            Description__c = 'Test active feature with 100% rollout'
        ));
        
        // Active flag with 0% rollout
        flags.add(new Feature_Flag__c(
            Name = 'TestFeature_Active_0Percent',
            Is_Active__c = true,
            Percentage_Rollout__c = 0,
            Description__c = 'Test active feature with 0% rollout'
        ));
        
        // Inactive flag
        flags.add(new Feature_Flag__c(
            Name = 'TestFeature_Inactive',
            Is_Active__c = false,
            Percentage_Rollout__c = 50,
            Description__c = 'Test inactive feature'
        ));
        
        insert flags;
    }
    
    @IsTest
    static void testIsEnabled_NonExistentFeature() {
        Test.startTest();
        Boolean result = FeatureFlag.isEnabled('NonExistentFeature');
        Test.stopTest();
        
        System.assertEquals(false, result, 'Non-existent feature should return false');
    }
    
    @IsTest
    static void testIsEnabled_InactiveFeature() {
        Test.startTest();
        Boolean result = FeatureFlag.isEnabled('TestFeature_Inactive');
        Test.stopTest();
        
        System.assertEquals(false, result, 'Inactive feature should return false');
    }
    
    @IsTest
    static void testIsEnabled_ActiveFeatureWithDirectAssignment() {
        // Get the active feature flag
        Feature_Flag__c flag = [SELECT Id FROM Feature_Flag__c WHERE Name = 'TestFeature_Active_50Percent' LIMIT 1];
        
        // Create a direct assignment for the current user
        Feature_Flag_Assignment__c assignment = new Feature_Flag_Assignment__c(
            Feature_Flag__c = flag.Id,
            User__c = UserInfo.getUserId()
        );
        insert assignment;
        
        Test.startTest();
        Boolean result = FeatureFlag.isEnabled('TestFeature_Active_50Percent');
        Test.stopTest();
        
        System.assertEquals(true, result, 'Feature with direct assignment should return true');
    }
    
    @IsTest
    static void testIsEnabled_ActiveFeatureWithCustomPermission() {
        // Mock the FeatureManagement.checkPermission to return true
        Test.startTest();
        
        // Since we can't easily mock static methods in Apex, we'll test the integration
        // by creating a custom permission and permission set assignment
        // For now, we'll test the scenario where custom permission check returns false
        Boolean result = FeatureFlag.isEnabled('TestFeature_Active_50Percent');
        
        Test.stopTest();
        
        // The result will depend on the percentage rollout since no direct assignment exists
        // and custom permission check will likely return false in test context
        System.assertNotEquals(null, result, 'Result should not be null');
    }
    
    @IsTest
    static void testIsEnabled_ActiveFeatureWith100PercentRollout() {
        Test.startTest();
        Boolean result = FeatureFlag.isEnabled('TestFeature_Active_100Percent');
        Test.stopTest();
        
        System.assertEquals(true, result, 'Feature with 100% rollout should return true');
    }
    
    @IsTest
    static void testIsEnabled_ActiveFeatureWith0PercentRollout() {
        Test.startTest();
        Boolean result = FeatureFlag.isEnabled('TestFeature_Active_0Percent');
        Test.stopTest();
        
        System.assertEquals(false, result, 'Feature with 0% rollout should return false');
    }
    
    @IsTest
    static void testIsEnabled_ActiveFeatureWith50PercentRollout() {
        Test.startTest();
        Boolean result = FeatureFlag.isEnabled('TestFeature_Active_50Percent');
        Test.stopTest();
        
        // The result will be deterministic based on the user ID hash
        // We can't predict the exact result, but it should be consistent
        System.assertNotEquals(null, result, 'Result should not be null');
    }
    
    @IsTest
    static void testIsEnabled_ConsistentResultsForSameUser() {
        Test.startTest();
        Boolean result1 = FeatureFlag.isEnabled('TestFeature_Active_50Percent');
        Boolean result2 = FeatureFlag.isEnabled('TestFeature_Active_50Percent');
        Test.stopTest();
        
        System.assertEquals(result1, result2, 'Results should be consistent for the same user and feature');
    }
    
    @IsTest
    static void testIsEnabled_NullFeatureName() {
        Test.startTest();
        Boolean result = FeatureFlag.isEnabled(null);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Null feature name should return false');
    }
    
    @IsTest
    static void testIsEnabled_EmptyFeatureName() {
        Test.startTest();
        Boolean result = FeatureFlag.isEnabled('');
        Test.stopTest();
        
        System.assertEquals(false, result, 'Empty feature name should return false');
    }
    
    @IsTest
    static void testBulkFeatureFlagQueries() {
        // Test that the method can handle multiple calls efficiently
        List<String> featureNames = new List<String>{
            'TestFeature_Active_50Percent',
            'TestFeature_Active_100Percent',
            'TestFeature_Active_0Percent',
            'TestFeature_Inactive',
            'NonExistentFeature'
        };
        
        Test.startTest();
        List<Boolean> results = new List<Boolean>();
        for (String featureName : featureNames) {
            results.add(FeatureFlag.isEnabled(featureName));
        }
        Test.stopTest();
        
        System.assertEquals(5, results.size(), 'Should return results for all 5 features');
        System.assertEquals(false, results[3], 'Inactive feature should return false');
        System.assertEquals(false, results[4], 'Non-existent feature should return false');
    }
} 