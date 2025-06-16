import { LightningElement, wire } from 'lwc';
import { getListUi } from 'lightning/uiListApi';
import { createRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'Name', fieldName: 'Name', type: 'text', editable: true },
    { label: 'Description', fieldName: 'Description__c', type: 'text', editable: true },
    { label: 'Is Active', fieldName: 'Is_Active__c', type: 'boolean', editable: true },
    { label: 'Percentage Rollout', fieldName: 'Percentage_Rollout__c', type: 'number', editable: true }
];

export default class FeatureFlagManager extends LightningElement {
    columns = COLUMNS;
    featureFlags = [];
    draftValues = [];

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

    handleSave(event) {
        const recordInputs = event.detail.draftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });

        const promises = recordInputs.map(recordInput => {
            if (recordInput.fields.Id) {
                // Update existing record
                return updateRecord(recordInput);
            } else {
                // Create new record
                return createRecord({ apiName: 'Feature_Flag__c', fields: recordInput.fields });
            }
        });

        Promise.all(promises).then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Feature Flags updated',
                    variant: 'success'
                })
            );
            this.draftValues = [];
            return this.refresh();
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating or creating records',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }

    // Placeholder for refresh function - implement as needed
    refresh() {
        // Implement logic to refresh the data in the LWC
        // For example, you can call the @wire method again
    }
}