using System;
using System.Collections.Generic;
using System.Text;

namespace AutocontrolService.Data.Model.Report
{
    public class ReportStatesGraph
    {
        public string Machine { get; set; }
        public int nTime { get; set; }
        public string ColorCode { get; set; }
        public int pStateNumber { get; set; }

        public int bProductive { get; set; }
        public int SortOrder { get; set; }
    }
}
