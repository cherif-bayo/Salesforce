@isTest
global class FlexeraWebServiceMockImpl implements WebServiceMock {
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
       
        if(requestName == 'getUserCountRequest'){
            FlexeraUserOrgHierarchyService.getUserCountRequestType requestObject = (FlexeraUserOrgHierarchyService.getUserCountRequestType)request;
        
            FlexeraUserOrgHierarchyService.getUserCountResponseType respElement = new FlexeraUserOrgHierarchyService.getUserCountResponseType();
            respElement.statusInfo = new FlexeraUserOrgHierarchyService.StatusInfoType();
            respElement.statusInfo.status = 'SUCCESS';
            respElement.responseData = new FlexeraUserOrgHierarchyService.getUserCountResponseDataType();
            respElement.responseData.count = 0;
            
            if(requestObject.queryParams.emailAddress.value == 'test@test.com'){
                respElement.statusInfo.status = 'ERROR';
            }
            
            response.put('response_x', respElement);
        }else if(requestName == 'getOrganizationCountRequest'){
            FlexeraUserOrgHierarchyService.getOrganizationCountRequestType requestObject = (FlexeraUserOrgHierarchyService.getOrganizationCountRequestType)request;
        
             FlexeraUserOrgHierarchyService.getOrganizationCountResponseType respElement = new FlexeraUserOrgHierarchyService.getOrganizationCountResponseType();
             respElement.statusInfo = new FlexeraUserOrgHierarchyService.StatusInfoType();
             respElement.statusInfo.status = 'SUCCESS';
             respElement.responseData = new FlexeraUserOrgHierarchyService.getOrganizationCountResponseDataType();
             respElement.responseData.count = 0;
             
             if(requestObject.queryParams.orgName.value == 'test2@test.com'){
                respElement.statusInfo.status = 'ERROR';
             }
                
             response.put('response_x', respElement);
        }else if(requestName == 'createUserRequest'){
            FlexeraUserOrgHierarchyService.createUserRequestType requestObject = (FlexeraUserOrgHierarchyService.createUserRequestType)request;
        
            FlexeraUserOrgHierarchyService.createUserResponseType respElement = new FlexeraUserOrgHierarchyService.createUserResponseType();
            respElement.statusInfo = new FlexeraUserOrgHierarchyService.StatusInfoType();
            respElement.statusInfo.status = 'SUCCESS';
            
            if(requestObject.user_x[0].emailAddress == 'test3@test.com'){
                respElement.statusInfo.status = 'ERROR';
                respElement.failedData = new FlexeraUserOrgHierarchyService.failedCreateUserDataListType ();
                respElement.failedData.failedUser = new FlexeraUserOrgHierarchyService.failedCreateUserDataType[1];
                respElement.failedData.failedUser[0] = new FlexeraUserOrgHierarchyService.failedCreateUserDataType();
                respElement.failedData.failedUser[0].reason = 'Test';
            }
        
            response.put('response_x', respElement);
        }else if(requestName == 'createOrgRequest'){
             FlexeraUserOrgHierarchyService.createOrgRequestType requestObject = (FlexeraUserOrgHierarchyService.createOrgRequestType)request;
        
            FlexeraUserOrgHierarchyService.createOrgResponseType respElement = new FlexeraUserOrgHierarchyService.createOrgResponseType();
            respElement.statusInfo = new FlexeraUserOrgHierarchyService.StatusInfoType();
            respElement.statusInfo.status = 'SUCCESS';
            
            if(requestObject.organization[0].name == 'test4@test.com'){
                respElement.failedData = new FlexeraUserOrgHierarchyService.failedCreateOrgDataListType ();
                respElement.failedData.failedOrg = new FlexeraUserOrgHierarchyService.failedCreateOrgDataType[1];
                respElement.failedData.failedOrg[0] = new FlexeraUserOrgHierarchyService.failedCreateOrgDataType();
                respElement.failedData.failedOrg[0].reason = 'test';      
            }
            
            response.put('response_x', respElement);
        }else if(requestName == 'createSimpleEntitlementRequest'){
            FlexeraEntitlementOrderService.createSimpleEntitlementRequestType requestObject = (FlexeraEntitlementOrderService.createSimpleEntitlementRequestType)request;
        
            FlexeraEntitlementOrderService.createSimpleEntitlementResponseType respElement = new FlexeraEntitlementOrderService.createSimpleEntitlementResponseType();
            respElement.statusInfo = new FlexeraEntitlementOrderService.StatusInfoType();
            respElement.statusInfo.status = 'SUCCESS';
            respElement.responseData = new FlexeraEntitlementOrderService.createdSimpleEntitlementDataListType();
            respElement.responseData.createdSimpleEntitlement = new FlexeraEntitlementOrderService.createdSimpleEntitlementDataType[1];
            respElement.responseData.createdSimpleEntitlement[0] = new FlexeraEntitlementOrderService.createdSimpleEntitlementDataType();
            respElement.responseData.createdSimpleEntitlement[0].entitlementId = 'Test';
            respElement.responseData.createdSimpleEntitlement[0].lineItemIdentifiers = new FlexeraEntitlementOrderService.entitlementLineItemIdentifierType[1];
            respElement.responseData.createdSimpleEntitlement[0].lineItemIdentifiers[0] = new FlexeraEntitlementOrderService.entitlementLineItemIdentifierType();
            respElement.responseData.createdSimpleEntitlement[0].lineItemIdentifiers[0].primaryKeys = new FlexeraEntitlementOrderService.entitlementLineItemPKType();
            respElement.responseData.createdSimpleEntitlement[0].lineItemIdentifiers[0].primaryKeys.activationId = 'Test';
            
            if(requestObject.simpleEntitlement[0].soldTo == 'test5@test.com'){
                respElement.statusInfo.status = 'ERROR';
                respElement.failedData = new FlexeraEntitlementOrderService.failedSimpleEntitlementDataListType();
                respElement.failedData.failedSimpleEntitlement = new FlexeraEntitlementOrderService.failedSimpleEntitlementDataType[1];
                respElement.failedData.failedSimpleEntitlement[0] = new FlexeraEntitlementOrderService.failedSimpleEntitlementDataType();  
                respElement.failedData.failedSimpleEntitlement[0].reason = 'test';
            }
            
            response.put('response_x', respElement);
        }else if(requestName == 'updateEntitlementLineItemRequest'){
            FlexeraEntitlementOrderService.updateEntitlementLineItemRequestType requestObject = (FlexeraEntitlementOrderService.updateEntitlementLineItemRequestType)request;
                    
            FlexeraEntitlementOrderService.updateEntitlementLineItemResponseType respElement = new FlexeraEntitlementOrderService.updateEntitlementLineItemResponseType();
            respElement.statusInfo = new FlexeraEntitlementOrderService.StatusInfoType();
            respElement.statusInfo.status = 'SUCCESS';
            
            if(requestObject.lineItemData[0].entitlementIdentifier.primaryKeys.entitlementId == 'TestError'){
                respElement.statusInfo.status = 'ERROR';
                respElement.failedData = new FlexeraEntitlementOrderService.failedUpdateEntitlementLineItemDataListType ();
                respElement.failedData.failedData = new FlexeraEntitlementOrderService.failedUpdateEntitlementLineItemDataType[1];
                respElement.failedData.failedData[0] = new FlexeraEntitlementOrderService.failedUpdateEntitlementLineItemDataType();
                respElement.failedData.failedData[0].reason = 'Test';
            }
            
            response.put('response_x', respElement);
        }else if(requestName == 'searchEntitlementLineItemPropertiesRequest'){
            FlexeraEntitlementOrderService.searchEntitlementLineItemPropertiesRequestType requestObject = (FlexeraEntitlementOrderService.searchEntitlementLineItemPropertiesRequestType)request;
        
            FlexeraEntitlementOrderService.searchEntitlementLineItemPropertiesResponseType respElement = new FlexeraEntitlementOrderService.searchEntitlementLineItemPropertiesResponseType();
            respElement.statusInfo = new FlexeraEntitlementOrderService.StatusInfoType();
            respElement.statusInfo.status = 'SUCCESS';
            respElement.entitlementLineItem = new FlexeraEntitlementOrderService.entitlementLineItemPropertiesType[1];
            respElement.entitlementLineItem[0] = new FlexeraEntitlementOrderService.entitlementLineItemPropertiesType();
            respElement.entitlementLineItem[0].entitlementId = new FlexeraEntitlementOrderService.entitlementIdentifierType();
            respElement.entitlementLineItem[0].entitlementId.primaryKeys = new FlexeraEntitlementOrderService.entitlementPKType();
            respElement.entitlementLineItem[0].entitlementId.primaryKeys.entitlementId = 'Test';
            respElement.entitlementLineItem[0].soldTo = new FlexeraEntitlementOrderService.organizationIdentifierType();
            respElement.entitlementLineItem[0].soldTo.primaryKeys = new FlexeraEntitlementOrderService.organizationPKType();
            respElement.entitlementLineItem[0].soldTo.primaryKeys.name = 'Test';
            respElement.entitlementLineItem[0].licenseModel = new FlexeraEntitlementOrderService.licenseModelIdentifierType();
            respElement.entitlementLineItem[0].licenseModel.primaryKeys = new FlexeraEntitlementOrderService.licenseModelPKType();
            respElement.entitlementLineItem[0].licenseModel.primaryKeys.name = 'CMP_AN';
            respElement.entitlementLineItem[0].isPermanent = false;
            respElement.entitlementLineItem[0].numberOfCopies = 1;
            respElement.entitlementLineItem[0].numberOfRemainingCopies = 1;
            respElement.entitlementLineItem[0].entitledProducts = new FlexeraEntitlementOrderService.entitledProductDataListType();
            respElement.entitlementLineItem[0].entitledProducts.entitledProduct = new FlexeraEntitlementOrderService.entitledProductDataType[1];
            respElement.entitlementLineItem[0].entitledProducts.entitledProduct[0] = new FlexeraEntitlementOrderService.entitledProductDataType();     
            respElement.entitlementLineItem[0].entitledProducts.entitledProduct[0].product = new FlexeraEntitlementOrderService.productIdentifierType();
            respElement.entitlementLineItem[0].entitledProducts.entitledProduct[0].product.primaryKeys = new FlexeraEntitlementOrderService.productPKType();
            respElement.entitlementLineItem[0].entitledProducts.entitledProduct[0].product.primaryKeys.name = 'XLSTAT-Base';
            respElement.entitlementLineItem[0].startDate = Date.today();
            respElement.entitlementLineItem[0].expirationDate= Date.today();
            
            requestObject.queryParams.parentBulkEntitlementId = new FlexeraEntitlementOrderService.SimpleQueryType();
            requestObject.queryParams.parentBulkEntitlementId.value = 'test';
            requestObject.queryParams.entitlementId= new FlexeraEntitlementOrderService.SimpleQueryType();
            requestObject.queryParams.entitlementId.value = 'test';
            requestObject.queryParams.productName= new FlexeraEntitlementOrderService.SimpleQueryType();
            requestObject.queryParams.productName.value = 'XLSTAT-Base, XLSTAT-3DPlot';
            requestObject.queryParams.productVersion= new FlexeraEntitlementOrderService.SimpleQueryType();
            requestObject.queryParams.productVersion.value = '1.0';
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
            
            if(requestObject.queryParams.activationId.value == 'TestError2'){
                respElement.statusInfo.status = 'ERROR';
            }    
            
            response.put('response_x', respElement);
        }else if(requestName == 'setEntitlementStateRequest'){        
            FlexeraEntitlementOrderService.setEntitlementStateResponseType respElement = new FlexeraEntitlementOrderService.setEntitlementStateResponseType();
            respElement.statusInfo = new FlexeraEntitlementOrderService.StatusInfoType();
            respElement.statusInfo.status = 'SUCCESS';
            
            response.put('response_x', respElement);
        }
   }
}