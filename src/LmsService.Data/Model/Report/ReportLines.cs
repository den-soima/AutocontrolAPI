using System;
using System.Collections.Generic;
using System.Text;
using System.ComponentModel.DataAnnotations;

namespace LmsService.Data.Model.Report
{
    public class ReportLines
    {
        [Key]
        public int LineLink { get; set; }
        public string LineName { get; set; }
    }
}
