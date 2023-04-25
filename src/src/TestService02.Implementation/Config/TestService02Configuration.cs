using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using PlantiT.Base.CommandLineUtils;
using PlantiT.Base.Primitives.DataStructure;
using PlantiT.Base.Primitives.SimpleLogging;
using PlantiT.Base.ServiceBootstrapping;

namespace TestService02.Implementation.Config
{
    /// <summary>
    /// Method-object for loading configuration from different sources like static-files or the command-line.
    /// </summary>
    public class TestService02Configuration : ServiceConfiguration<TestService02Settings>
    {
        /// <summary>
        /// The Service name of the application (The Logging infrastructure reads this)
        /// </summary>
        public override TechName ModuleServiceIdentifier => ConfigurationConstants.ModuleServiceIdentifier;

        /// <summary>
        /// The Module name of the application (The Logging infrastructure reads this)
        /// </summary>
        public override TechName ModuleIdentifier => ConfigurationConstants.ModuleIdentifier;

        /// <summary>
        /// The section name, required for the configuration system to find the 
        /// correct object for the name of the object in the configuration file
        /// </summary>
        protected override string ConfigSectionName => ConfigurationConstants.ConfigSectionName;

        /// <summary>
        /// This adds the configuration-file of this Module-Service to the configuration system.
        /// </summary>
        /// <param name="configurationBuilder">Provides the collection of possible configuration sources.</param>
        /// <param name="basePath">Path under which the configuration files can be found.</param>
        protected override void AddConfigurationFiles(IConfigurationBuilder configurationBuilder, string basePath)
        {
            if (File.Exists(Path.Combine(basePath, ConfigurationConstants.TestService02ConfigFileName)))
            {
                configurationBuilder
                    .AddJsonFile(Path.Combine(basePath, ConfigurationConstants.TestService02ConfigFileName));

                SimpleLogging.Log(
                    "TestService02-Configuration will be loaded from: " +
                    $"{Path.Combine(basePath, ConfigurationConstants.TestService02ConfigFileName)}",
                    SimpleLogEntryType.Information);
            }
            else
            {
                SimpleLogging.Log(
                    "TestService02-Configuration file not found: " +
                    $"{Path.Combine(basePath, ConfigurationConstants.TestService02ConfigFileName)}",
                    SimpleLogEntryType.Warning);
            }
        }

        /// <summary>
        /// Displays the current configuration in the log (and console, if used)
        /// </summary>
        protected override void OnConfigurationFinished()
        {
            //todo einkommentieren wenn nuget-package aktualisiert wurde mit der LogLoadedConfiguration-methode
            //this.LogLoadedConfiguration(Settings.ConfigurationMapping.GetConfiguration(this.Configuration),
            //    "Current TestService02 configuration:");
        }


        // If you need to provide command line options for this module-service
        // use this region to enable acceptance and applying to the Settings-object.

        #region Command-Line-Options

        /// <summary>
        /// Used to configure command line arguments.
        /// 
        /// The following arguments are already in use, so use the short or long names in own arguments please:
        /// Long-Name               Short-Name 
        /// --Port                  -l
        /// --projectDirectory      -p 
        /// --TlsMode               -s
        /// --SslCertThumbprint     -t
        /// --UrlPathBase           -u
        /// --piTReverseProxyPort   -r
        /// --databaseStorageType   -w
        /// --databaseServerComputer-x
        /// --databaseServerInstance-y
        /// --showPII               -z 
        /// For descriptions and options of above arguments please refer to the developers-manual.
        /// </summary>
        /// <param name="parserBuilder">None of your interest.</param>
        protected override void CreateCommandLineArguments(CommandLineParserBuilder<TestService02Settings> parserBuilder)
        {
            //Add own command line arguments below like in this example:
            parserBuilder.CreateArgument(a => a.ExampleSetting, 'e');
            //These can also be made required or get long names like here:
            //parserBuilder.CreateArgument(a => a.ExampleSetting, 'e',"example",true);
        }

        #endregion
    }
}
