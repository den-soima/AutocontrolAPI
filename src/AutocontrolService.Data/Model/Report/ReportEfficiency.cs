using System;
using System.Collections.Generic;
using System.Text;
using System.ComponentModel.DataAnnotations;

namespace AutocontrolService.Data.Model.Report
{
    
    public class ReportEfficiency
    {
        public int HoursAgo { get; set; }
        public int HourRecorded { get; set; }

        public decimal PercEff { get; set; }
        public decimal PercEffAcumulado { get; set; }
    }
}
