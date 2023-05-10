using System;
using System.Collections.Generic;
using System.Text;
using System.Linq;
using AutocontrolService.Data.Services;
using AutocontrolService.Data.Model;
using Microsoft.EntityFrameworkCore;
using AutocontrolService.Data.Model.Report;

namespace AutocontrolService.Data
{
    class ReportRepository : IReportRepository
    {

        private LmsContext _context;

        public ReportRepository(LmsContext context)
        {
            _context = context;
        }
       
        public IQueryable<ReportEfficiency> ReportEfficiencyGet(int nLineLink)
        {
            var value = _context.ReportEfficiency.FromSqlRaw<ReportEfficiency>($"EXECUTE [zmod].[sp_LmsReportLineEffByTime] {nLineLink}");
            return value;
        }

        public IQueryable<ReportErrorList> ReportErroListGet(int nLineLink)
        {
            var value = _context.ReportErrorList.FromSqlRaw<ReportErrorList>($"EXECUTE [zmod].[sp_LmsReportLineErrorList] {nLineLink}");
            return value;
        }

        public IQueryable<ReportHeader> ReportHeaderGet(int nLineLink)
        {
            var value = _context.ReportHeader.FromSqlRaw<ReportHeader>($"EXECUTE [zmod].[sp_LmsReportLineHeader] {nLineLink}");
            return value;
        }

        public IQueryable<ReportLines> ReportLinesGet()
        {
            var value = _context.ReportLines.FromSqlRaw<ReportLines>("EXECUTE [zmod].[sp_LmsReportLineLineLink]");
            return value;
        }

        public IQueryable<ReportMachineError> ReportMachineError2Get(int nLineLink)
        {
            var value = _context.ReportMachineError.FromSqlRaw<ReportMachineError>($"EXECUTE [zmod].[sp_LmsReportLineMachineError2] {nLineLink}");
            return value;
        }

        public IQueryable<ReportMachineError> ReportMachineErrorGet(int nLineLink)
        {
            var value = _context.ReportMachineError.FromSqlRaw<ReportMachineError>($"EXECUTE [zmod].[sp_LmsReportLineMachineError] {nLineLink}");
            return value;
        }

        public IQueryable<ReportProductionInfo> ReportProductionInfoGet(int nLineLink)
        {
            var value = _context.ReportProductionInfo.FromSqlRaw<ReportProductionInfo>($"EXECUTE [zmod].[sp_LmsReportLineProductioninfo] {nLineLink}");
            return value;
        }

        public IQueryable<ReportStatesGraph> ReportStatesGraphGet(int nLineLink)
        {
            var value = _context.ReportStatesGraph.FromSqlRaw<ReportStatesGraph>($"EXECUTE [zmod].[sp_LmsReportLineStatesGraph] {nLineLink}");
            return value;
        }
    }
}
