using System;
using System.Collections.Generic;
using System.Text;

namespace LmsService.Data.Model.Report
{
    public class ReportMachineError
    {
        public string szText { get; set; }
        public decimal Efficiency { get; set; }
        public decimal Speed { get; set; }
        public int nError { get; set; }
        public int nSortOrder { get; set; }
        public string ColorCode { get; set; }
        public string FontColor { get; set; }
    }
}
