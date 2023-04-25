using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using AutocontrolService.Implementation.BusinessLogic;
using PlantiT.Base.HttpClientProvider;
using PlantiT.Base.Logging.Abstractions;
using PlantiT.Base.ServiceBootstrapping.SwaggerConfiguration.ProcessModellingExtensions;
using PlantiT.Base.ServiceBootstrapping.SwaggerConfiguration;
using PlantiT.Base.PolicyValidation.Attributes;
using AutocontrolService.Data;
using AutocontrolService.Data.Model;

namespace AutocontrolService.Implementation.Controllers.V1
{
    /// <summary>
    /// An REST-ful api-controller for storing and retrieving the names of guests who visited this instance.
    /// </summary>
    // TODO for template-users: To require incoming requests to Authenticate un-comment the following Line
    // (and add it to any other controller which should only allow authenticated incoming requests) (4/4) 
    //[Authorize]
    [ApiController]
    [ApiVersion("1")]
    // TODO for template-users: Uncomment below attribute to allow Camunda Modeler to discoer and access this API. 
    //[SupportsBaseProcessModelling]
    [Route("api/v{version:apiVersion}/[controller]")]
    [PitApiExplorerSettings(typeof(AutocontrolController))] //Required for grouping API-functions in automatic API-documentation generation.
    public class AutocontrolController : ControllerBase
    {
        private IAutocontrolRepository _autocontrolRepository;

        public AutocontrolController(IAutocontrolRepository autocontrolRepository)
        {
            this._autocontrolRepository = autocontrolRepository;
        }
        /// <summary>
        /// Gets all entries in the list of guests.
        /// </summary>
        /// <returns>The entire list of guests who immortalized themselves in this session.</returns>
        [HttpGet]
        //[RequiresPermission("Guest","Read")]
        [Produces(typeof(List<Autocontrol>))] //Required for API-Documentation; this way required data structures are also documented.
        public IActionResult GetAll()
        {
            try
            {
                var autocontrols = _autocontrolRepository.GetAll();              
                return Ok(autocontrols);
            }
            catch (Exception ex)
            {

                return StatusCode(500, ex.Message);
            }
        }
    }
}
