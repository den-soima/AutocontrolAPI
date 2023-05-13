using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace LmsService.Implementation.Config
{
    /// <summary>
    /// Defines constants that configure the module/service
    /// </summary>
    public class ConfigurationConstants
    {
        /// <summary>
        /// TODO for template-users: a file with the following name must be placed in the config directory of Plant iT base.
        /// containing a json structure corresponding to the class hirarchy seen in "Settings.cs". Please
        /// refer to the developer manual for more information about this.
        /// </summary>
        public const string LmsServiceConfigFileName = "LmsService.Config.json";

        /// <summary>
        /// This should be set to the techname of the module.
        /// </summary>
        public const string ModuleIdentifier = "LmsModule";

        /// <summary>
        /// Normally, this should be set to the techname of the module-service.
        /// Will be used from the StartStopLog-Service which log's when this service starts and stops.
        /// </summary>
        public const string ModuleServiceIdentifier = "LmsService";

        /// <summary>
        /// The section name, required for the configuration system to find the 
        /// correct object for the name of the object in the configuration file
        /// </summary>
        public const string ConfigSectionName = "LmsServiceSettings";
    }
}
