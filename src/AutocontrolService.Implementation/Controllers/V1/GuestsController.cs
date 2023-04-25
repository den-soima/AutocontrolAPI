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
    [PitApiExplorerSettings(typeof(GuestsController))] //Required for grouping API-functions in automatic API-documentation generation.
    public class GuestsController : Controller
    {
        private GuestBook guestBook;
        private ILogWriter log;

        enum ResourceKey
        {
            EntryCreated,
            EntryDeleted
        }

        /// <summary>
        /// Instantiates the controller.
        /// </summary>
        /// <param name="guestBook">The storage resource for adding and retrieving guests.</param>
        /// <param name="log">Required for logging.</param>
        public GuestsController(GuestBook guestBook, ILogWriter log)
        {
            this.guestBook = guestBook;
            this.log = log;
        }

        /// <summary>
        /// Gets all entries in the list of guests.
        /// </summary>
        /// <returns>The entire list of guests who immortalized themselves in this session.</returns>
        [HttpGet]
        //[RequiresPermission("Guest","Read")]
        [Produces(typeof(List<GuestBookEntry>))] //Required for API-Documentation; this way required data structures are also documented.
        public IActionResult Get()
        {
            return Ok(guestBook.Entries);
        }

        /// <summary>
        /// Gets a guest with a specific index on the list.
        /// </summary>
        /// <param name="index">The guest in question.</param>
        /// <returns></returns>
        [HttpGet("{index}")]
        [Produces(typeof(GuestBookEntry))]
        public IActionResult Get(int index)
        {
            return  Ok(guestBook.GetEntry(index));
        }

        /// <summary>
        /// Immortalizes a new guest for the time of this session.
        /// </summary>
        /// <param name="entry">The new entry.</param>
        [HttpPut]
        [Produces(typeof(GuestBookEntry))]
        // To use the below line, activate authentication in your module-service, uncomment the below line and
        // register the permission at Plant iT base UserMgmt using Cmdlets. After that, you can associate the permission
        // to a user-group by creating a policy. For Details, please read the developer manual's chapter "Authorization".
        //[RequiresPermission("Guest","Write")]
        public IActionResult Put([FromBody] GuestBookEntry entry)
        {
            guestBook.AddEntry(entry);
            log.WriteToLog().Information(ResourceKey.EntryCreated);
            return Ok(entry);
        }

        /// <summary>
        /// De-immortalizes a guest, a functionality due to popular request.
        /// </summary>
        /// <param name="index">The index of the item to be deleted.</param>
        [HttpDelete("{index}")]
        public IActionResult Delete(int index)
        {
            guestBook.DeleteEntry(index);
            log.WriteToLog().Information(ResourceKey.EntryDeleted);
            return Ok();
        }
    }
}
