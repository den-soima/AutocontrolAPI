using System;
using System.Collections.Generic;
using System.Text;

namespace AutocontrolService.Data.Model.Report
{
    public class ReportErrorList
    {
        public string Reason { get; set; }
        public string Machine { get; set; }
        public int CountError { get; set; }
    }
}
