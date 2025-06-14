import { LightningElement, wire } from 'lwc';
import { getListUi } from 'lightning/uiListApi';

const COLUMNS = [
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Description', fieldName: 'Description__c', type: 'text' },
    { label: 'Is Active', fieldName: 'Is_Active__c', type: 'boolean' },
    { label: 'Percentage Rollout', fieldName: 'Percentage_Rollout__c', type: 'number' }
];

export default class FeatureFlagManager extends LightningElement {
    columns = COLUMNS;
    featureFlags = [];

    @wire(getListUi, {
        objectApiName: 'Feature_Flag__c',
        listViewApiName: 'All_Feature_Flags' // Replace with your list view API name
    })
    wiredFeatureFlags({ error, data }) {
        if (data) {
            this.featureFlags = data.records.records.map(record => {
                return {
                    Id: record.id,
                    Name: record.fields.Name.value,
                    Description__c: record.fields.Description__c.value,
                    Is_Active__c: record.fields.Is_Active__c.value,
                    Percentage_Rollout__c: record.fields.Percentage_Rollout__c.value
                };
            });
        } else if (error) {
            console.error(error);
        }
    }
}