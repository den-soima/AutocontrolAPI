using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PlantiT.Base.ServiceBootstrapping.SwaggerConfiguration;
using PlantiT.Base.PolicyValidation.Attributes;
using LmsService.Data;
using LmsService.Data.Model.Autocontrol;
using Microsoft.AspNetCore.JsonPatch;
using System.IO;
using Microsoft.AspNetCore.Http;
using System.Net.Http.Headers;
using LmsService.Implementation.Config;

namespace LmsService.Implementation.Controllers.V1
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
        private LmsServiceSettings _lmsServiceSettings;

        public AutocontrolController(IAutocontrolRepository autocontrolRepository, LmsServiceSettings settings)
        {
            this._autocontrolRepository = autocontrolRepository;
            this._lmsServiceSettings = settings;
        }
        /// <summary>
        /// Gets all entries in the list of Autocontrols.
        /// </summary>
        /// <returns>The entire list of Autocontrols who immortalized themselves in this session.</returns>
        [HttpGet]
        //[RequiresPermission("Guest","Read")]
        [Produces(typeof(List<Autocontrol>))] //Required for API-Documentation; this way required data structures are also documented.
        public IActionResult GetAutocontrols(string? szPiTBaseUserUid = null)
        {
            try
            {
                var autocontrols = _autocontrolRepository.GetAutocontrols(szPiTBaseUserUid);
                return Ok(autocontrols);
            }
            catch (Exception ex)
            {

                return StatusCode(500, ex.Message);
            }
        }
        /// <summary>
        /// Gets all Fields of specific Autocontrol.
        /// </summary>
        /// <returns>The entire list of Fields who immortalized themselves in this session.</returns>
        [HttpGet("fields/{nKeyAC}")]
        //[RequiresPermission("Guest","Read")]
        [Produces(typeof(List<AutocontrolDialog>))] //Required for API-Documentation; this way required data structures are also documented.
        public IActionResult GetDialogFields(int nKeyAC)
        {
            try
            {
                var dialogFields = _autocontrolRepository.GetDialogFieldsByACId(nKeyAC);
                return Ok(dialogFields);
            }
            catch (Exception ex)
            {

                return StatusCode(500, ex.Message);
            }
        }

        /// <summary>
        /// Gets all Enums for specific Autocontrol fied.
        /// </summary>
        /// <returns>The entire list of Fields who immortalized themselves in this session.</returns>
        [HttpGet("fieldenum/{nACFId}")]
        //[RequiresPermission("Guest","Read")]
        [Produces(typeof(List<AutocontrolFieldEnum>))] //Required for API-Documentation; this way required data structures are also documented.
        public IActionResult GetEnumsByFieldId(int nACFId)
        {
            try
            {
                var dialogFields = _autocontrolRepository.GetEnumsByFieldId(nACFId);
                return Ok(dialogFields);
            }
            catch (Exception ex)
            {

                return StatusCode(500, ex.Message);
            }
        }

        /// <summary>
        /// Upload files.
        /// </summary>
        /// <returns>Files count and size</returns>
        [HttpPost("field/file/{nACFId}"), DisableRequestSizeLimit]
        //[RequiresPermission("Guest","Read")]
        [Produces(typeof(IFormFile))] //Required for API-Documentation; this way required data structures are also documented.    
        public async Task<IActionResult> FilesUpload(int nACFId, IFormFile file)
        {
            if (file == null)
                return BadRequest("File ");

            try
            {
                string lmsFolderPath = _lmsServiceSettings.AutocontrolFilesPath;         

                var fileName = Path.GetFileName(ContentDispositionHeaderValue.Parse(file.ContentDisposition).FileName.ToString().Trim('"'));            

                long size = await _autocontrolRepository.CreateAutocontrolFile(nACFId, file, lmsFolderPath, fileName);

                return Ok(new { name = fileName, size = (size/1024).ToString() + " kB"});
            }
            catch (Exception ex)
            {

                return StatusCode(500, ex.Message);
            }
        }


        /// <summary>
        /// Update autocontrol fields.
        /// </summary>
        /// <returns>The number of affected row.</returns>
        [HttpPut("field")]
        //[RequiresPermission("Guest","Read")]
        [Produces(typeof(List<AutocontrolField>))] //Required for API-Documentation; this way required data structures are also documented.
        public IActionResult UpdateAutocontrolField(AutocontrolField field)
        {
            try
            {
                if (field.nKey <= 0)
                    return BadRequest("Field ID incorrect");

                var rowAffected = _autocontrolRepository.UpdateAutocontrolField(field);
                return Ok(rowAffected);

            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }
        }



    }
}
