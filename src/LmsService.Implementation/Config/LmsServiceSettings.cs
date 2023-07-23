using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using PlantiT.Base.HttpClientProvider.DelegationFlow;
using PlantiT.Base.ServiceBootstrapping;

namespace LmsService.Implementation.Config
{
    /// <summary>
    /// Provides settings for the current Module-Service.
    /// Populated with values loaded from static files, command line or presets.
    /// </summary>
    public class LmsServiceSettings : ServiceSettings
    {
        /// <summary>Example setting. Should always have a default value. Referenced to from the Configuration class. Can be deleted once understood.</summary>
        public string ExampleSetting { get; set; } = "default value";

        public string DatabaseConnectionString { get; set; }

        public string AutocontrolFilesPath { get; set; }

        public DelegationFlowSettings DelegationFlowSettings { get; set; } = new DelegationFlowSettings
        {
            ClientId = "LmsClient",
            ClientSecret = "MyClientSecret",
            ScopesToRequest = "basecommon"
        };
    }
}
