using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutocontrolService.Implementation.Config;
using PlantiT.Base.Logging.Abstractions;

namespace AutocontrolService.Host.Services
{
    /// <summary>
    /// Allows the module service to log its own start and stop.
    /// Technically, this is realized by creating this service class at startup and disposing it at shut-down.
    /// </summary>
    public class StartStopLog : IDisposable
    {
        private readonly ILogWriter log;

        private enum ResourceKey
        {
            ApplicationStarted,
            ApplicationShutdown,
        }

        /// <summary>Initializes this service. Should be called in the ConfigureServices method of the Startup.cs.
        /// Writes a startup-event in the log.</summary>
        public StartStopLog(ILogWriter log)
        {
            this.log = log;
            this.log.WriteToLog().Information(ResourceKey.ApplicationStarted, ConfigurationConstants.ModuleServiceIdentifier);
        }

        /// <summary>Disposes this service. Should be called by Kestrel only. Logs shutdown-event.</summary>
        public void Dispose()
        {
            log.WriteToLog().Information(ResourceKey.ApplicationShutdown, ConfigurationConstants.ModuleServiceIdentifier);
        }
    }
}
