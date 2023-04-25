using Microsoft.AspNetCore.Mvc;
using PlantiT.Base.HttpClientProvider;
using PlantiT.Base.Logging.Abstractions;
using PlantiT.Base.ServiceBootstrapping.SwaggerConfiguration;

namespace AutocontrolService.Implementation.Controllers.V1
{
    /// <summary>
    /// An REST-ful api-controller for storing and retrieving the names of guests who visited this instance.
    /// 
    /// TODO for template-users: This is an example controller and should be removed once understood!
    /// </summary>
    // TODO for template-users: To require incoming requests to Authenticate un-comment the following Line
    // (and add it to any other controller which should only allow authenticated incoming requests) (4/4) 
    //[Authorize]
    [ApiController]
    [ApiVersion("1")]
    [Route("api/v{version:apiVersion}/[controller]")]
    [PitApiExplorerSettings(typeof(AccessingForeignModuleServicesExampleController))]
    public class AccessingForeignModuleServicesExampleController : Controller
    {
        private readonly ILogWriter log;
        private readonly IHttpClientProvider httpClientProvider;

        enum ResourceKey
        {
            EntryCreated,
            EntryDeleted
        }

        /// <summary>
        /// Instanciates the controller.
        /// </summary>
        /// <param name="httpClientProvider">A provider for tokenized http-clients.</param>
        /// <param name="log">Required for logging.</param>
        public AccessingForeignModuleServicesExampleController(ILogWriter log, IHttpClientProvider httpClientProvider)
        {
            this.log = log;
            this.httpClientProvider = httpClientProvider;
        }

        /// <summary>
        /// Example method which shows how to use the httpClientProvider
        /// </summary>
        /// <returns>Nothing</returns>
        [HttpGet]
        public IActionResult ExampleAccessOfOtherModuleService()
        {
            // The below received client contains an access-token, which is required
            // for accessing foreign module-services which only accept authenticated calls.
            var httpClient = httpClientProvider.GetClientForClientCredentialsFlow("OtherModuleName", "OtherServiceName");

            // After receiving the above http-client, an automatically generated API-Client can be fed with it. e.g.

            // var materialApiClient = new materialApiClient(httpClient);

            // Please refer to the developers-manual for details.

            return Ok();
        }
    }
}
