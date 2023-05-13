using System;
using System.Collections.Generic;
using System.Text;

namespace LmsService.Data.Model.Dashboard
{
    public class DashboardHeader
    {
        public DateTime ActualShift { get; set; }
        public DateTime ActualTime { get; set; }
        public DateTime Duration { get; set; }
    }
}
