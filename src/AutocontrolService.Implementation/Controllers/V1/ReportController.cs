using AutocontrolService.Data;
using AutocontrolService.Data.Model.Report;
using Microsoft.AspNetCore.Mvc;
using PlantiT.Base.ServiceBootstrapping.SwaggerConfiguration;
using System;
using System.Collections.Generic;

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
    [PitApiExplorerSettings(typeof(ReportController))] //Required for grouping API-functions in automatic API-documentation generation.
    public class ReportController : ControllerBase
    {
        private IReportRepository _reportRepository;

        public ReportController(IReportRepository reportRepository)
        {
            this._reportRepository = reportRepository;
        }

        /// <summary>
        /// Get all Lines for lms report
        /// </summary>
        /// <returns> </returns>
        [HttpGet("lines")]
        //[RequiresPermission("Guest","Read")]
        [Produces(typeof(List<ReportLines>))] // Required for API-Documentation; this way required data structures are also documented.
        public IActionResult GetLines()
        {
            try
            {
                var result = _reportRepository.ReportLinesGet();
                return Ok(result);
            }
            catch (Exception ex)
            {

                return StatusCode(500, ex.Message);
            }
        }
        /// <summary>
        /// Get Header for specific line for lms report.
        /// </summary>
        /// <returns> .</returns>
        [HttpGet("header/{nLineLink}")]
        //[RequiresPermission("Guest","Read")]
        [Produces(typeof(List<ReportHeader>))] // Required for API-Documentation; this way required data structures are also documented.
        public IActionResult GetHeader(int nLineLink)
        {
            try
            {
                var result = _reportRepository.ReportHeaderGet(nLineLink);              
                return Ok(result);
            }
            catch (Exception ex)
            {

                return StatusCode(500, ex.Message);
            }
        }
        /// <summary>
        /// Get Production Info for specific line for lms report.
        /// </summary>
        /// <returns> .</returns>
        [HttpGet("productionInfo/{nLineLink}")]
        //[RequiresPermission("Guest","Read")]
        [Produces(typeof(List<ReportProductionInfo>))] // Required for API-Documentation; this way required data structures are also documented.
        public IActionResult GetProductionInfo(int nLineLink)
        {
            try
            {
                var result = _reportRepository.ReportProductionInfoGet(nLineLink);
                return Ok(result);
            }
            catch (Exception ex)
            {

                return StatusCode(500, ex.Message);
            }
        }

        /// <summary>
        /// Get Machine Error for specific line for lms report.
        /// </summary>
        /// <returns> .</returns>
        [HttpGet("machineError/{nLineLink}")]
        //[RequiresPermission("Guest","Read")]
        [Produces(typeof(List<ReportMachineError>))] // Required for API-Documentation; this way required data structures are also documented.
        public IActionResult GetMachineError(int nLineLink)
        {
            try
            {
                var result = _reportRepository.ReportMachineErrorGet(nLineLink);
                return Ok(result);
            }
            catch (Exception ex)
            {

                return StatusCode(500, ex.Message);
            }
        }

        /// <summary>
        /// Get Machine Error 2 for specific line for lms report.
        /// </summary>
        /// <returns> .</returns>
        [HttpGet("machineError2/{nLineLink}")]
        //[RequiresPermission("Guest","Read")]
        [Produces(typeof(List<ReportMachineError>))] // Required for API-Documentation; this way required data structures are also documented.
        public IActionResult GetMachineError2(int nLineLink)
        {
            try
            {
                var result = _reportRepository.ReportMachineError2Get(nLineLink);
                return Ok(result);
            }
            catch (Exception ex)
            {

                return StatusCode(500, ex.Message);
            }
        }

        /// <summary>
        /// Get Efficiency by Time for specific line for lms report.
        /// </summary>
        /// <returns> .</returns>
        [HttpGet("efficiency/{nLineLink}")]
        //[RequiresPermission("Guest","Read")]
        [Produces(typeof(List<ReportEfficiency>))] // Required for API-Documentation; this way required data structures are also documented.
        public IActionResult GetEfficiency(int nLineLink)
        {
            try
            {
                var result = _reportRepository.ReportEfficiencyGet(nLineLink);
                return Ok(result);
            }
            catch (Exception ex)
            {

                return StatusCode(500, ex.Message);
            }
        }

        /// <summary>
        /// Get Sate Graph for specific line for lms report.
        /// </summary>
        /// <returns> .</returns>
        [HttpGet("statesGraph/{nLineLink}")]
        //[RequiresPermission("Guest","Read")]
        [Produces(typeof(List<ReportStatesGraph>))] // Required for API-Documentation; this way required data structures are also documented.
        public IActionResult GetStateGraph(int nLineLink)
        {
            try
            {
                var result = _reportRepository.ReportStatesGraphGet(nLineLink);
                return Ok(result);
            }
            catch (Exception ex)
            {

                return StatusCode(500, ex.Message);
            }
        }

        /// <summary>
        /// Get Sate Graph for specific line for lms report.
        /// </summary>
        /// <returns> .</returns>
        [HttpGet("errorList/{nLineLink}")]
        //[RequiresPermission("Guest","Read")]
        [Produces(typeof(List<ReportErrorList>))] // Required for API-Documentation; this way required data structures are also documented.
        public IActionResult GetErrorList(int nLineLink)
        {
            try
            {
                var result = _reportRepository.ReportErroListGet(nLineLink);
                return Ok(result);
            }
            catch (Exception ex)
            {

                return StatusCode(500, ex.Message);
            }
        }
    }
}
