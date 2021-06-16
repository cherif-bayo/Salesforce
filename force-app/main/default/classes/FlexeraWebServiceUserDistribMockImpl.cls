@isTest
global class FlexeraWebServiceUserDistribMockImpl implements WebServiceMock {
   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
       
        if(requestName == 'searchEntitlementLineItemPropertiesRequest'){
            FlexeraEntitlementOrderService.searchEntitlementLineItemPropertiesRequestType requestObject = (FlexeraEntitlementOrderService.searchEntitlementLineItemPropertiesRequestType)request;
        
            FlexeraEntitlementOrderService.searchEntitlementLineItemPropertiesResponseType respElement = new FlexeraEntitlementOrderService.searchEntitlementLineItemPropertiesResponseType();
            respElement.statusInfo = new FlexeraEntitlementOrderService.StatusInfoType();
            respElement.statusInfo.status = 'SUCCESS';
            respElement.entitlementLineItem = new FlexeraEntitlementOrderService.entitlementLineItemPropertiesType[2];
            respElement.entitlementLineItem[0] = new FlexeraEntitlementOrderService.entitlementLineItemPropertiesType();
            respElement.entitlementLineItem[0].entitlementId = new FlexeraEntitlementOrderService.entitlementIdentifierType();
            respElement.entitlementLineItem[0].entitlementId.primaryKeys = new FlexeraEntitlementOrderService.entitlementPKType();
            respElement.entitlementLineItem[0].entitlementId.primaryKeys.entitlementId = 'Test';
            respElement.entitlementLineItem[0].soldTo = new FlexeraEntitlementOrderService.organizationIdentifierType();
            respElement.entitlementLineItem[0].soldTo.primaryKeys = new FlexeraEntitlementOrderService.organizationPKType();
            respElement.entitlementLineItem[0].soldTo.primaryKeys.name = 'Test';
            respElement.entitlementLineItem[0].licenseModel = new FlexeraEntitlementOrderService.licenseModelIdentifierType();
            respElement.entitlementLineItem[0].licenseModel.primaryKeys = new FlexeraEntitlementOrderService.licenseModelPKType();
            respElement.entitlementLineItem[0].licenseModel.primaryKeys.name = 'Test';
            respElement.entitlementLineItem[0].isPermanent = false;
            respElement.entitlementLineItem[0].numberOfCopies = 1;
            respElement.entitlementLineItem[0].numberOfRemainingCopies = 1;
            respElement.entitlementLineItem[0].entitledProducts = new FlexeraEntitlementOrderService.entitledProductDataListType();
            respElement.entitlementLineItem[0].entitledProducts.entitledProduct = new FlexeraEntitlementOrderService.entitledProductDataType[2];
            respElement.entitlementLineItem[0].entitledProducts.entitledProduct[0] = new FlexeraEntitlementOrderService.entitledProductDataType();     
            respElement.entitlementLineItem[0].entitledProducts.entitledProduct[0].product = new FlexeraEntitlementOrderService.productIdentifierType();
            respElement.entitlementLineItem[0].entitledProducts.entitledProduct[0].product.primaryKeys = new FlexeraEntitlementOrderService.productPKType();
            respElement.entitlementLineItem[0].entitledProducts.entitledProduct[0].product.primaryKeys.name = 'XLSTAT-Pro';
            respElement.entitlementLineItem[0].entitledProducts.entitledProduct[1] = new FlexeraEntitlementOrderService.entitledProductDataType();     
            respElement.entitlementLineItem[0].entitledProducts.entitledProduct[1].product = new FlexeraEntitlementOrderService.productIdentifierType();
            respElement.entitlementLineItem[0].entitledProducts.entitledProduct[1].product.primaryKeys = new FlexeraEntitlementOrderService.productPKType();
            respElement.entitlementLineItem[0].entitledProducts.entitledProduct[1].product.primaryKeys.name = 'XLSTAT-MX';
            respElement.entitlementLineItem[0].activationId = new FlexeraEntitlementOrderService.entitlementLineItemIdentifierType();
            respElement.entitlementLineItem[0].activationId.primaryKeys = new FlexeraEntitlementOrderService.entitlementLineItemPKType();
            respElement.entitlementLineItem[0].activationId.primaryKeys.activationId = 'Test-Activation-Id';      
            respElement.entitlementLineItem[1] = new FlexeraEntitlementOrderService.entitlementLineItemPropertiesType();
            respElement.entitlementLineItem[1].entitlementId = new FlexeraEntitlementOrderService.entitlementIdentifierType();
            respElement.entitlementLineItem[1].entitlementId.primaryKeys = new FlexeraEntitlementOrderService.entitlementPKType();
            respElement.entitlementLineItem[1].entitlementId.primaryKeys.entitlementId = 'Test';
            respElement.entitlementLineItem[1].soldTo = new FlexeraEntitlementOrderService.organizationIdentifierType();
            respElement.entitlementLineItem[1].soldTo.primaryKeys = new FlexeraEntitlementOrderService.organizationPKType();
            respElement.entitlementLineItem[1].soldTo.primaryKeys.name = 'Test';
            respElement.entitlementLineItem[1].licenseModel = new FlexeraEntitlementOrderService.licenseModelIdentifierType();
            respElement.entitlementLineItem[1].licenseModel.primaryKeys = new FlexeraEntitlementOrderService.licenseModelPKType();
            respElement.entitlementLineItem[1].licenseModel.primaryKeys.name = 'Test';
            respElement.entitlementLineItem[1].isPermanent = false;
            respElement.entitlementLineItem[1].numberOfCopies = 1;
            respElement.entitlementLineItem[1].numberOfRemainingCopies = 1;
            respElement.entitlementLineItem[1].entitledProducts = new FlexeraEntitlementOrderService.entitledProductDataListType();
            respElement.entitlementLineItem[1].entitledProducts.entitledProduct = new FlexeraEntitlementOrderService.entitledProductDataType[2];
            respElement.entitlementLineItem[1].entitledProducts.entitledProduct[0] = new FlexeraEntitlementOrderService.entitledProductDataType();     
            respElement.entitlementLineItem[1].entitledProducts.entitledProduct[0].product = new FlexeraEntitlementOrderService.productIdentifierType();
            respElement.entitlementLineItem[1].entitledProducts.entitledProduct[0].product.primaryKeys = new FlexeraEntitlementOrderService.productPKType();
            respElement.entitlementLineItem[1].entitledProducts.entitledProduct[0].product.primaryKeys.name = 'XLSTAT-Pro';
            respElement.entitlementLineItem[1].entitledProducts.entitledProduct[1] = new FlexeraEntitlementOrderService.entitledProductDataType();     
            respElement.entitlementLineItem[1].entitledProducts.entitledProduct[1].product = new FlexeraEntitlementOrderService.productIdentifierType();
            respElement.entitlementLineItem[1].entitledProducts.entitledProduct[1].product.primaryKeys = new FlexeraEntitlementOrderService.productPKType();
            respElement.entitlementLineItem[1].entitledProducts.entitledProduct[1].product.primaryKeys.name = 'XLSTAT-MX';
            respElement.entitlementLineItem[1].activationId = new FlexeraEntitlementOrderService.entitlementLineItemIdentifierType();
            respElement.entitlementLineItem[1].activationId.primaryKeys = new FlexeraEntitlementOrderService.entitlementLineItemPKType();
            respElement.entitlementLineItem[1].activationId.primaryKeys.activationId = 'Test2-Activation-Id';                  
            
            requestObject.queryParams.parentBulkEntitlementId = new FlexeraEntitlementOrderService.SimpleQueryType();
            requestObject.queryParams.parentBulkEntitlementId.value = 'test';
            requestObject.queryParams.entitlementId= new FlexeraEntitlementOrderService.SimpleQueryType();
            requestObject.queryParams.entitlementId.value = 'test';
            requestObject.queryParams.productName= new FlexeraEntitlementOrderService.SimpleQueryType();
            requestObject.queryParams.productName.value = 'test';
            requestObject.queryParams.productVersion= new FlexeraEntitlementOrderService.SimpleQueryType();
            requestObject.queryParams.productVersion.value = 'test';
            requestObject.queryParams.productType= 'test';
            requestObject.queryParams.partNumber= new FlexeraEntitlementOrderService.SimpleQueryType();
            requestObject.queryParams.partNumber.value = 'test';
            requestObject.queryParams.startDate= new FlexeraEntitlementOrderService.DateQueryType();
            requestObject.queryParams.startDate.value = Date.today();
            requestObject.queryParams.isPermanent= false;
            requestObject.queryParams.expirationDate= new FlexeraEntitlementOrderService.DateQueryType();
            requestObject.queryParams.expirationDate.value = Date.today();
            requestObject.queryParams.versionDate= new FlexeraEntitlementOrderService.DateQueryType();
            requestObject.queryParams.licenseTechnology = new FlexeraEntitlementOrderService.SimpleQueryType();
            requestObject.queryParams.orderId = new FlexeraEntitlementOrderService.SimpleQueryType();
            requestObject.queryParams.withNoOrderId = false;
            requestObject.queryParams.restrictToItemsWithCount = false;
            requestObject.queryParams.fulfilledAmount = new FlexeraEntitlementOrderService.NumberQueryType();
            requestObject.queryParams.fulfilledAmount.value = 0;
            requestObject.queryParams.userId = 'test';
            requestObject.queryParams.customAttributes = new FlexeraEntitlementOrderService.customAttributesQueryListType();
            requestObject.queryParams.customAttributes.attribute = new FlexeraEntitlementOrderService.customAttributeQueryType[1];
            requestObject.queryParams.customAttributes.attribute[0] = new FlexeraEntitlementOrderService.customAttributeQueryType();
            requestObject.queryParams.customAttributes.attribute[0].booleanValue = true;
            requestObject.queryParams.customAttributes.attribute[0].attributeName = 'test';            
            requestObject.queryParams.soldTo = new FlexeraEntitlementOrderService.SimpleQueryType();
            requestObject.queryParams.parentBulkEntSoldTo = new FlexeraEntitlementOrderService.SimpleQueryType ();
            requestObject.queryParams.activatableItemType = 'test';
            requestObject.queryParams.allowPortalLogin = false;
            requestObject.queryParams.organizationUnitName = new FlexeraEntitlementOrderService.PartnerTierQueryType ();
            requestObject.queryParams.organizationUnitName.value = 'test';
            requestObject.queryParams.currentOwnerName = new FlexeraEntitlementOrderService.SimpleQueryType();
            requestObject.queryParams.lineItemParentLineItemId = new FlexeraEntitlementOrderService.SimpleQueryType();
            requestObject.queryParams.createdOnDateTime = new FlexeraEntitlementOrderService.DateTimeQueryType();
            requestObject.queryParams.createdOnDateTime.value = DateTime.now();
            requestObject.queryParams.lastModifiedDateTime = new FlexeraEntitlementOrderService.DateTimeQueryType();
            requestObject.queryParams.lineItemAttributes = new FlexeraEntitlementOrderService.lineItemCustomAttributesQueryListType();
            requestObject.queryParams.lineItemAttributes.attribute = new FlexeraEntitlementOrderService.lineItemCustomAttributeQueryType[1];
            requestObject.queryParams.lineItemAttributes.attribute[0] = new FlexeraEntitlementOrderService.lineItemCustomAttributeQueryType();     
            requestObject.queryParams.lineItemAttributes.attribute[0].attributeName = 'test';
            requestObject.queryParams.lineItemAttributes.attribute[0].stringValue = new FlexeraEntitlementOrderService.SimpleQueryType();
            
            response.put('response_x', respElement);
        }
   }
}