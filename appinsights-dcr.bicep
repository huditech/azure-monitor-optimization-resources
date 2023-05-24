param location string = resourceGroup().location
param workspaceName string

resource workspace 'Microsoft.operationalinsights/workspaces@2022-10-01' existing = {
  name: workspaceName
}

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'app-insights-data-collection-rule'
  location: location
  kind: 'WorkspaceTransforms'
  properties: {
    dataSources: {}
    destinations: {
      logAnalytics: [
        {
          name: 'workspace' // Friendly name used for destinations
          workspaceResourceId: workspace.id
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Table-AppDependencies'
        ]
        destinations: [
          'workspace'
        ]
        // Possibly also the OperationId and ParentId columns
        // Id column also seems useless but there is an error when removing it (at least via the portal)
        transformKql: 'source | project-away ClientCity, ClientCountryOrRegion, ClientIP, ClientOS, ClientStateOrProvince, ClientType, IKey, ResourceGUID, SDKVersion'
      }
      // Missing here: AppEvents - There were no rows in the example data
      // Missing here: AppExceptions - Data Collection Rules don't seem to be supported
      // Missing here: AppPageView - Data Collection Rules don't seem to be supported
      {
        streams: [
          'Microsoft-Table-AppPerformanceCounters'
        ]
        destinations: [
          'workspace'
        ]
        transformKql: 'source | project-away ClientOS, ClientType, IKey, ResourceGUID, SDKVersion, Properties, ClientStateOrProvince, ClientIP, ClientCountryOrRegion, ClientCity, Instance'
      }
      {
        streams: [
          'Microsoft-Table-AppRequests'
        ]
        destinations: [
          'workspace'
        ]
        transformKql: 'source | project-away ClientIP, ClientType, IKey, ResourceGUID, SDKVersion'
      }
      // Missing here: AppSystemEvents - There were no rows in the example data
      {
        streams: [
          'Microsoft-Table-AppTraces'
        ]
        destinations: [
          'workspace'
        ]
        transformKql: 'source | project-away ClientIP, ClientType, IKey, ResourceGUID, SDKVersion, SourceSystem, TenantId'
      }
      {
        streams: [
          'Microsoft-Table-AppMetrics'
        ]
        destinations: [
          'workspace'
        ]
        transformKql: 'source | project-away ClientCity, ClientCountryOrRegion, ClientIP, ClientOS, ClientStateOrProvince, IKey, ResourceGUID, SDKVersion'
      }
    ]
  }
}
