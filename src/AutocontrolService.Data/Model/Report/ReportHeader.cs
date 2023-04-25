using System;
using System.Collections.Generic;
using System.Text;

namespace AutocontrolService.Data.Model.Report
{
    public class ReportHeader
    {
        public DateTime ActualTime { get; set; }
        public DateTime ActualDate { get; set; }

        public string LineName { get; set; }

        public int nFillerMachine { get; set; }
    }
}
