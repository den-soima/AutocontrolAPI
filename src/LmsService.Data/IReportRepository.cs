using LmsService.Data.Model.Report;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace LmsService.Data
{
    public interface IReportRepository
    {
        IQueryable<ReportLines> ReportLinesGet();
        IQueryable<ReportHeader> ReportHeaderGet(int nLineLink);
        IQueryable<ReportProductionInfo> ReportProductionInfoGet(int nLineLink);
        IQueryable<ReportMachineError> ReportMachineErrorGet(int nLineLink);
        IQueryable<ReportMachineError> ReportMachineError2Get(int nLineLink);
        IQueryable<ReportStatesGraph> ReportStatesGraphGet(int nLineLink);
        IQueryable<ReportEfficiency> ReportEfficiencyGet(int nLineLink);
        IQueryable<ReportErrorList> ReportErroListGet(int nLineLink);
    }
}
