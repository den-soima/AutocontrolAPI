using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;
using TestService02.Implementation.Config;
using PlantiT.Base.HttpClientProvider;
using PlantiT.Base.Localization;
using PlantiT.Base.Logging.Configuration;
using PlantiT.Base.Primitives;
using PlantiT.Base.ServiceBootstrapping;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System;
using PlantiT.Base.Logging;
using PlantiT.Base.ServiceBootstrapping.DatabaseSupport;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using PlantiT.Base.PermissionValidation.PermissionRegistration;
using PlantiT.Base.PermissionValidation.Abstractions;

namespace TestService02.Implementation
{
    /// <summary>
    /// All public methods in this class are called by the Host-Application at Startup.
    ///
    /// TODO for template-users: Adapt all methods of this Factory to the needs of your Service.
    /// </summary>
    public static class Factory
    {
        /// <summary>
        /// Add all dependency-injection-services ("DI-services") of this module-service
        /// </summary>
        /// <returns></returns>
        public static IServiceCollection AddTestService02Services(this IServiceCollection services, TestService02Settings settings)
        {
            // Uncomment the following block, once you need a connection string for the private database of your module service!
            // Plant iT base stores connection-string configuration in a dedicated, partially encrypted file.
            // The ConnectionStringProvider-class can be used to access those connection-strings.
            // They can be configured using the Get/Set-PiTConnectionString Cmdlets.
            //if (settings.DatabaseConnectionString == null)
            //{
            //    settings.DatabaseConnectionString = ConnectionStringProvider
            //                                           .GetValidConnectionString(
            //                                                          settings, ConfigurationConstants.ModuleIdentifier,
            //                                                          ConfigurationConstants.ModuleServiceIdentifier, null, null);
            //}
            //Uncomment the following block, once you need a private database for your service.
            //MyDbContext is a placeholder for your context name!
            //var myDbContextOptions = new DbContextOptionsBuilder<MyDbContext>();
            //myDbContextOptions.UseSqlServer(settings.DatabaseConnectionString);
            //services.AddSingleton(myDbContextOptions.Options);
            //services.AddTransient<MyDbContext>();

            //If you want to use a SignalR Hub
            //services.AddSignalR();



            return services;
        }

        /// <summary>
        /// Configurations of the Application itself can be customized here.
        /// </summary>
        public static void Configure(IApplicationBuilder app, IWebHostEnvironment env, TestService02Settings settings, LogConfiguration logSettings)
        {

        }

        /// <summary>
        /// Add each of your controllers here like this:
        /// yield return new ControllerDocumentation(typeof(ValuesController));
        ///
        /// This is required for the included systems "Swashbuckle" and "Swagger".
        /// These can generate a human friendly API-specification
        /// which can be reviewed at runtime or used for automatic generation
        /// of REST-clients.
        ///
        /// Please refer to the developers-manual for more details.
        /// </summary>
        public static IEnumerable<ControllerDocumentation> ControllerDocumentation
        {
            get
            {
                yield break;
            }
        }

        #region Authentication configuration

        /// <summary>Set this to true, once secured API's should be accessed (e.g. of other module-services)</summary>
        public static bool RequireAuthentication { get; private set; } = false;

        /// <summary>
        /// The scopes (api-names) which are requested by swagger and are required to access
        /// the module-service's endpoints (controllers).
        /// </summary>
        public static Dictionary<string, string> ScopesSwaggerMustRequest = new Dictionary<string, string>
        {
            { "ScopeName", "Free-text description of what this scope is" }
        };

        /// <summary>
        /// Configures the authentication-settings in both directions:
        /// - When THIS module-service sends requests to OTHER module-services.
        /// - When OTHER module-services send requests to THIS module-service.
        ///
        /// For the first case:
        ///   Once you want to access secured API's (e.g. of other module-services)
        ///   this module service must be registered at IdentityProvider with an Id, a Secret and the Scopes
        ///   it wants to access. Afterwards, the Settings used in the AddTokenizedHttpClientProvider... should be
        ///   set according to the credentials which where set at IdentityProvider.
        ///
        /// For the latter:
        /// - the boolean "RequireAuthentication" needs to be set to true
        /// - the ApiName of this module-service must be registered at Identity-Provider and
        /// - the ApiName needs to be set below at "options.ApiName = PlantiTBase"
        /// - all controllers which should receive authenticated requests only must be decorated with the [Authorize] attribute
        /// </summary>
        public static IServiceCollection AddAuthenticationConfigurations(this IServiceCollection services, TestService02Settings settings)
        {
            // TODO for template-users:  Below is the configuration of a service which helps
            // sending authenticated http-requests.
            services.AddTokenizedHttpClientProviderForClientCredentialsFlowConfiguration(
                "MyClientId",
                new List<string>() { "ScopeA", "ScopeB" },
                "MySecret"
                );

            if (RequireAuthentication)
            {
                services.AddDelegatedClientProvider(settings.DelegationFlowSettings);

                // Adding authentication service.
                // Allows the usage of [Authorize] attributes.
                // For further information, see developer's manual.

                services.AddAuthentication("Bearer")
                    //If you want to use a SignalR Hub with token validation (access token in the query string)
                    //.AddJwtBearer(options =>
                    //{
                    //    options.Authority = IdentityProviderDiscovery.GetMostPossiblyWorkingIdentityProviderAddress();

                    //    // Sending the access token in the query string is required due to
                    //    // a limitation in Browser APIs. We restrict it to only calls to the
                    //    // SignalR hubs.
                    //    // See https://docs.microsoft.com/aspnet/core/signalr/security#access-token-logging
                    //    // for more information about security considerations when using
                    //    // the query string to transmit the access token.
                    //    options.Events = new JwtBearerEvents
                    //    {
                    //        OnMessageReceived = context =>
                    //        {
                    //            var accessToken = context.Request.Query["access_token"];

                    //            // If the request is for our hub...
                    //            var path = context.HttpContext.Request.Path;
                    //            if (!string.IsNullOrEmpty(accessToken) &&
                    //                (path.StartsWithSegments("/signalrHubs")))
                    //            {
                    //                // Read the token out of the query string
                    //                context.Token = accessToken;
                    //            }
                    //            return Task.CompletedTask;
                    //        }
                    //    };
                    //});
                    .AddIdentityServerAuthentication(options =>
                    {
                        options.Authority = IdentityProviderDiscovery.GetMostPossiblyWorkingIdentityProviderAddress();
                        options.RequireHttpsMetadata = (settings.System.HttpTlsMode == HttpTlsMode.Https);
                        options.ApiName = "PlantiTbase";
                    });



                //If you want to use a SignalR Hub
                // Change to use Name as the user identifier for SignalR
                // WARNING: This requires that the source of your JWT token 
                // ensures that the Name claim is unique!
                // If the Name claim isn't unique, users could receive messages 
                // intended for a different user!
                //services.AddSingleton<IUserIdProvider, NameUserIdProvider>();

                // Change to use email as the user identifier for SignalR
                // services.AddSingleton<IUserIdProvider, EmailBasedUserIdProvider>();

                // WARNING: use *either* the NameUserIdProvider *or* the 
                // EmailBasedUserIdProvider, but do not use both. 
            }

            return services;
        }

        #endregion

        /// <summary>
        /// Action that will be preformed on graceful shutdown
        /// </summary>
        public static void OnShutdown()
        {
            // ToDo for Template Users: Add Code that shut be executed on a graceful shutdown
            // The Service will not stop until this Method is executed and will be called threadsave only once.

        }
    }
}
