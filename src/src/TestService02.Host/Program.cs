using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using TestService02.Implementation.Config;
using PlantiT.Base.ServiceBootstrapping;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace TestService02.Host
{
    /// <summary>
    /// The main program class for starting the module-service. 
    /// In most cases, this class does not need to be changed.
    /// </summary>
    public class Program
    {
        /// <summary>
        /// Entrance of application control flow.
        /// </summary>
        /// <param name="args">Arguments provided from the command-line.</param>
        static void Main(string[] args)
        {
            CreateWebHostBuilder(args)
                .Build()
                .RunWithCommandReceiver(ConfigurationConstants.ModuleIdentifier, Startup.OnCommandRecieved);
        }

        /// <summary>
        /// Helper method for creating a <see cref="IWebHostBuilder"/> 
        /// </summary>
        /// <param name="args">Arguments provided from the command-line.</param>
        /// <returns></returns>
        public static IWebHostBuilder CreateWebHostBuilder(string[] args)
        {
            ServiceSettings serviceSettings;
            IWebHostBuilder webHostBuilder = WebHost.CreateDefaultBuilder()
                   .UseStartupWithConfiguration<Startup, TestService02Configuration>(args, out serviceSettings)
                   .UseKestrelWithListenSettings<TestService02Settings>();

            return webHostBuilder;
        }
    }
}
