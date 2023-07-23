using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Hosting.Server.Features;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using LmsService.Implementation;
using LmsService.Implementation.Config;
using LmsService.Host.Services;
using PlantiT.Base.HttpClientProvider;
using PlantiT.Base.Localization;
using PlantiT.Base.Logging.Configuration;
using PlantiT.Base.Primitives;
using PlantiT.Base.ServiceBootstrapping;
using PlantiT.Base.ServiceDiscovery;
using PlantiT.Base.ServiceDiscovery.Abstractions;
using PlantiT.Base.ServiceDiscovery.Abstractions.DataStructure;
using PlantiT.Base.ServiceDiscovery.IdentityProvider.ForApi;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection.Extensions;
using PlantiT.Base.AngularHosting;
using PlantiT.Base.ServiceBootstrapping.IPC;
using Factory = LmsService.Implementation.Factory;
using PlantiT.Base.ServiceBootstrapping.SwaggerConfiguration;
using System.IO;

namespace LmsService.Host
{
    /// <summary>
    /// This class is instanciated by the Webhost (Kestrel), which is built and started in Program.cs
    /// The webhost uses this object to initialize and configure the services, which it is using at runtime.
    /// The dependency-injection pattern is strongly followed here.
    /// </summary>
    public class Startup
    {
        // Flag to avoid that the graceful shutdown action will be started more than once.
        private static bool shutdownCalled = false;

        // Object to avoid that the graceful shutdown action will be started more than once threadsafe.
        private static object lockObject = "Lock";

        /// <summary> An <see cref="IConfiguration"/> instance with basic settings provided by the Webhost-Builder (e.g. Environment-Variables) </summary>
        private readonly IConfiguration configuration;

        private readonly IWebHostEnvironment env;

        /// <summary>The settings for this module-service</summary>
        private readonly LmsServiceSettings settings;      

        /// <summary> Creates a new instance of the <see cref="Startup"/> class. </summary>
        public Startup(IConfiguration configuration, IWebHostEnvironment env)
        {
            this.configuration = configuration;
            this.env = env;

            // Fill the settings-object with values provided by the different configuration-sources (commandline, config-file or default-values)
            this.settings = ServiceTools.GetServiceSettings<Startup, LmsServiceSettings>(ConfigurationConstants.ConfigSectionName);
        }

        /// <summary>
        /// This method is called by the webhost.
        /// Here, all used singletons and transients should be added to the service-collection.
        /// </summary>
        /// <param name="services">The Servicecollection to which all services should be added.</param>
        public void ConfigureServices(IServiceCollection services)
        {
            // Adds swagger, optionally with authentication if enabled
            services.AddSwagger(new SwaggerSettings()
            {
                EnableAuthenticationFeatures = Implementation.Factory.RequireAuthentication,
                TryAutomaticClientSetup = Implementation.Factory.RequireAuthentication,
                AppDisplayName = $"{ConfigurationConstants.ModuleServiceIdentifier}",
                Scopes = Implementation.Factory.ScopesSwaggerMustRequest,
                OAuthClientId = $"{ConfigurationConstants.ModuleIdentifier}{ConfigurationConstants.ModuleServiceIdentifier}SwaggerClient",
            },
            Factory.ControllerDocumentation);         

            // ATTENTION:
            // ==========
            // The following call includes an implicit call to services.AddMvc() **and** services.AddMvcCore()
            // If this service is a typical MVC application this should be fine - otherwise please refer to the documentation

            services.AddPlantiTBase<Startup>(env);

            // A service logging the startup and shutdown of this module service
            //services.AddSingleton<StartStopLog>();
            services.AddSingleton<ServiceConfiguration, LmsServiceConfiguration>();

            services.AddSingleton<LmsServiceSettings>(this.settings);

            // Adding the service discovery
            services.AddServiceDiscoveryWithDefaultSettings(this.settings);

            #region Example: Explicitly adding the service discovery

            // The following codeblock makes use of the Options-Pattern provided by ASP-net.core.
            // https://docs.microsoft.com/de-de/aspnet/core/fundamentals/configuration/options?view=aspnetcore-2.1
            // This pattern separates groups of settings and their configration from the actual instantiation of the service.
            //services.AddOptions<ServiceDiscoverySettings>()
            //    .Configure((o) =>
            //    {
            //        o.InfrastructureHostName = settings.System.LocalModuleManagerHostName;
            //        o.InfrastructurePort = settings.System.LocalModuleManagerPort;
            //        o.TlsMode = settings.System.HttpTlsMode;
            //    });

            //services.AddServiceDiscovery();

            #endregion Example: Explicitly adding the service discovery

            Implementation.Factory.AddLmsServiceServices(services, settings);

            Implementation.Factory.AddAuthenticationConfigurations(services, settings);

            services.TryAddSingleton<IHttpContextAccessor, HttpContextAccessor>();
        }

        /// <summary>
        /// This method is called by the webhost (after "ConfigureServices(...)").
        /// Here, the configurations for the web application itself (like the url)
        /// are set.
        /// </summary>
        /// <param name="app">Provides the mechanisms to configure an application's request pipeline</param>
        /// <param name="env">Provides information about the web hosting environment an application is running in.</param>
        /// <param name="settings">Provides settings for the current Module-Service</param>
        /// <param name="logSettings">The settings for the logging</param>
        /// <param name="applicationLifetime">Allows consumers to preform cleanup during a graceful shutdown</param>
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env, LmsServiceSettings settings, LogConfiguration logSettings, IHostApplicationLifetime applicationLifetime)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UsePathBase(settings.System.UrlPathBase);

            app.UsePlantiTBaseExceptionHandler(); // Must be located BEFORE app.UseRouting();!

            app.UseRouting();

            // The service logging the startup and shutdown of this module service
            //app.ApplicationServices.GetService(typeof(StartStopLog));

            app.ConfigureApplicationForPlantiTBase(env, settings, logSettings);

            if (Implementation.Factory.RequireAuthentication)
            {
                app.UseIdentityProviderReconfigurationMiddleware();

                // Authentication middleware - this line must be after UseIdentityProviderReconfigurationeMiddleware()
                app.UseAuthentication();

                app.UseAuthorization();
            }

            // Registers the Action "OnShutdown" to the Cancelation token of the application so it´s preformed on graceful shutdown
            applicationLifetime.ApplicationStopping.Register(OnShutdown);

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllerRoute(
                    name: "default",
                    pattern: "{controller=Home}/{action=Index}/{id?}");

                //If you want to use a Domain Event Hub for throwing domain events
                //endpoints.MapDomainEventsHub();

                //If you want to use a SignalR Hub
                //endpoints.MapHub<YourSignalrHub>($"/signalrHubs/YourHubName", options =>
                //{
                //    options.Transports = HttpTransportType.WebSockets;
                //});
            });

            app.Use((context, next) =>
            {
                if (context.Request.IsHtml())
                {
                    context.Response.Headers.Add("Cache-Control", "no-cache, no-store");
                    context.Response.Headers.Add("Expires", "-1");
                }
                return next();
            });

            app.ConfigureContentSecurityPolicy(builder =>
            {
                builder.Defaults.AllowSelf();
                builder.Styles.Allow("\'unsafe-inline\'");
                builder.Styles.AllowSelf();
                builder.Styles.Allow("data: https");
                builder.Images.Allow("\'unsafe-inline\'");
                builder.Images.AllowSelf();
                builder.Images.Allow("data: https");
                builder.Fonts.Allow("\'unsafe-inline\'");
                builder.Fonts.AllowSelf();
                builder.Fonts.Allow("data: https");
                builder.Scripts.Allow("\'unsafe-inline\'");
                builder.Scripts.AllowSelf();
                builder.Scripts.Allow("data: https");

            });

            app.UseCors(x => x.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());

            app.UseHttpsRedirection();
            app.UseStaticFiles();

            app.TrySetCurrentCulture();
            app.ConfigureXFrameOptions(options =>
            {
                options.Deny();
            });

            app.UseLocalizedSpaStaticFiles("index.html");
            Implementation.Factory.Configure(app, env, settings, logSettings);

            GlobalVariables.IsConfigurePhaseFinished = true;
        }

        // Action that will be called on graceful shotdown of the application
        private static void OnShutdown()
        {
            if (!shutdownCalled)
            {
                // Locks a object to ensure a threadsave execution
                lock (lockObject)
                {
                    if (!shutdownCalled)
                    {
                        shutdownCalled = true;
                        Factory.OnShutdown();
                    }
                }
            }
        }

        // Will be called if the terminate command is executed
        internal static void OnCommandRecieved(CommandReceivedEventArgs<Command> cmd)
        {
            if (cmd.Command == Command.Terminate)
            {
                OnShutdown();
            }
        }
    }
}
